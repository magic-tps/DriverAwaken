import argparse
import json
import shutil
import tempfile
from pathlib import Path

import matplotlib
import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.impute import SimpleImputer
from sklearn.metrics import (
    ConfusionMatrixDisplay,
    accuracy_score,
    balanced_accuracy_score,
    classification_report,
    confusion_matrix,
    precision_recall_fscore_support,
)
from sklearn.utils.class_weight import compute_class_weight

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


def split_train_validation_by_video(
    x_train: pd.DataFrame,
    y_train: pd.Series,
    groups_train: pd.Series,
    val_size: float,
) -> tuple[pd.DataFrame, pd.DataFrame | None, pd.Series, pd.Series | None]:
    if val_size <= 0 or groups_train.nunique() < 3:
        return x_train, None, y_train, None

    best_split: tuple[np.ndarray, np.ndarray] | None = None
    best_score = -1
    target_class_count = y_train.nunique()

    for seed in range(43, 58):
        fit_index, val_index, _ = grouped_holdout_indices(
            y_train,
            groups_train,
            test_size=val_size,
            base_seed=seed,
            candidate_seeds=1,
        )
        val_class_count = y_train.iloc[val_index].nunique()
        fit_class_count = y_train.iloc[fit_index].nunique()
        score = int(val_class_count == target_class_count) + int(
            fit_class_count == target_class_count
        )
        if score > best_score:
            best_score = score
            best_split = (fit_index, val_index)
        if score == 2:
            break

    if best_split is None:
        return x_train, None, y_train, None

    fit_index, val_index = best_split
    return (
        x_train.iloc[fit_index],
        x_train.iloc[val_index],
        y_train.iloc[fit_index],
        y_train.iloc[val_index],
    )


def build_model(feature_count: int, learning_rate: float) -> tf.keras.Model:
    regularizer = tf.keras.regularizers.l2(1e-4)
    model = tf.keras.Sequential(
        [
            tf.keras.layers.Input(shape=(feature_count,), name="features"),
            tf.keras.layers.Dense(128, activation="relu", kernel_regularizer=regularizer),
            tf.keras.layers.BatchNormalization(),
            tf.keras.layers.Dropout(0.30),
            tf.keras.layers.Dense(64, activation="relu", kernel_regularizer=regularizer),
            tf.keras.layers.BatchNormalization(),
            tf.keras.layers.Dropout(0.25),
            tf.keras.layers.Dense(32, activation="relu", kernel_regularizer=regularizer),
            tf.keras.layers.Dropout(0.15),
            tf.keras.layers.Dense(3, activation="softmax", name="class_probabilities"),
        ]
    )
    try:
        optimizer = tf.keras.optimizers.AdamW(
            learning_rate=learning_rate,
            weight_decay=1e-4,
        )
    except AttributeError:
        optimizer = tf.keras.optimizers.Adam(learning_rate=learning_rate)

    model.compile(
        optimizer=optimizer,
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )
    return model


