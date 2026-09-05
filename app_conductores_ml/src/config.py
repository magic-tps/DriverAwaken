from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[1]

DATA_DIR = BASE_DIR / "data"
RAW_DATA_DIR = DATA_DIR / "raw"
RAW_FOLD5_DIR = RAW_DATA_DIR / "uta_rldd" / "fold5"
PROCESSED_DATA_DIR = DATA_DIR / "processed"
FEATURES_DIR = DATA_DIR / "features"

MODELS_DIR = BASE_DIR / "models"
REPORTS_DIR = BASE_DIR / "reports"
NOTEBOOKS_DIR = BASE_DIR / "notebooks"
FLUTTER_ASSETS_DIR = BASE_DIR / "flutter_assets"

VIDEO_EXTENSIONS = (".mp4", ".avi", ".mov", ".mkv")

EAR_CLOSED_THRESHOLD = 0.16
MAR_YAWN_THRESHOLD = 0.55
SAMPLE_FPS = 5
WINDOW_SECONDS = 10
MAX_FRAME_WIDTH = 640
EXTRACTION_WORKERS = 6

RAW_LABEL_TO_MODEL_LABEL = {
    0: 0,
    5: 1,
    10: 2,
}

CLASS_NAMES = {
    0: "despierto",
    1: "cansancio",
    2: "somnoliento",
}

IDENTIFIER_COLUMNS = [
    "video_id",
    "source_path",
    "window_id",
    "start_second",
    "end_second",
    "label",
]

FEATURE_COLUMNS = [
    "face_ratio",
    "no_face_ratio",
    "ear_mean",
    "ear_min",
    "ear_max",
    "ear_std",
    "mar_mean",
    "mar_max",
    "mar_std",
    "perclos",
    "blink_count",
    "max_eye_closed_duration",
    "yawn_count",
    "yawn_ratio",
    "yaw_proxy_mean",
    "yaw_proxy_max_abs",
    "pitch_proxy_mean",
    "pitch_proxy_max",
    "valid_frame_count",
    "total_frame_count",
]

WINDOW_FEATURE_COLUMNS = IDENTIFIER_COLUMNS + FEATURE_COLUMNS

NON_FEATURE_COLUMNS = IDENTIFIER_COLUMNS + [
    "raw_label",
    "class_name",
    "subject_id",
    "fold_id",
]


def infer_feature_columns(columns: list[str]) -> list[str]:
    return [
        column
        for column in columns
        if column not in NON_FEATURE_COLUMNS
        and not column.endswith("_id")
        and column != "source_path"
    ]


def ensure_project_dirs() -> None:
    for path in [
        RAW_FOLD5_DIR,
        PROCESSED_DATA_DIR,
        FEATURES_DIR,
        MODELS_DIR,
        REPORTS_DIR,
        NOTEBOOKS_DIR,
    ]:
        path.mkdir(parents=True, exist_ok=True)
