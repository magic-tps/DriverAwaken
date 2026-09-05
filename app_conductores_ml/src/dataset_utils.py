import hashlib
import re
from pathlib import Path
from typing import Iterable

from config import RAW_LABEL_TO_MODEL_LABEL, VIDEO_EXTENSIONS


def find_video_files(input_dir: Path) -> list[Path]:
    input_dir = Path(input_dir)
    if not input_dir.exists():
        return []

    return sorted(
        path
        for path in input_dir.rglob("*")
        if path.is_file() and path.suffix.lower() in VIDEO_EXTENSIONS
    )


def infer_raw_label(video_path: Path, input_dir: Path | None = None) -> int | None:
    """Infer UTA-RLDD raw labels 0, 5 or 10 from folders or file names."""
    labels = set(RAW_LABEL_TO_MODEL_LABEL.keys())
    parts = _relative_parts(video_path, input_dir)

    for part in reversed(parts[:-1]):
        cleaned = part.strip().lower()
        if cleaned in {"0", "5", "10"}:
            return int(cleaned)

    stem = video_path.stem.strip().lower()
    tokens = [token for token in re.split(r"[^0-9]+", stem) if token]
    for token in reversed(tokens):
        if token in {"0", "5", "10"} and int(token) in labels:
            return int(token)

    return None


def model_label_from_raw(raw_label: int | None) -> int | None:
    if raw_label is None:
        return None
    return RAW_LABEL_TO_MODEL_LABEL.get(raw_label)


def video_id_for_path(video_path: Path, input_dir: Path | None = None) -> str:
    parts = _relative_parts(video_path, input_dir)
    relative_text = "/".join(parts)
    slug = re.sub(r"[^a-zA-Z0-9]+", "_", Path(*parts).with_suffix("").as_posix())
    slug = slug.strip("_").lower() or video_path.stem.lower()
    digest = hashlib.sha1(relative_text.encode("utf-8")).hexdigest()[:8]
    return f"{slug}_{digest}"


def source_path_text(video_path: Path, input_dir: Path | None = None) -> str:
    try:
        if input_dir is not None:
            return video_path.resolve().relative_to(Path(input_dir).resolve()).as_posix()
    except ValueError:
        pass
    return video_path.as_posix()


def labeled_videos(input_dir: Path) -> list[dict[str, object]]:
    records: list[dict[str, object]] = []
    for video_path in find_video_files(input_dir):
        raw_label = infer_raw_label(video_path, input_dir)
        label = model_label_from_raw(raw_label)
        if label is None:
            continue
        records.append(
            {
                "path": video_path,
                "raw_label": raw_label,
                "label": label,
                "video_id": video_id_for_path(video_path, input_dir),
                "source_path": source_path_text(video_path, input_dir),
            }
        )
    return records


def _relative_parts(video_path: Path, input_dir: Path | None) -> tuple[str, ...]:
    try:
        if input_dir is not None:
            return video_path.resolve().relative_to(Path(input_dir).resolve()).parts
    except ValueError:
        pass
    return video_path.parts


def count_by_label(labels: Iterable[int]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for label in labels:
        key = str(int(label))
        counts[key] = counts.get(key, 0) + 1
    return counts
