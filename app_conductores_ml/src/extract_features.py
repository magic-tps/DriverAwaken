import argparse
import json
import math
import os
from collections import Counter
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path

os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")

import cv2
import mediapipe as mp
import numpy as np
import pandas as pd
from tqdm import tqdm

from config import (
    EAR_CLOSED_THRESHOLD,
    EXTRACTION_WORKERS,
    FEATURES_DIR,
    MAR_YAWN_THRESHOLD,
    MAX_FRAME_WIDTH,
    RAW_FOLD5_DIR,
    REPORTS_DIR,
    SAMPLE_FPS,
    WINDOW_FEATURE_COLUMNS,
    WINDOW_SECONDS,
    ensure_project_dirs,
)
from dataset_utils import labeled_videos
from landmark_utils import (
    LEFT_EYE,
    RIGHT_EYE,
    calculate_ear,
    calculate_mar,
    calculate_pitch_proxy,
    calculate_yaw_proxy,
    nanmean,
)


def process_frame(
    face_mesh: object,
    frame: np.ndarray,
    max_frame_width: int,
    ear_closed_threshold: float,
    mar_yawn_threshold: float,
) -> dict[str, object]:
    frame_for_mesh = resize_for_mesh(frame, max_frame_width)
    rgb_frame = cv2.cvtColor(frame_for_mesh, cv2.COLOR_BGR2RGB)
    rgb_frame.flags.writeable = False
    results = face_mesh.process(rgb_frame)

    if not results.multi_face_landmarks:
        return {
            "face_detected": 0,
            "ear_left": math.nan,
            "ear_right": math.nan,
            "ear_mean": math.nan,
            "mar": math.nan,
            "yaw_proxy": math.nan,
            "pitch_proxy": math.nan,
            "eyes_closed": 0,
            "yawning": 0,
        }

    landmarks = results.multi_face_landmarks[0].landmark
    ear_left = calculate_ear(landmarks, LEFT_EYE)
    ear_right = calculate_ear(landmarks, RIGHT_EYE)
    ear_mean = nanmean([ear_left, ear_right])
    mar = calculate_mar(landmarks)
    yaw_proxy = calculate_yaw_proxy(landmarks)
    pitch_proxy = calculate_pitch_proxy(landmarks)

    return {
        "face_detected": 1,
        "ear_left": ear_left,
        "ear_right": ear_right,
        "ear_mean": ear_mean,
        "mar": mar,
        "yaw_proxy": yaw_proxy,
        "pitch_proxy": pitch_proxy,
        "eyes_closed": int(not math.isnan(ear_mean) and ear_mean < ear_closed_threshold),
        "yawning": int(not math.isnan(mar) and mar > mar_yawn_threshold),
    }


