import argparse
import json
import re
import warnings
from pathlib import Path

import numpy as np
import pandas as pd
from pandas.errors import PerformanceWarning

from config import (
    EAR_CLOSED_THRESHOLD,
    FEATURES_DIR,
    IDENTIFIER_COLUMNS,
    MAR_YAWN_THRESHOLD,
    REPORTS_DIR,
    WINDOW_SECONDS,
    ensure_project_dirs,
)

warnings.filterwarnings("ignore", category=PerformanceWarning)


ROLLING_WINDOWS = (3, 6, 12)
ROLLING_MEAN_COLUMNS = [
    "face_ratio",
    "no_face_ratio",
    "ear_mean",
    "ear_min",
    "ear_std",
    "mar_mean",
    "mar_max",
    "perclos",
    "max_eye_closed_duration",
    "yawn_ratio",
    "yaw_proxy_max_abs",
    "pitch_proxy_max",
]
ROLLING_SUM_COLUMNS = ["blink_count", "yawn_count"]
DIFF_COLUMNS = [
    "ear_mean",
    "ear_min",
    "mar_mean",
    "mar_max",
    "perclos",
    "yaw_proxy_mean",
    "pitch_proxy_mean",
]


def engineer_features(
    input_path: Path,
    output_path: Path,
    ear_threshold: float,
    mar_threshold: float,
    window_seconds: int,
) -> pd.DataFrame:
    ensure_project_dirs()
    output_path.parent.mkdir(parents=True, exist_ok=True)
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)

    if not input_path.exists():
        raise FileNotFoundError(f"No existe el CSV base: {input_path}")

    df = pd.read_csv(input_path)
    if df.empty:
        raise ValueError("El CSV base esta vacio.")

    missing = [column for column in IDENTIFIER_COLUMNS if column not in df.columns]
    if missing:
        raise ValueError(f"Faltan columnas identificadoras: {missing}")

    enhanced = df.copy()
    enhanced["subject_id"] = enhanced["source_path"].map(extract_subject_id)
    enhanced["fold_id"] = enhanced["source_path"].map(extract_fold_id)
    enhanced = enhanced.sort_values(["video_id", "window_id"]).reset_index(drop=True)

    add_static_features(enhanced, ear_threshold, mar_threshold, window_seconds)
    add_temporal_features(enhanced)

    feature_columns = [
        column
        for column in enhanced.columns
        if column not in set(IDENTIFIER_COLUMNS + ["subject_id", "fold_id"])
        and pd.api.types.is_numeric_dtype(enhanced[column])
    ]

    enhanced.to_csv(output_path, index=False)
    report = {
        "input": str(input_path),
        "output": str(output_path),
        "rows": int(len(enhanced)),
        "columns": int(len(enhanced.columns)),
        "feature_columns": feature_columns,
        "feature_count": int(len(feature_columns)),
        "ear_threshold": float(ear_threshold),
        "mar_threshold": float(mar_threshold),
        "window_seconds": int(window_seconds),
        "rolling_windows": list(ROLLING_WINDOWS),
        "label_distribution": {
            str(int(label)): int(count)
            for label, count in enhanced["label"].value_counts().sort_index().items()
        },
    }
    (REPORTS_DIR / "feature_engineering_summary.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )

    print("\n=== Feature engineering completo ===")
    print(f"Entrada: {input_path}")
    print(f"Salida: {output_path}")
    print(f"Filas: {len(enhanced)}")
    print(f"Features numericas: {len(feature_columns)}")
    print(f"Reporte: {REPORTS_DIR / 'feature_engineering_summary.json'}")
    return enhanced


def add_static_features(
    df: pd.DataFrame, ear_threshold: float, mar_threshold: float, window_seconds: int
) -> None:
    eps = 1e-6
    safe_total = df["total_frame_count"].replace(0, np.nan)
    safe_valid = df["valid_frame_count"].replace(0, np.nan)

    df["valid_frame_ratio"] = df["valid_frame_count"] / safe_total
    df["invalid_frame_count"] = df["total_frame_count"] - df["valid_frame_count"]
    df["ear_range"] = df["ear_max"] - df["ear_min"]
    df["ear_mean_to_min_gap"] = df["ear_mean"] - df["ear_min"]
    df["ear_closed_intensity_mean"] = (ear_threshold - df["ear_mean"]).clip(lower=0)
    df["ear_closed_intensity_min"] = (ear_threshold - df["ear_min"]).clip(lower=0)
    df["ear_stability_ratio"] = df["ear_std"] / (df["ear_mean"].abs() + eps)
    df["mar_open_intensity_mean"] = (df["mar_mean"] - mar_threshold).clip(lower=0)
    df["mar_open_intensity_max"] = (df["mar_max"] - mar_threshold).clip(lower=0)
    df["mar_activity_ratio"] = df["mar_std"] / (df["mar_mean"].abs() + eps)
    df["blink_rate"] = df["blink_count"] / max(1, window_seconds)
    df["yawn_rate"] = df["yawn_count"] / max(1, window_seconds)
    df["closed_duration_ratio"] = df["max_eye_closed_duration"] / max(1, window_seconds)
    df["closed_frames_estimated"] = df["perclos"] * safe_valid
    df["head_yaw_abs_mean_proxy"] = df["yaw_proxy_mean"].abs()
    df["head_pitch_abs_mean_proxy"] = df["pitch_proxy_mean"].abs()
    df["head_pose_intensity"] = df["yaw_proxy_max_abs"].abs() + df["pitch_proxy_max"].abs()
    df["fatigue_eye_score"] = (
        0.55 * df["perclos"]
        + 0.30 * df["closed_duration_ratio"]
        + 0.15 * df["ear_closed_intensity_min"]
    )
    df["fatigue_mouth_score"] = (
        0.70 * df["yawn_ratio"].fillna(0)
        + 0.20 * df["mar_open_intensity_max"].fillna(0)
        + 0.10 * df["yawn_rate"].fillna(0)
    )
    df["fatigue_pose_score"] = 0.60 * df["head_pose_intensity"].fillna(0) + 0.40 * df[
        "no_face_ratio"
    ].fillna(0)
    df["fatigue_combined_score"] = (
        0.55 * df["fatigue_eye_score"].fillna(0)
        + 0.25 * df["fatigue_mouth_score"].fillna(0)
        + 0.20 * df["fatigue_pose_score"].fillna(0)
    )
    df["perclos_x_yawn_ratio"] = df["perclos"] * df["yawn_ratio"]
    df["perclos_x_closed_duration"] = df["perclos"] * df["max_eye_closed_duration"]
    df["perclos_x_head_pose"] = df["perclos"] * df["head_pose_intensity"]
    df["mar_x_head_pose"] = df["mar_max"] * df["head_pose_intensity"]
    df["blink_per_valid_frame"] = df["blink_count"] / safe_valid
    df["yawn_per_valid_frame"] = df["yawn_count"] / safe_valid


def add_temporal_features(df: pd.DataFrame) -> None:
    grouped = df.groupby("video_id", group_keys=False)

    for column in DIFF_COLUMNS:
        if column in df.columns:
            df[f"{column}_diff1"] = grouped[column].diff().fillna(0.0)
            df[f"{column}_abs_diff1"] = df[f"{column}_diff1"].abs()

    for window_size in ROLLING_WINDOWS:
        for column in ROLLING_MEAN_COLUMNS:
            if column in df.columns:
                rolling = grouped[column].rolling(window=window_size, min_periods=1)
                df[f"{column}_roll{window_size}_mean"] = rolling.mean().reset_index(
                    level=0, drop=True
                )
                df[f"{column}_roll{window_size}_max"] = rolling.max().reset_index(
                    level=0, drop=True
                )
                df[f"{column}_roll{window_size}_min"] = rolling.min().reset_index(
                    level=0, drop=True
                )

        for column in ROLLING_SUM_COLUMNS:
            if column in df.columns:
                rolling = grouped[column].rolling(window=window_size, min_periods=1)
                df[f"{column}_roll{window_size}_sum"] = rolling.sum().reset_index(
                    level=0, drop=True
                )

    df["perclos_minus_roll3"] = df["perclos"] - df.get("perclos_roll3_mean", df["perclos"])
    df["perclos_minus_roll6"] = df["perclos"] - df.get("perclos_roll6_mean", df["perclos"])
    df["ear_mean_minus_roll3"] = df["ear_mean"] - df.get("ear_mean_roll3_mean", df["ear_mean"])
    df["mar_max_minus_roll3"] = df["mar_max"] - df.get("mar_max_roll3_mean", df["mar_max"])
    df["fatigue_accumulation_3"] = (
        df.get("perclos_roll3_mean", df["perclos"]).fillna(0)
        + df.get("closed_duration_ratio", 0)
        + df.get("yawn_ratio_roll3_mean", df["yawn_ratio"]).fillna(0)
    )
    df["fatigue_accumulation_6"] = (
        df.get("perclos_roll6_mean", df["perclos"]).fillna(0)
        + df.get("max_eye_closed_duration_roll6_max", df["max_eye_closed_duration"]).fillna(0)
        / 10.0
        + df.get("yawn_count_roll6_sum", df["yawn_count"]).fillna(0) / 6.0
    )


def extract_subject_id(source_path: object) -> str:
    text = str(source_path)
    parts = re.split(r"[\\/]+", text)
    for part in reversed(parts[:-1]):
        if re.fullmatch(r"\d{1,3}", part):
            return part.zfill(3)
    match = re.search(r"(?:subject|driver|user)[_\- ]?(\d{1,3})", text, flags=re.IGNORECASE)
    if match:
        return match.group(1).zfill(3)
    return "unknown"


def extract_fold_id(source_path: object) -> str:
    text = str(source_path)
    match = re.search(r"fold\s*([0-9]+)", text, flags=re.IGNORECASE)
    if match:
        return match.group(1)
    return "unknown"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Crea un CSV enriquecido desde features base.")
    parser.add_argument(
        "--input",
        type=Path,
        default=FEATURES_DIR / "fold5_features.csv",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=FEATURES_DIR / "fold5_features_enhanced.csv",
    )
    parser.add_argument("--ear_threshold", type=float, default=EAR_CLOSED_THRESHOLD)
    parser.add_argument("--mar_threshold", type=float, default=MAR_YAWN_THRESHOLD)
    parser.add_argument("--window_seconds", type=int, default=WINDOW_SECONDS)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    engineer_features(
        input_path=args.input,
        output_path=args.output,
        ear_threshold=args.ear_threshold,
        mar_threshold=args.mar_threshold,
        window_seconds=args.window_seconds,
    )


if __name__ == "__main__":
    main()