def train(
    csv_path: Path,
    epochs: int,
    batch_size: int,
    learning_rate: float,
    patience: int,
    val_size: float,
    min_final_epochs: int,
) -> dict[str, object]:
    ensure_project_dirs()
    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    tf.keras.utils.set_random_seed(42)

    x, y, groups, feature_columns = load_training_data(csv_path)
    x_train, x_test, y_train, y_test, groups_train, groups_test = split_by_subject(x, y, groups)
    x_fit, x_val, y_fit, y_val = split_train_validation_by_video(
        x_train=x_train,
        y_train=y_train,
        groups_train=groups_train,
        val_size=val_size,
    )

    imputer = SimpleImputer(strategy="median", keep_empty_features=True)
    x_train_imputed = imputer.fit_transform(x_train)
    x_test_imputed = imputer.transform(x_test)
    x_fit_imputed = imputer.transform(x_fit)
    x_val_imputed = imputer.transform(x_val) if x_val is not None else None

    scaler_means = x_train_imputed.mean(axis=0)
    scaler_stds = x_train_imputed.std(axis=0)
    scaler_stds = np.where(scaler_stds == 0, 1.0, scaler_stds)

    x_train_scaled = scale_features(x_train_imputed, scaler_means, scaler_stds)
    x_test_scaled = scale_features(x_test_imputed, scaler_means, scaler_stds)
    x_fit_scaled = scale_features(x_fit_imputed, scaler_means, scaler_stds)
    x_val_scaled = (
        scale_features(x_val_imputed, scaler_means, scaler_stds)
        if x_val_imputed is not None
        else None
    )

    metadata = {
        "feature_columns": feature_columns,
        "imputer_medians": [float(value) for value in imputer.statistics_],
        "scaler_means": [float(value) for value in scaler_means],
        "scaler_stds": [float(value) for value in scaler_stds],
        "class_names": {str(key): value for key, value in CLASS_NAMES.items()},
        "training": {
            "epochs_requested": int(epochs),
            "batch_size": int(batch_size),
            "learning_rate": float(learning_rate),
            "patience": int(patience),
            "val_size": float(val_size),
            "min_final_epochs": int(min_final_epochs),
        },
    }
    metadata_path = MODELS_DIR / "preprocessing_metadata.json"
    metadata_path.write_text(json.dumps(metadata, indent=2), encoding="utf-8")

    class_weight = _class_weight(y_train)
    tuning_model = build_model(len(feature_columns), learning_rate)
    callbacks = build_callbacks(patience) if x_val_scaled is not None else []
    validation_data = (
        (x_val_scaled, y_val.to_numpy()) if x_val_scaled is not None and y_val is not None else None
    )
    tuning_history = tuning_model.fit(
        x_fit_scaled,
        y_fit.to_numpy(),
        epochs=epochs,
        batch_size=batch_size,
        validation_data=validation_data,
        callbacks=callbacks,
        class_weight=class_weight,
        verbose=2,
    )

    best_epoch = best_epoch_from_history(tuning_history)
    final_epochs = min(epochs, max(best_epoch, min_final_epochs))

    final_model = build_model(len(feature_columns), learning_rate)
    final_model.fit(
        x_train_scaled,
        y_train.to_numpy(),
        epochs=final_epochs,
        batch_size=batch_size,
        class_weight=class_weight,
        verbose=2,
    )

    keras_path = MODELS_DIR / "drowsiness_mlp.keras"
    final_model.save(keras_path)

    y_prob = final_model.predict(x_test_scaled, verbose=0)
    y_pred = np.argmax(y_prob, axis=1)

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
        "train_windows": int(len(x_train_scaled)),
        "fit_windows": int(len(x_fit_scaled)),
        "validation_windows": int(len(x_val_scaled)) if x_val_scaled is not None else 0,
        "test_windows": int(len(x_test_scaled)),
        "train_videos": int(groups_train.nunique()),
        "test_videos": int(groups_test.nunique()),
        "epochs_requested": int(epochs),
        "best_epoch_from_validation": int(best_epoch),
        "final_epochs": int(final_epochs),
        "batch_size": int(batch_size),
        "learning_rate": float(learning_rate),
        "feature_count": int(len(feature_columns)),
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
    }

    (REPORTS_DIR / "mlp_classification_report.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    (REPORTS_DIR / "mlp_metrics.json").write_text(json.dumps(metrics, indent=2), encoding="utf-8")
    save_confusion_matrix(matrix, REPORTS_DIR / "mlp_confusion_matrix.png")
    save_training_history(tuning_history, REPORTS_DIR / "training_history.png")
    export_tflite(final_model, MODELS_DIR / "drowsiness_mlp.tflite")

    print("\n=== MLP + TFLite entrenado ===")
    print(f"Modelo Keras: {keras_path}")
    print(f"Modelo TFLite: {MODELS_DIR / 'drowsiness_mlp.tflite'}")
    print(f"Metadata Flutter: {metadata_path}")
    print(f"Accuracy: {metrics['accuracy']:.4f}")
    print(f"Balanced accuracy: {metrics['balanced_accuracy']:.4f}")
    print(f"Mejor epoca de validacion: {best_epoch}")
    print(f"Epocas finales usadas: {final_epochs}")
    return metrics


def scale_features(
    values: np.ndarray,
    means: np.ndarray,
    stds: np.ndarray,
) -> np.ndarray:
    return ((values - means) / stds).astype("float32")


def build_callbacks(patience: int) -> list[tf.keras.callbacks.Callback]:
    return [
        tf.keras.callbacks.EarlyStopping(
            monitor="val_loss",
            patience=patience,
            min_delta=0.0005,
            restore_best_weights=True,
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor="val_loss",
            factor=0.5,
            patience=max(5, patience // 3),
            min_lr=1e-5,
            verbose=1,
        ),
    ]


def best_epoch_from_history(history: tf.keras.callbacks.History) -> int:
    values = history.history.get("val_loss") or history.history.get("loss") or []
    if not values:
        return 1
    return int(np.argmin(values) + 1)


def _class_weight(y_train: pd.Series) -> dict[int, float]:
    classes = np.unique(y_train.to_numpy())
    weights = compute_class_weight(
        class_weight="balanced",
        classes=classes,
        y=y_train.to_numpy(),
    )
    return {int(class_id): float(weight) for class_id, weight in zip(classes, weights, strict=True)}


def save_confusion_matrix(matrix: np.ndarray, output_path: Path) -> None:
    display = ConfusionMatrixDisplay(
        confusion_matrix=matrix,
        display_labels=[CLASS_NAMES[index] for index in CLASS_LABELS],
    )
    fig, ax = plt.subplots(figsize=(7, 6))
    display.plot(ax=ax, cmap="Oranges", values_format="d", colorbar=False)
    ax.set_title("MLP - Matriz de confusion")
    fig.tight_layout()
    fig.savefig(output_path, dpi=160)
    plt.close(fig)


def save_training_history(history: tf.keras.callbacks.History, output_path: Path) -> None:
    fig, axes = plt.subplots(1, 2, figsize=(12, 4))
    axes[0].plot(history.history.get("loss", []), label="train")
    if "val_loss" in history.history:
        axes[0].plot(history.history["val_loss"], label="val")
    axes[0].set_title("Loss")
    axes[0].legend()

    axes[1].plot(history.history.get("accuracy", []), label="train")
    if "val_accuracy" in history.history:
        axes[1].plot(history.history["val_accuracy"], label="val")
    axes[1].set_title("Accuracy")
    axes[1].legend()
    fig.tight_layout()
    fig.savefig(output_path, dpi=160)
    plt.close(fig)


def export_tflite(model: tf.keras.Model, output_path: Path) -> None:
    saved_model_dir = Path(tempfile.mkdtemp(prefix="magicdrive_savedmodel_"))
    try:
        model.export(saved_model_dir)
        converter = tf.lite.TFLiteConverter.from_saved_model(str(saved_model_dir))
        converter.experimental_enable_resource_variables = True
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        tflite_model = converter.convert()
    except Exception as error:  # noqa: BLE001
        print(
            f"Conversion optimizada fallo, reintentando sin optimizacion desde SavedModel: {error}"
        )
        converter = tf.lite.TFLiteConverter.from_saved_model(str(saved_model_dir))
        converter.experimental_enable_resource_variables = True
        tflite_model = converter.convert()
    finally:
        shutil.rmtree(saved_model_dir, ignore_errors=True)

    output_path.write_bytes(tflite_model)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Entrena MLP optimizado y exporta TFLite.")
    parser.add_argument(
        "--csv",
        type=Path,
        default=FEATURES_DIR / "fold5_features.csv",
        help="CSV generado por extract_features.py.",
    )
    parser.add_argument("--epochs", type=int, default=500)
    parser.add_argument("--batch_size", type=int, default=32)
    parser.add_argument("--learning_rate", type=float, default=0.00025)
    parser.add_argument("--patience", type=int, default=70)
    parser.add_argument("--val_size", type=float, default=0.15)
    parser.add_argument("--min_final_epochs", type=int, default=100)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    train(
        csv_path=args.csv,
        epochs=max(1, args.epochs),
        batch_size=max(1, args.batch_size),
        learning_rate=args.learning_rate,
        patience=max(1, args.patience),
        val_size=max(0.0, min(0.5, args.val_size)),
        min_final_epochs=max(1, args.min_final_epochs),
    )


if __name__ == "__main__":
    main()