def process_video(
    video_record: dict[str, object],
    face_mesh: object,
    sample_fps: float,
    window_seconds: int,
    max_frame_width: int,
    ear_closed_threshold: float,
    mar_yawn_threshold: float,
    sampling_mode: str,
) -> tuple[list[dict[str, object]], dict[str, object]]:
    video_path = Path(video_record["path"])
    capture = cv2.VideoCapture(str(video_path))
    if not capture.isOpened():
        raise RuntimeError("No se pudo abrir el video con OpenCV.")

    fps = float(capture.get(cv2.CAP_PROP_FPS) or 0.0)
    if fps <= 0:
        fps = 30.0

    sampled_frames = 0
    windows: dict[int, list[dict[str, object]]] = {}

    for _, timestamp, frame in iter_sampled_frames(capture, fps, sample_fps, sampling_mode):
        window_id = int(timestamp // window_seconds)
        features = process_frame(
            face_mesh,
            frame,
            max_frame_width,
            ear_closed_threshold,
            mar_yawn_threshold,
        )
        features["timestamp"] = timestamp
        windows.setdefault(window_id, []).append(features)
        sampled_frames += 1

    capture.release()

    rows = [
        summarize_window(
            video_record=video_record,
            window_id=window_id,
            records=records,
            window_seconds=window_seconds,
            sample_fps=sample_fps,
        )
        for window_id, records in sorted(windows.items())
    ]

    face_detected_count = sum(
        int(record["face_detected"]) for records in windows.values() for record in records
    )
    no_face_ratio = 1.0 - (face_detected_count / sampled_frames) if sampled_frames else math.nan

    summary = {
        "video_id": video_record["video_id"],
        "source_path": video_record["source_path"],
        "sampled_frames": sampled_frames,
        "windows_generated": len(rows),
        "no_face_ratio": no_face_ratio,
    }
    return rows, summary


def process_video_worker(
    payload: dict[str, object],
) -> tuple[list[dict[str, object]], dict[str, object]]:
    video_record = payload["video_record"]
    sample_fps = float(payload["sample_fps"])
    window_seconds = int(payload["window_seconds"])
    max_frame_width = int(payload["max_frame_width"])
    ear_closed_threshold = float(payload["ear_closed_threshold"])
    mar_yawn_threshold = float(payload["mar_yawn_threshold"])
    sampling_mode = str(payload["sampling_mode"])

    mp_face_mesh = mp.solutions.face_mesh
    with mp_face_mesh.FaceMesh(
        static_image_mode=False,
        max_num_faces=1,
        refine_landmarks=True,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5,
    ) as face_mesh:
        return process_video(
            video_record=video_record,
            face_mesh=face_mesh,
            sample_fps=sample_fps,
            window_seconds=window_seconds,
            max_frame_width=max_frame_width,
            ear_closed_threshold=ear_closed_threshold,
            mar_yawn_threshold=mar_yawn_threshold,
            sampling_mode=sampling_mode,
        )


def summarize_window(
    video_record: dict[str, object],
    window_id: int,
    records: list[dict[str, object]],
    window_seconds: int,
    sample_fps: float,
) -> dict[str, object]:
    total_frame_count = len(records)
    valid_records = [record for record in records if int(record["face_detected"]) == 1]
    valid_frame_count = len(valid_records)
    face_ratio = valid_frame_count / total_frame_count if total_frame_count else 0.0
    no_face_ratio = 1.0 - face_ratio

    ears = _numeric_values(valid_records, "ear_mean")
    mars = _numeric_values(valid_records, "mar")
    yaw_values = _numeric_values(valid_records, "yaw_proxy")
    pitch_values = _numeric_values(valid_records, "pitch_proxy")
    closed_flags = [int(record["eyes_closed"]) for record in valid_records]
    yawn_flags = [int(record["yawning"]) for record in valid_records]

    perclos = sum(closed_flags) / valid_frame_count if valid_frame_count else math.nan
    yawn_ratio = sum(yawn_flags) / valid_frame_count if valid_frame_count else math.nan

    return {
        "video_id": video_record["video_id"],
        "source_path": video_record["source_path"],
        "window_id": window_id,
        "start_second": window_id * window_seconds,
        "end_second": (window_id + 1) * window_seconds,
        "label": int(video_record["label"]),
        "face_ratio": face_ratio,
        "no_face_ratio": no_face_ratio,
        "ear_mean": _stat(ears, "mean"),
        "ear_min": _stat(ears, "min"),
        "ear_max": _stat(ears, "max"),
        "ear_std": _stat(ears, "std"),
        "mar_mean": _stat(mars, "mean"),
        "mar_max": _stat(mars, "max"),
        "mar_std": _stat(mars, "std"),
        "perclos": perclos,
        "blink_count": _count_true_runs(closed_flags),
        "max_eye_closed_duration": _max_true_run_duration(closed_flags, sample_fps),
        "yawn_count": _count_true_runs(yawn_flags),
        "yawn_ratio": yawn_ratio,
        "yaw_proxy_mean": _stat(yaw_values, "mean"),
        "yaw_proxy_max_abs": _max_abs(yaw_values),
        "pitch_proxy_mean": _stat(pitch_values, "mean"),
        "pitch_proxy_max": _stat(pitch_values, "max"),
        "valid_frame_count": valid_frame_count,
        "total_frame_count": total_frame_count,
    }


def extract_features(
    input_dir: Path,
    output_path: Path,
    sample_fps: float,
    window_seconds: int,
    max_frame_width: int,
    workers: int,
    ear_closed_threshold: float,
    mar_yawn_threshold: float,
    sampling_mode: str,
) -> pd.DataFrame:
    ensure_project_dirs()
    output_path.parent.mkdir(parents=True, exist_ok=True)
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)

    videos = labeled_videos(input_dir)
    print(f"Videos etiquetados encontrados: {len(videos)}")
    if not videos:
        print("No hay videos etiquetados. Ejecuta inspect_dataset.py para revisar el parser.")

    all_rows: list[dict[str, object]] = []
    videos_failed: list[dict[str, str]] = []
    no_face_high: list[dict[str, object]] = []

    if workers > 1 and len(videos) > 1:
        payloads = [
            {
                "video_record": video_record,
                "sample_fps": sample_fps,
                "window_seconds": window_seconds,
                "max_frame_width": max_frame_width,
                "ear_closed_threshold": ear_closed_threshold,
                "mar_yawn_threshold": mar_yawn_threshold,
                "sampling_mode": sampling_mode,
            }
            for video_record in videos
        ]
        with ProcessPoolExecutor(max_workers=workers) as executor:
            future_to_video = {
                executor.submit(process_video_worker, payload): payload["video_record"]
                for payload in payloads
            }
            for future in tqdm(
                as_completed(future_to_video),
                total=len(future_to_video),
                desc="Extrayendo features",
            ):
                video_record = future_to_video[future]
                try:
                    rows, video_summary = future.result()
                    all_rows.extend(rows)
                    no_face_ratio = float(video_summary["no_face_ratio"])
                    if not math.isnan(no_face_ratio) and no_face_ratio > 0.80:
                        no_face_high.append(video_summary)
                except Exception as error:  # noqa: BLE001 - continue with next video
                    videos_failed.append(
                        {
                            "video_id": str(video_record["video_id"]),
                            "source_path": str(video_record["source_path"]),
                            "error": str(error),
                        }
                    )
    else:
        mp_face_mesh = mp.solutions.face_mesh
        with mp_face_mesh.FaceMesh(
            static_image_mode=False,
            max_num_faces=1,
            refine_landmarks=True,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5,
        ) as face_mesh:
            iterator = tqdm(videos, desc="Extrayendo features")
            for video_record in iterator:
                try:
                    rows, video_summary = process_video(
                        video_record=video_record,
                        face_mesh=face_mesh,
                        sample_fps=sample_fps,
                        window_seconds=window_seconds,
                        max_frame_width=max_frame_width,
                        ear_closed_threshold=ear_closed_threshold,
                        mar_yawn_threshold=mar_yawn_threshold,
                        sampling_mode=sampling_mode,
                    )
                    all_rows.extend(rows)
                    no_face_ratio = float(video_summary["no_face_ratio"])
                    if not math.isnan(no_face_ratio) and no_face_ratio > 0.80:
                        no_face_high.append(video_summary)
                except Exception as error:  # noqa: BLE001 - continue with next video
                    videos_failed.append(
                        {
                            "video_id": str(video_record["video_id"]),
                            "source_path": str(video_record["source_path"]),
                            "error": str(error),
                        }
                    )

    all_rows.sort(key=lambda row: (str(row["video_id"]), int(row["window_id"])))

    features_df = pd.DataFrame(all_rows, columns=WINDOW_FEATURE_COLUMNS)
    features_df.to_csv(output_path, index=False)

    windows_by_label = Counter(str(int(label)) for label in features_df["label"].dropna().tolist())
    summary = {
        "total_videos_processed": len(videos) - len(videos_failed),
        "total_windows_generated": int(len(features_df)),
        "windows_by_label": dict(sorted(windows_by_label.items())),
        "sample_fps": float(sample_fps),
        "window_seconds": int(window_seconds),
        "max_frame_width": int(max_frame_width),
        "ear_closed_threshold": float(ear_closed_threshold),
        "mar_yawn_threshold": float(mar_yawn_threshold),
        "sampling_mode": sampling_mode,
        "videos_failed": videos_failed,
        "videos_without_face_ratio_high": no_face_high,
    }
    summary_path = REPORTS_DIR / "feature_extraction_summary.json"
    summary_path.write_text(json.dumps(summary, indent=2), encoding="utf-8")

    print(f"\nFeatures guardadas en: {output_path}")
    print(f"Resumen guardado en: {summary_path}")
    if videos_failed:
        print(f"Videos fallidos: {len(videos_failed)}")

    return features_df


