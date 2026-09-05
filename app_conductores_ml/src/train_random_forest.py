import argparse
import json
from pathlib import Path
from typing import Any

import joblib
import matplotlib
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.metrics import (
    ConfusionMatrixDisplay,
    accuracy_score,
    balanced_accuracy_score,
    classification_report,
    confusion_matrix,
    precision_recall_fscore_support,
)
from sklearn.model_selection import RandomizedSearchCV
from sklearn.pipeline import Pipeline

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

from config import (  # noqa: E402
    CLASS_NAMES,
    FEATURES_DIR,
    IDENTIFIER_COLUMNS,
    MODELS_DIR,
    REPORTS_DIR,
    ensure_project_dirs,
    infer_feature_columns,
)
from splitting import (  # noqa: E402
    create_grouped_cv,
    extract_subject_groups,
    grouped_holdout_indices,
)

CLASS_LABELS = list(CLASS_NAMES.keys())


def load_training_data(csv_path: Path) -> tuple[pd.DataFrame, pd.Series, pd.Series, list[str]]:
    if not csv_path.exists():
        raise FileNotFoundError(f"No existe el CSV de features: {csv_path}")

    df = pd.read_csv(csv_path)
    if df.empty:
        raise ValueError("El CSV de features esta vacio.")

    if "label" not in df.columns:
        raise ValueError("El CSV debe incluir label.")

    feature_columns = [
        column
        for column in infer_feature_columns(list(df.columns))
        if column not in IDENTIFIER_COLUMNS
        and pd.api.types.is_numeric_dtype(pd.to_numeric(df[column], errors="coerce"))
    ]
    if not feature_columns:
        raise ValueError("No se encontraron columnas numericas de features.")

    x = df[feature_columns].apply(pd.to_numeric, errors="coerce")
    y = df["label"].astype(int)
    groups = extract_subject_groups(df)
    return x, y, groups, feature_columns


def split_by_subject(
    x: pd.DataFrame,
    y: pd.Series,
    groups: pd.Series,
) -> tuple[pd.DataFrame, pd.DataFrame, pd.Series, pd.Series, pd.Series, pd.Series]:
    if groups.nunique() < 2:
        raise ValueError("Se necesitan al menos 2 sujetos para separar train/test.")

    train_index, test_index, _ = grouped_holdout_indices(y, groups)
    return (
        x.iloc[train_index],
        x.iloc[test_index],
        y.iloc[train_index],
        y.iloc[test_index],
        groups.iloc[train_index],
        groups.iloc[test_index],
    )


def build_pipeline() -> Pipeline:
    return Pipeline(
        steps=[
            ("imputer", SimpleImputer(strategy="median", keep_empty_features=True)),
            (
                "classifier",
                RandomForestClassifier(
                    n_estimators=700,
                    class_weight="balanced_subsample",
                    random_state=42,
                    n_jobs=-1,
                ),
            ),
        ]
    )


def fit_random_forest(
    x_train: pd.DataFrame,
    y_train: pd.Series,
    groups_train: pd.Series,
    search_iter: int,
    cv_splits: int,
    scoring: str,
) -> tuple[Pipeline, dict[str, Any]]:
    pipeline = build_pipeline()
    group_count = int(groups_train.nunique())
    cv_splits = min(max(2, cv_splits), group_count)

    if search_iter <= 0 or group_count < 3:
        pipeline.fit(x_train, y_train)
        return pipeline, {
            "search_enabled": False,
            "reason": "search_iter <= 0 o pocos grupos de video",
        }

    param_distributions = {
        "classifier__n_estimators": [500, 700, 900, 1100],
        "classifier__max_depth": [None, 8, 12, 16, 24, 32],
        "classifier__min_samples_split": [2, 4, 8, 12],
        "classifier__min_samples_leaf": [1, 2, 4, 6],
        "classifier__max_features": ["sqrt", "log2", 0.5, 0.75, None],
        "classifier__bootstrap": [True, False],
        "classifier__criterion": ["gini", "entropy", "log_loss"],
    }
    search = RandomizedSearchCV(
        estimator=pipeline,
        param_distributions=param_distributions,
        n_iter=search_iter,
        scoring=scoring,
        cv=create_grouped_cv(groups_train, cv_splits),
        random_state=42,
        n_jobs=1,
        refit=True,
        verbose=1,
    )
    search.fit(x_train, y_train, groups=groups_train)
    best_pipeline = search.best_estimator_
    best_pipeline.named_steps["classifier"].set_params(n_jobs=-1)

    metadata = {
        "search_enabled": True,
        "search_iter": int(search_iter),
        "cv_splits": int(cv_splits),
        "scoring": scoring,
        "best_score": float(search.best_score_),
        "best_params": search.best_params_,
    }
    return best_pipeline, metadata


