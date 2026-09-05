import math
from typing import Sequence

import numpy as np

LEFT_EYE = [33, 160, 158, 133, 153, 144]
RIGHT_EYE = [362, 385, 387, 263, 373, 380]

MOUTH_LEFT = 61
MOUTH_RIGHT = 291
MOUTH_UPPER = 13
MOUTH_LOWER = 14

NOSE_TIP = 1
CHIN = 152
FACE_LEFT = 234
FACE_RIGHT = 454


def safe_float(value: float | int | None, default: float = math.nan) -> float:
    if value is None:
        return default
    try:
        number = float(value)
    except (TypeError, ValueError):
        return default
    if math.isfinite(number):
        return number
    return default


def nanmean(values: Sequence[float]) -> float:
    array = np.asarray(values, dtype=float)
    if array.size == 0 or np.all(np.isnan(array)):
        return math.nan
    return float(np.nanmean(array))


def euclidean_distance(point_a: object, point_b: object) -> float:
    ax, ay = _xy(point_a)
    bx, by = _xy(point_b)
    if any(math.isnan(value) for value in [ax, ay, bx, by]):
        return math.nan
    return math.sqrt((ax - bx) ** 2 + (ay - by) ** 2)


def calculate_ear(landmarks: Sequence[object], eye_indices: Sequence[int]) -> float:
    """Eye aspect ratio with six FaceMesh eye landmarks."""
    try:
        p1, p2, p3, p4, p5, p6 = [landmarks[index] for index in eye_indices]
    except (IndexError, TypeError):
        return math.nan

    horizontal = euclidean_distance(p1, p4)
    vertical_1 = euclidean_distance(p2, p6)
    vertical_2 = euclidean_distance(p3, p5)

    if not horizontal or math.isnan(horizontal):
        return math.nan
    return safe_float((vertical_1 + vertical_2) / (2.0 * horizontal))


def calculate_mar(landmarks: Sequence[object]) -> float:
    """Mouth aspect ratio using left, right, upper and lower lip landmarks."""
    try:
        left = landmarks[MOUTH_LEFT]
        right = landmarks[MOUTH_RIGHT]
        upper = landmarks[MOUTH_UPPER]
        lower = landmarks[MOUTH_LOWER]
    except (IndexError, TypeError):
        return math.nan

    width = euclidean_distance(left, right)
    height = euclidean_distance(upper, lower)
    if not width or math.isnan(width):
        return math.nan
    return safe_float(height / width)


def calculate_yaw_proxy(landmarks: Sequence[object]) -> float:
    """Horizontal nose displacement normalized by face width."""
    try:
        nose = landmarks[NOSE_TIP]
        left = landmarks[FACE_LEFT]
        right = landmarks[FACE_RIGHT]
    except (IndexError, TypeError):
        return math.nan

    face_width = euclidean_distance(left, right)
    if not face_width or math.isnan(face_width):
        return math.nan

    nose_x, _ = _xy(nose)
    left_x, _ = _xy(left)
    right_x, _ = _xy(right)
    face_center_x = (left_x + right_x) / 2.0
    return safe_float((nose_x - face_center_x) / face_width)


def calculate_pitch_proxy(landmarks: Sequence[object]) -> float:
    """Vertical nose/chin relation normalized by face width."""
    try:
        nose = landmarks[NOSE_TIP]
        chin = landmarks[CHIN]
        left = landmarks[FACE_LEFT]
        right = landmarks[FACE_RIGHT]
    except (IndexError, TypeError):
        return math.nan

    face_width = euclidean_distance(left, right)
    if not face_width or math.isnan(face_width):
        return math.nan

    _, nose_y = _xy(nose)
    _, chin_y = _xy(chin)
    return safe_float((chin_y - nose_y) / face_width)


def _xy(point: object) -> tuple[float, float]:
    if isinstance(point, (tuple, list)) and len(point) >= 2:
        return safe_float(point[0]), safe_float(point[1])
    return safe_float(getattr(point, "x", None)), safe_float(getattr(point, "y", None))