def _numeric_values(records: list[dict[str, object]], key: str) -> list[float]:
    values: list[float] = []
    for record in records:
        value = float(record.get(key, math.nan))
        if not math.isnan(value):
            values.append(value)
    return values


def _stat(values: list[float], name: str) -> float:
    if not values:
        return math.nan
    array = np.asarray(values, dtype=float)
    if name == "mean":
        return float(np.mean(array))
    if name == "min":
        return float(np.min(array))
    if name == "max":
        return float(np.max(array))
    if name == "std":
        return float(np.std(array))
    raise ValueError(f"Estadistica no soportada: {name}")


def _max_abs(values: list[float]) -> float:
    if not values:
        return math.nan
    return float(np.max(np.abs(np.asarray(values, dtype=float))))


def _count_true_runs(flags: list[int]) -> int:
    count = 0
    previous = 0
    for flag in flags:
        if flag and not previous:
            count += 1
        previous = flag
    return count


def _max_true_run_duration(flags: list[int], sample_fps: float) -> float:
    max_run = 0
    current_run = 0
    for flag in flags:
        if flag:
            current_run += 1
            max_run = max(max_run, current_run)
        else:
            current_run = 0
    return float(max_run / sample_fps) if sample_fps > 0 else 0.0


def resize_for_mesh(frame: np.ndarray, max_frame_width: int) -> np.ndarray:
    if max_frame_width <= 0:
        return frame

    height, width = frame.shape[:2]
    if width <= max_frame_width:
        return frame

    scale = max_frame_width / width
    target_size = (max_frame_width, max(1, int(round(height * scale))))
    return cv2.resize(frame, target_size, interpolation=cv2.INTER_AREA)


