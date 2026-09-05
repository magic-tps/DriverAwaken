import argparse
from pathlib import Path

import joblib
import pandas as pd

from config import CLASS_NAMES, FEATURE_COLUMNS, FEATURES_DIR, MODELS_DIR


def load_model(model_path: Path) -> tuple[object, list[str], dict[int, str]]:
    artifact = joblib.load(model_path)
    if isinstance(artifact, dict) and "pipeline" in artifact:
        pipeline = artifact["pipeline"]
        feature_columns = list(artifact.get("feature_columns", FEATURE_COLUMNS))
        class_names = {
            int(key): value for key, value in artifact.get("class_names", CLASS_NAMES).items()
        }
        return pipeline, feature_columns, class_names
    return artifact, FEATURE_COLUMNS, CLASS_NAMES


def select_row(df: pd.DataFrame, row: int | None, video_id: str | None) -> pd.Series:
    if video_id:
        matches = df[df["video_id"].astype(str) == video_id]
        if matches.empty:
            raise ValueError(f"No se encontro video_id en el CSV: {video_id}")
        return matches.iloc[0]

    row_index = 0 if row is None else row
    if row_index < 0 or row_index >= len(df):
        raise IndexError(f"Fila fuera de rango: {row_index}. El CSV tiene {len(df)} filas.")
    return df.iloc[row_index]


def predict(csv_path: Path, model_path: Path, row: int | None, video_id: str | None) -> None:
    if not csv_path.exists():
        raise FileNotFoundError(f"No existe el CSV: {csv_path}")
    if not model_path.exists():
        raise FileNotFoundError(f"No existe el modelo: {model_path}")

    df = pd.read_csv(csv_path)
    selected = select_row(df, row, video_id)
    model, feature_columns, class_names = load_model(model_path)

    x = pd.DataFrame([selected[feature_columns]], columns=feature_columns)
    x = x.apply(pd.to_numeric, errors="coerce")
    predicted_label = int(model.predict(x)[0])
    probabilities = model.predict_proba(x)[0] if hasattr(model, "predict_proba") else None

    print("\n=== Prediccion de muestra ===")
    print(f"CSV: {csv_path}")
    print(f"Modelo: {model_path}")
    print(f"video_id: {selected.get('video_id', '')}")
    print(f"window_id: {selected.get('window_id', '')}")
    print(f"label real: {selected.get('label', 'desconocido')}")
    print(f"prediccion: {predicted_label} - {class_names.get(predicted_label, 'desconocida')}")

    if probabilities is not None:
        print("\nProbabilidades:")
        for index, probability in enumerate(probabilities):
            print(f"  {index} - {class_names.get(index, 'desconocida')}: {probability:.4f}")

    print("\nFeatures usadas:")
    for column in feature_columns:
        print(f"  {column}: {x.iloc[0][column]}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Prueba un modelo Random Forest entrenado.")
    parser.add_argument("--csv", type=Path, default=FEATURES_DIR / "fold5_features.csv")
    parser.add_argument(
        "--model",
        type=Path,
        default=MODELS_DIR / "drowsiness_random_forest.joblib",
    )
    parser.add_argument("--row", type=int, default=0)
    parser.add_argument("--video_id", type=str, default=None)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    predict(
        csv_path=args.csv,
        model_path=args.model,
        row=args.row,
        video_id=args.video_id,
    )


if __name__ == "__main__":
    main()
