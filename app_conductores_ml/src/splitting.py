from __future__ import annotations

from collections.abc import Sequence

import numpy as np
import pandas as pd
from sklearn.model_selection import GroupShuffleSplit, StratifiedGroupKFold


def extract_subject_groups(df: pd.DataFrame) -> pd.Series:
    if "subject_id" not in df.columns:
        raise ValueError(
            "El dataset debe incluir subject_id antes de entrenar; "
            "no se permite usar video_id como sustituto."
        )
    groups = df["subject_id"].astype(str).str.strip()
    if groups.empty or groups.eq("").any() or groups.str.lower().eq("unknown").any():
        raise ValueError("subject_id contiene valores vacios o desconocidos.")
    if groups.nunique() < 2:
        raise ValueError("Se necesitan al menos 2 sujetos independientes.")
    return groups


def validate_no_group_leakage(
    train_groups: Sequence[object] | pd.Series,
    test_groups: Sequence[object] | pd.Series,
) -> None:
    train_ids = {str(value) for value in train_groups}
    test_ids = {str(value) for value in test_groups}
    overlap = sorted(train_ids.intersection(test_ids))
    if overlap:
        preview = ", ".join(overlap[:10])
        raise ValueError(f"Fuga de sujetos detectada: {preview}")


def grouped_holdout_indices(
    y: pd.Series,
    groups: pd.Series,
    *,
    test_size: float = 0.20,
    base_seed: int = 42,
    candidate_seeds: int = 24,
) -> tuple[np.ndarray, np.ndarray, int]:
    if not 0 < test_size < 1:
        raise ValueError("test_size debe estar entre 0 y 1.")
    if groups.nunique() < 2:
        raise ValueError("Se necesitan al menos 2 sujetos para crear holdout.")

    labels = sorted(int(value) for value in y.unique())
    global_distribution = y.value_counts(normalize=True)
    best: tuple[float, np.ndarray, np.ndarray, int] | None = None

    for seed in range(base_seed, base_seed + max(1, candidate_seeds)):
        splitter = GroupShuffleSplit(
            n_splits=1,
            test_size=test_size,
            random_state=seed,
        )
        train_index, test_index = next(splitter.split(np.zeros(len(y)), y, groups=groups))
        train_y = y.iloc[train_index]
        test_y = y.iloc[test_index]
        missing_penalty = 10 * (
            len(set(labels).difference(train_y.unique()))
            + len(set(labels).difference(test_y.unique()))
        )
        distribution_error = sum(
            abs(float(test_y.eq(label).mean()) - float(global_distribution.get(label, 0)))
            for label in labels
        )
        score = missing_penalty + distribution_error
        if best is None or score < best[0]:
            best = (score, train_index, test_index, seed)

    if best is None:
        raise ValueError("No se pudo crear un split agrupado.")
    _, train_index, test_index, selected_seed = best
    validate_no_group_leakage(groups.iloc[train_index], groups.iloc[test_index])
    return train_index, test_index, selected_seed


def create_grouped_cv(groups: pd.Series, n_splits: int, seed: int = 42) -> StratifiedGroupKFold:
    group_count = int(groups.nunique())
    if group_count < 2:
        raise ValueError("Se necesitan al menos 2 sujetos para validacion cruzada.")
    folds = min(max(2, n_splits), group_count)
    return StratifiedGroupKFold(n_splits=folds, shuffle=True, random_state=seed)
