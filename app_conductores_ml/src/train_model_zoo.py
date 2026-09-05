import argparse
import json
from pathlib import Path

import joblib
import matplotlib
import numpy as np
import pandas as pd
from sklearn.ensemble import (
    ExtraTreesClassifier,
    HistGradientBoostingClassifier,
    RandomForestClassifier,
    VotingClassifier,
)
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    ConfusionMatrixDisplay,
    accuracy_score,
    balanced_accuracy_score,
    classification_report,
    confusion_matrix,
    precision_recall_fscore_support,
)
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

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
from splitting import extract_subject_groups, grouped_holdout_indices  # noqa: E402

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
    train_index, test_index, _ = grouped_holdout_indices(y, groups)
    return (
        x.iloc[train_index],
        x.iloc[test_index],
        y.iloc[train_index],
        y.iloc[test_index],
        groups.iloc[train_index],
        groups.iloc[test_index],
    )


def build_models(n_estimators: int) -> dict[str, object]:
    random_forest = Pipeline(
        [
            ("imputer", SimpleImputer(strategy="median", keep_empty_features=True)),
            (
                "classifier",
                RandomForestClassifier(
                    n_estimators=n_estimators,
                    max_depth=12,
                    min_samples_leaf=2,
                    max_features=0.5,
                    class_weight="balanced_subsample",
                    random_state=42,
                    n_jobs=-1,
                ),
            ),
        ]
    )
    extra_trees = Pipeline(
        [
            ("imputer", SimpleImputer(strategy="median", keep_empty_features=True)),
            (
                "classifier",
                ExtraTreesClassifier(
                    n_estimators=n_estimators,
                    max_depth=None,
                    min_samples_leaf=1,
                    max_features="sqrt",
                    class_weight="balanced",
                    random_state=42,
                    n_jobs=-1,
                ),
            ),
        ]
    )
    extra_trees_smooth = Pipeline(
        [
            ("imputer", SimpleImputer(strategy="median", keep_empty_features=True)),
            (
                "classifier",
                ExtraTreesClassifier(
                    n_estimators=n_estimators,
                    max_depth=18,
                    min_samples_leaf=2,
                    max_features=0.5,
                    class_weight="balanced",
                    random_state=84,
                    n_jobs=-1,
                ),
            ),
        ]
    )
    hist_gradient_boosting = Pipeline(
        [
            ("imputer", SimpleImputer(strategy="median", keep_empty_features=True)),
            (
                "classifier",
                HistGradientBoostingClassifier(
                    max_iter=450,
                    learning_rate=0.035,
                    max_leaf_nodes=31,
                    l2_regularization=0.08,
                    class_weight="balanced",
                    random_state=42,
                ),
            ),
        ]
    )
    logistic = Pipeline(
        [
            ("imputer", SimpleImputer(strategy="median", keep_empty_features=True)),
            ("scaler", StandardScaler()),
            (
                "classifier",
                LogisticRegression(
                    C=0.6,
                    class_weight="balanced",
                    max_iter=2000,
                    n_jobs=-1,
                    random_state=42,
                ),
            ),
        ]
    )

    voting = VotingClassifier(
        estimators=[
            ("extra_trees", extra_trees),
            ("extra_trees_smooth", extra_trees_smooth),
            ("hist_gradient_boosting", hist_gradient_boosting),
            ("random_forest", random_forest),
        ],
        voting="soft",
        weights=[2, 2, 2, 1],
        n_jobs=1,
        flatten_transform=True,
    )

    return {
        "extra_trees": extra_trees,
        "extra_trees_smooth": extra_trees_smooth,
        "hist_gradient_boosting": hist_gradient_boosting,
        "random_forest_stronger": random_forest,
        "logistic_baseline": logistic,
        "soft_voting_ensemble": voting,
    }