def train(
    csv_path: Path,
    search_iter: int,
    cv_splits: int,
    scoring: str,
) -> dict[str, object]:
    ensure_project_dirs()
    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)

    x, y, groups, feature_columns = load_training_data(csv_path)
    x_train, x_test, y_train, y_test, groups_train, groups_test = split_by_subject(x, y, groups)
    pipeline, search_metadata = fit_random_forest(
        x_train=x_train,
        y_train=y_train,
        groups_train=groups_train,
        search_iter=search_iter,
        cv_splits=cv_splits,
        scoring=scoring,
    )

    y_pred = pipeline.predict(x_test)
    report = classification_report(
        y_test,
        y_pred,
        labels=CLASS_LABELS,
        target_names=[CLASS_NAMES[index] for index in CLASS_LABELS],
        output_dict=True,
        zero_division=0,
    )
    matrix = confusion_matrix(y_test, y_pred, labels=CLASS_LABELS)
    precision, recall, f1, _ = precision_recall_fscore_support(
        y_test,
        y_pred,
        average="weighted",
        zero_division=0,
    )
    metrics = {
        "accuracy": float(accuracy_score(y_test, y_pred)),
        "balanced_accuracy": float(balanced_accuracy_score(y_test, y_pred)),
        "precision_weighted": float(precision),
        "recall_weighted": float(recall),
        "f1_weighted": float(f1),
        "train_windows": int(len(x_train)),
        "test_windows": int(len(x_test)),
        "train_videos": int(groups_train.nunique()),
        "test_videos": int(groups_test.nunique()),
        "class_distribution": {
            str(int(label)): int(count) for label, count in y.value_counts().sort_index().items()
        },
        "test_class_distribution": {
            str(int(label)): int(count)
            for label, count in y_test.value_counts().sort_index().items()
        },
        "prediction_distribution": {
            str(int(label)): int(count)
            for label, count in pd.Series(y_pred).value_counts().sort_index().items()
        },
        "search": search_metadata,
        "feature_count": int(len(feature_columns)),
    }

    model_path = MODELS_DIR / "drowsiness_random_forest.joblib"
    joblib.dump(
        {
            "pipeline": pipeline,
            "feature_columns": feature_columns,
            "class_names": CLASS_NAMES,
            "search": search_metadata,
        },
        model_path,
    )

    (REPORTS_DIR / "random_forest_classification_report.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    (REPORTS_DIR / "random_forest_metrics.json").write_text(
        json.dumps(metrics, indent=2), encoding="utf-8"
    )
    (REPORTS_DIR / "random_forest_best_params.json").write_text(
        json.dumps(search_metadata, indent=2), encoding="utf-8"
    )

    save_confusion_matrix(
        matrix,
        REPORTS_DIR / "random_forest_confusion_matrix.png",
        "Random Forest - Matriz de confusion",
    )
    save_feature_importance(pipeline, REPORTS_DIR, feature_columns)

    print("\n=== Random Forest entrenado ===")
    print(f"Modelo: {model_path}")
    print(f"Accuracy: {metrics['accuracy']:.4f}")
    print(f"Balanced accuracy: {metrics['balanced_accuracy']:.4f}")
    if search_metadata.get("search_enabled"):
        print(f"Mejor score CV ({scoring}): {search_metadata['best_score']:.4f}")
        print(f"Mejores parametros: {search_metadata['best_params']}")
    print_conclusion(report, matrix, metrics)
    return metrics


