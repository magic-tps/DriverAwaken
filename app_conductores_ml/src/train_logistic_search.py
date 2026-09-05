import argparse
import json
from pathlib import Path

import joblib
import matplotlib
import numpy as np
import pandas as pd
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
from sklearn.model_selection import GridSearchCV
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
    train_index, test_index, _ = grouped_holdout_indices(y, groups)
    return (
        x.iloc[train_index],
        x.iloc[test_index],
        y.iloc[train_index],
        y.iloc[test_index],
        groups.iloc[train_index],
        groups.iloc[test_index],
    )


def build_pipeline(max_iter: int) -> Pipeline:
    return Pipeline(
        [
            ("imputer", SimpleImputer(strategy="median", keep_empty_features=True)),
            ("scaler", StandardScaler()),
            (
                "classifier",
                LogisticRegression(
                    class_weight="balanced",
                    max_iter=max_iter,
                    random_state=42,
                ),
            ),
        ]
    )


def train_logistic_search(
    csv_path: Path,
    cv_splits: int,
    max_iter: int,
) -> dict[str, object]:
    ensure_project_dirs()
    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)

    x, y, groups, feature_columns = load_training_data(csv_path)
    x_train, x_test, y_train, y_test, groups_train, groups_test = split_by_subject(x, y, groups)
    cv_splits = min(max(2, cv_splits), int(groups_train.nunique()))

    search = GridSearchCV(
        estimator=build_pipeline(max_iter),
        param_grid={
            "classifier__C": [0.02, 0.05, 0.1, 0.2, 0.4, 0.6, 1.0, 2.0, 5.0, 10.0],
        },
        scoring="f1_macro",
        cv=create_grouped_cv(groups_train, cv_splits),
        n_jobs=-1,
        refit=True,
        verbose=1,
    )
    search.fit(x_train, y_train, groups=groups_train)

    model = search.best_estimator_
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
        "model": "logistic_search",
        "accuracy": float(accuracy_score(y_test, y_pred)),
        "balanced_accuracy": float(balanced_accuracy_score(y_test, y_pred)),
        "precision_weighted": float(precision),
        "recall_weighted": float(recall),
        "f1_weighted": float(f1),
        "macro_f1": float(report["macro avg"]["f1-score"]),
        "somnoliento_recall": float(report["somnoliento"]["recall"]),
        "cansancio_recall": float(report["cansancio"]["recall"]),
        "despierto_recall": float(report["despierto"]["recall"]),
        "best_cv_score": float(search.best_score_),
        "best_params": search.best_params_,
        "feature_count": int(len(feature_columns)),
        "train_windows": int(len(x_train)),
        "test_windows": int(len(x_test)),
        "train_videos": int(groups_train.nunique()),
        "test_videos": int(groups_test.nunique()),
    }

    model_path = MODELS_DIR / "drowsiness_logistic_search.joblib"
    joblib.dump(
        {
            "pipeline": model,
            "feature_columns": feature_columns,
            "class_names": CLASS_NAMES,
            "source_csv": str(csv_path),
            "model_name": "logistic_search",
            "metrics": metrics,
            "cv_results": {
                "best_score": float(search.best_score_),
                "best_params": search.best_params_,
            },
        },
        model_path,
    )
    (REPORTS_DIR / "logistic_search_metrics.json").write_text(
        json.dumps(metrics, indent=2), encoding="utf-8"
    )
    (REPORTS_DIR / "logistic_search_classification_report.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    save_confusion_matrix(matrix, REPORTS_DIR / "logistic_search_confusion_matrix.png")

    print("\n=== Logistic Search entrenado ===")
    print(f"Modelo: {model_path}")
    print(f"Mejor CV f1_macro: {search.best_score_:.4f}")
    print(f"Mejores params: {search.best_params_}")
    print(f"Accuracy: {metrics['accuracy']:.4f}")
    print(f"Balanced accuracy: {metrics['balanced_accuracy']:.4f}")
    print(f"Macro F1: {metrics['macro_f1']:.4f}")
    print(f"Recall somnoliento: {metrics['somnoliento_recall']:.4f}")
    return metrics


def save_confusion_matrix(matrix: np.ndarray, output_path: Path) -> None:
    display = ConfusionMatrixDisplay(
        confusion_matrix=matrix,
        display_labels=[CLASS_NAMES[index] for index in CLASS_LABELS],
    )
    fig, ax = plt.subplots(figsize=(7, 6))
    display.plot(ax=ax, cmap="Purples", values_format="d", colorbar=False)
    ax.set_title("Logistic Search - Matriz de confusion")
    fig.tight_layout()
    fig.savefig(output_path, dpi=160)
    plt.close(fig)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Busca C para regresion logistica.")
    parser.add_argument(
        "--csv",
        type=Path,
        default=FEATURES_DIR / "fold5_features_enhanced.csv",
    )
    parser.add_argument("--cv_splits", type=int, default=4)
    parser.add_argument("--max_iter", type=int, default=2500)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    train_logistic_search(
        csv_path=args.csv,
        cv_splits=max(2, args.cv_splits),
        max_iter=max(200, args.max_iter),
    )


if __name__ == "__main__":
    main()