def iter_sampled_frames(
    capture: cv2.VideoCapture,
    fps: float,
    sample_fps: float,
    sampling_mode: str,
) -> object:
    if sampling_mode == "seek":
        yielded_any = False
        total_frames = int(capture.get(cv2.CAP_PROP_FRAME_COUNT) or 0)
        if total_frames > 0:
            step = max(1.0, fps / sample_fps)
            target = 0.0
            previous_frame_index = -1
            while target < total_frames:
                frame_index = int(round(target))
                if frame_index <= previous_frame_index:
                    frame_index = previous_frame_index + 1
                if frame_index >= total_frames:
                    break

                capture.set(cv2.CAP_PROP_POS_FRAMES, frame_index)
                retrieved, frame = capture.read()
                if retrieved and frame is not None:
                    yielded_any = True
                    yield frame_index, frame_index / fps, frame

                previous_frame_index = frame_index
                target += step

        if yielded_any:
            return

        capture.set(cv2.CAP_PROP_POS_FRAMES, 0)

    sample_interval = max(1, int(round(fps / sample_fps)))
    frame_index = 0
    while True:
        grabbed = capture.grab()
        if not grabbed:
            break

        if frame_index % sample_interval == 0:
            retrieved, frame = capture.retrieve()
            if retrieved and frame is not None:
                yield frame_index, frame_index / fps, frame

        frame_index += 1


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Extrae features tabulares desde videos usando MediaPipe FaceMesh."
    )
    parser.add_argument("--input", type=Path, default=RAW_FOLD5_DIR)
    parser.add_argument(
        "--output",
        type=Path,
        default=FEATURES_DIR / "fold5_features.csv",
    )
    parser.add_argument("--sample_fps", type=float, default=SAMPLE_FPS)
    parser.add_argument("--window_seconds", type=int, default=WINDOW_SECONDS)
    parser.add_argument(
        "--max_frame_width",
        type=int,
        default=MAX_FRAME_WIDTH,
        help="Ancho maximo del frame antes de FaceMesh. Usa 0 para desactivar.",
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=EXTRACTION_WORKERS,
        help="Procesos paralelos por video. Usa 1 para modo secuencial.",
    )
    parser.add_argument(
        "--ear_threshold",
        type=float,
        default=EAR_CLOSED_THRESHOLD,
        help="Umbral EAR para marcar ojos cerrados.",
    )
    parser.add_argument(
        "--mar_threshold",
        type=float,
        default=MAR_YAWN_THRESHOLD,
        help="Umbral MAR para marcar bostezo.",
    )
    parser.add_argument(
        "--sampling_mode",
        choices=["seek", "grab"],
        default="grab",
        help="seek salta a frames objetivo; grab recorre el video secuencialmente.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    extract_features(
        input_dir=args.input,
        output_path=args.output,
        sample_fps=args.sample_fps,
        window_seconds=args.window_seconds,
        max_frame_width=args.max_frame_width,
        workers=max(1, args.workers),
        ear_closed_threshold=args.ear_threshold,
        mar_yawn_threshold=args.mar_threshold,
        sampling_mode=args.sampling_mode,
    )


if __name__ == "__main__":
    main()