def save_confusion_matrix(matrix: np.ndarray, output_path: Path, title: str) -> None:
    display = ConfusionMatrixDisplay(
        confusion_matrix=matrix,
        display_labels=[CLASS_NAMES[index] for index in CLASS_LABELS],
    )
    fig, ax = plt.subplots(figsize=(7, 6))
    display.plot(ax=ax, cmap="Blues", values_format="d", colorbar=False)
    ax.set_title(title)
    fig.tight_layout()
    fig.savefig(output_path, dpi=160)
    plt.close(fig)


def save_feature_importance(
    pipeline: Pipeline,
    reports_dir: Path,
    feature_columns: list[str],
) -> None:
    classifier = pipeline.named_steps["classifier"]
    importances = classifier.feature_importances_
    importance_df = pd.DataFrame(
        {
            "feature": feature_columns,
            "importance": importances,
        }
    ).sort_values("importance", ascending=False)
    importance_df.to_csv(reports_dir / "feature_importance.csv", index=False)

    top = importance_df.head(20).sort_values("importance")
    fig, ax = plt.subplots(figsize=(9, 7))
    ax.barh(top["feature"], top["importance"], color="#24D17E")
    ax.set_title("Random Forest - Feature importance")
    ax.set_xlabel("Importancia")
    fig.tight_layout()
    fig.savefig(reports_dir / "feature_importance.png", dpi=160)
    plt.close(fig)


def print_conclusion(
    report: dict[str, object],
    matrix: np.ndarray,
    metrics: dict[str, object],
) -> None:
    recalls = {
        class_name: float(report.get(class_name, {}).get("recall", 0.0))
        for class_name in CLASS_NAMES.values()
    }
    best_class = max(recalls, key=recalls.get)
    print(f"Clase que detecta mejor por recall: {best_class} ({recalls[best_class]:.3f})")

    off_diagonal = matrix.copy()
    np.fill_diagonal(off_diagonal, 0)
    if off_diagonal.max() > 0:
        row, col = np.unravel_index(off_diagonal.argmax(), off_diagonal.shape)
        labels = list(CLASS_NAMES.values())
        print(
            "Mayor confusion: "
            f"{labels[row]} clasificado como {labels[col]} "
            f"({int(off_diagonal[row, col])} ventanas)"
        )
    else:
        print("No hubo confusiones en el conjunto de prueba.")

    distribution = {
        int(label): int(count) for label, count in metrics["class_distribution"].items()
    }
    counts = list(distribution.values())
    if counts and min(counts) > 0 and max(counts) / min(counts) > 1.5:
        print("El dataset esta desbalanceado: conviene revisar pesos o muestreo.")
    else:
        print("El balance de clases parece razonable para una linea base.")

    print(
        "Uso recomendado: mantener reglas criticas en Flutter y usar este modelo "
        "como senal adicional de riesgo."
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Entrena Random Forest optimizado.")
    parser.add_argument(
        "--csv",
        type=Path,
        default=FEATURES_DIR / "fold5_features.csv",
        help="CSV generado por extract_features.py.",
    )
    parser.add_argument(
        "--search_iter",
        type=int,
        default=20,
        help="Iteraciones de busqueda aleatoria. Usa 0 para desactivar.",
    )
    parser.add_argument(
        "--cv_splits",
        type=int,
        default=4,
        help="Folds de GroupKFold durante busqueda.",
    )
    parser.add_argument(
        "--scoring",
        type=str,
        default="f1_macro",
        help="Metrica de RandomizedSearchCV.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    train(
        csv_path=args.csv,
        search_iter=max(0, args.search_iter),
        cv_splits=max(2, args.cv_splits),
        scoring=args.scoring,
    )


if __name__ == "__main__":
    main()