def train_model_zoo(csv_path: Path, n_estimators: int) -> dict[str, object]:
    ensure_project_dirs()
    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)

    x, y, groups, feature_columns = load_training_data(csv_path)
    x_train, x_test, y_train, y_test, groups_train, groups_test = split_by_subject(x, y, groups)
    models = build_models(n_estimators)

    results: list[dict[str, object]] = []
    best_name = ""
    best_score = -np.inf
    best_model = None
    best_report: dict[str, object] | None = None
    best_matrix: np.ndarray | None = None

    print("=== Model zoo tabular ===")
    print(f"CSV: {csv_path}")
    print(f"Features: {len(feature_columns)}")
    print(f"Train videos: {groups_train.nunique()} | Test videos: {groups_test.nunique()}")

    for name, model in models.items():
        print(f"\n--- Entrenando {name} ---")
        model.fit(x_train, y_train)
        y_pred = model.predict(x_test)
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
            "model": name,
            "accuracy": float(accuracy_score(y_test, y_pred)),
            "balanced_accuracy": float(balanced_accuracy_score(y_test, y_pred)),
            "precision_weighted": float(precision),
            "recall_weighted": float(recall),
            "f1_weighted": float(f1),
            "macro_f1": float(report["macro avg"]["f1-score"]),
            "somnoliento_recall": float(report["somnoliento"]["recall"]),
            "cansancio_recall": float(report["cansancio"]["recall"]),
            "despierto_recall": float(report["despierto"]["recall"]),
        }
        results.append(metrics)
        save_confusion_matrix(
            matrix,
            REPORTS_DIR / f"model_zoo_{name}_confusion_matrix.png",
            f"{name} - Matriz de confusion",
        )
        (REPORTS_DIR / f"model_zoo_{name}_classification_report.json").write_text(
            json.dumps(report, indent=2), encoding="utf-8"
        )
        print(
            f"accuracy={metrics['accuracy']:.4f} "
            f"balanced={metrics['balanced_accuracy']:.4f} "
            f"macro_f1={metrics['macro_f1']:.4f} "
            f"recall_somnoliento={metrics['somnoliento_recall']:.4f}"
        )

        selection_score = (
            0.45 * metrics["macro_f1"]
            + 0.35 * metrics["balanced_accuracy"]
            + 0.20 * metrics["somnoliento_recall"]
        )
        if selection_score > best_score:
            best_score = float(selection_score)
            best_name = name
            best_model = model
            best_report = report
            best_matrix = matrix

    if best_model is None or best_report is None or best_matrix is None:
        raise RuntimeError("No se pudo entrenar ningun modelo.")

    metrics_df = pd.DataFrame(results).sort_values("macro_f1", ascending=False)
    metrics_df.to_csv(REPORTS_DIR / "model_zoo_metrics.csv", index=False)
    (REPORTS_DIR / "model_zoo_metrics.json").write_text(
        json.dumps(results, indent=2), encoding="utf-8"
    )

    best_metrics = next(item for item in results if item["model"] == best_name)
    model_path = MODELS_DIR / "drowsiness_best_tabular.joblib"
    joblib.dump(
        {
            "pipeline": best_model,
            "feature_columns": feature_columns,
            "class_names": CLASS_NAMES,
            "source_csv": str(csv_path),
            "model_name": best_name,
            "metrics": best_metrics,
            "selection_score": best_score,
        },
        model_path,
    )
    (REPORTS_DIR / "best_tabular_metrics.json").write_text(
        json.dumps(best_metrics, indent=2), encoding="utf-8"
    )
    (REPORTS_DIR / "best_tabular_classification_report.json").write_text(
        json.dumps(best_report, indent=2), encoding="utf-8"
    )
    save_confusion_matrix(
        best_matrix,
        REPORTS_DIR / "best_tabular_confusion_matrix.png",
        f"Mejor tabular: {best_name}",
    )
    save_feature_importance_if_available(best_model, feature_columns, best_name)

    print("\n=== Mejor modelo tabular ===")
    print(f"Modelo: {best_name}")
    print(f"Archivo: {model_path}")
    print(f"Accuracy: {best_metrics['accuracy']:.4f}")
    print(f"Balanced accuracy: {best_metrics['balanced_accuracy']:.4f}")
    print(f"Macro F1: {best_metrics['macro_f1']:.4f}")
    print(f"Recall somnoliento: {best_metrics['somnoliento_recall']:.4f}")
    return {
        "best_model": best_name,
        "best_metrics": best_metrics,
        "all_metrics": results,
    }


def save_confusion_matrix(matrix: np.ndarray, output_path: Path, title: str) -> None:
    display = ConfusionMatrixDisplay(
        confusion_matrix=matrix,
        display_labels=[CLASS_NAMES[index] for index in CLASS_LABELS],
    )
    fig, ax = plt.subplots(figsize=(7, 6))
    display.plot(ax=ax, cmap="Greens", values_format="d", colorbar=False)
    ax.set_title(title)
    fig.tight_layout()
    fig.savefig(output_path, dpi=160)
    plt.close(fig)


def save_feature_importance_if_available(
    model: object,
    feature_columns: list[str],
    model_name: str,
) -> None:
    classifier = model
    if isinstance(model, Pipeline):
        classifier = model.named_steps.get("classifier")
    if not hasattr(classifier, "feature_importances_"):
        return

    importance_df = pd.DataFrame(
        {
            "feature": feature_columns,
            "importance": classifier.feature_importances_,
        }
    ).sort_values("importance", ascending=False)
    importance_df.to_csv(REPORTS_DIR / "best_tabular_feature_importance.csv", index=False)

    top = importance_df.head(25).sort_values("importance")
    fig, ax = plt.subplots(figsize=(10, 8))
    ax.barh(top["feature"], top["importance"], color="#00A884")
    ax.set_title(f"{model_name} - Feature importance")
    ax.set_xlabel("Importancia")
    fig.tight_layout()
    fig.savefig(REPORTS_DIR / "best_tabular_feature_importance.png", dpi=160)
    plt.close(fig)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Compara modelos tabulares fuertes.")
    parser.add_argument(
        "--csv",
        type=Path,
        default=FEATURES_DIR / "fold5_features_enhanced.csv",
    )
    parser.add_argument("--n_estimators", type=int, default=700)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    train_model_zoo(
        csv_path=args.csv,
        n_estimators=max(100, args.n_estimators),
    )


if __name__ == "__main__":
    main()
