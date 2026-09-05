import argparse
from pathlib import Path

import cv2
import pandas as pd

from config import CLASS_NAMES, RAW_FOLD5_DIR, REPORTS_DIR, ensure_project_dirs
from dataset_utils import (
    find_video_files,
    infer_raw_label,
    model_label_from_raw,
    source_path_text,
    video_id_for_path,
)


def inspect_video(video_path: Path, input_dir: Path) -> dict[str, object]:
    raw_label = infer_raw_label(video_path, input_dir)
    label = model_label_from_raw(raw_label)

    capture = cv2.VideoCapture(str(video_path))
    opened = capture.isOpened()
    fps = float(capture.get(cv2.CAP_PROP_FPS) or 0.0) if opened else 0.0
    frame_count = int(capture.get(cv2.CAP_PROP_FRAME_COUNT) or 0) if opened else 0
    width = int(capture.get(cv2.CAP_PROP_FRAME_WIDTH) or 0) if opened else 0
    height = int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT) or 0) if opened else 0
    duration_seconds = frame_count / fps if fps > 0 else float("nan")
    capture.release()

    return {
        "video_id": video_id_for_path(video_path, input_dir),
        "source_path": source_path_text(video_path, input_dir),
        "absolute_path": str(video_path.resolve()),
        "inferred_raw_label": raw_label,
        "label": label,
        "class_name": CLASS_NAMES.get(label, "sin_etiqueta"),
        "opened": opened,
        "duration_seconds": duration_seconds,
        "fps": fps,
        "frame_count": frame_count,
        "width": width,
        "height": height,
    }


def run(input_dir: Path) -> tuple[pd.DataFrame, pd.DataFrame]:
    ensure_project_dirs()
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)

    videos = find_video_files(input_dir)
    rows = [inspect_video(video_path, input_dir) for video_path in videos]
    report_df = pd.DataFrame(rows)

    if report_df.empty:
        report_df = pd.DataFrame(
            columns=[
                "video_id",
                "source_path",
                "absolute_path",
                "inferred_raw_label",
                "label",
                "class_name",
                "opened",
                "duration_seconds",
                "fps",
                "frame_count",
                "width",
                "height",
            ]
        )

    unlabeled_df = report_df[report_df["label"].isna()].copy()

    report_path = REPORTS_DIR / "dataset_inspection.csv"
    unlabeled_path = REPORTS_DIR / "unlabeled_videos.csv"
    report_df.to_csv(report_path, index=False)
    unlabeled_df.to_csv(unlabeled_path, index=False)

    print("\n=== Inspeccion UTA-RLDD Fold5 ===")
    print(f"Carpeta inspeccionada: {input_dir}")
    print(f"Videos encontrados: {len(report_df)}")

    labeled_df = report_df.dropna(subset=["label"]).copy()
    if labeled_df.empty:
        print("No pude inferir etiquetas. Revisa nombres de carpetas/archivos.")
    else:
        counts = labeled_df["label"].astype(int).value_counts().sort_index()
        print("\nConteo por clase:")
        for label, count in counts.items():
            print(f"  {label} - {CLASS_NAMES.get(int(label), 'desconocida')}: {count}")

    if not unlabeled_df.empty:
        print(f"\nVideos sin etiqueta inferida: {len(unlabeled_df)}")
        print(f"Reporte: {unlabeled_path}")

    print(f"\nReporte completo: {report_path}")
    return report_df, unlabeled_df


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Inspecciona videos UTA-RLDD Fold5 y genera reportes CSV."
    )
    parser.add_argument(
        "--input",
        type=Path,
        default=RAW_FOLD5_DIR,
        help="Carpeta donde esta descomprimido Fold5.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    run(args.input)


if __name__ == "__main__":
    main()
