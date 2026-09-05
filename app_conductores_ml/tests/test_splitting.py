import pandas as pd
import pytest

from splitting import (
    create_grouped_cv,
    extract_subject_groups,
    grouped_holdout_indices,
    validate_no_group_leakage,
)


def sample_data(subject_count: int = 18) -> tuple[pd.Series, pd.Series]:
    labels: list[int] = []
    groups: list[str] = []
    for subject in range(subject_count):
        for label in range(3):
            labels.extend([label] * 4)
            groups.extend([f"subject_{subject:02d}"] * 4)
    return pd.Series(labels), pd.Series(groups)


def test_extract_subject_groups_requires_subject_id() -> None:
    with pytest.raises(ValueError, match="subject_id"):
        extract_subject_groups(pd.DataFrame({"video_id": ["video_1"]}))


def test_extract_subject_groups_rejects_unknown_values() -> None:
    frame = pd.DataFrame({"subject_id": ["001", "unknown"]})

    with pytest.raises(ValueError, match="desconocidos"):
        extract_subject_groups(frame)


def test_holdout_has_zero_subject_intersection() -> None:
    y, groups = sample_data()

    train_index, test_index, _ = grouped_holdout_indices(y, groups)

    train_subjects = set(groups.iloc[train_index])
    test_subjects = set(groups.iloc[test_index])
    assert train_subjects.isdisjoint(test_subjects)
    assert set(y.iloc[train_index].unique()) == {0, 1, 2}
    assert set(y.iloc[test_index].unique()) == {0, 1, 2}


def test_holdout_is_reproducible_with_same_seed() -> None:
    y, groups = sample_data()

    first = grouped_holdout_indices(y, groups, base_seed=73)
    second = grouped_holdout_indices(y, groups, base_seed=73)

    assert first[2] == second[2]
    assert first[0].tolist() == second[0].tolist()
    assert first[1].tolist() == second[1].tolist()


def test_different_seed_ranges_can_select_different_subjects() -> None:
    y, groups = sample_data()

    first = grouped_holdout_indices(y, groups, base_seed=10, candidate_seeds=1)
    second = grouped_holdout_indices(y, groups, base_seed=200, candidate_seeds=1)

    assert set(groups.iloc[first[1]]) != set(groups.iloc[second[1]])


def test_validate_no_group_leakage_fails_fast() -> None:
    with pytest.raises(ValueError, match="Fuga de sujetos"):
        validate_no_group_leakage(["001", "002"], ["002", "003"])


def test_grouped_cv_rejects_too_few_subjects() -> None:
    with pytest.raises(ValueError, match="2 sujetos"):
        create_grouped_cv(pd.Series(["001", "001"]), n_splits=4)


def test_grouped_cv_never_mixes_subjects() -> None:
    y, groups = sample_data(subject_count=12)
    x = pd.DataFrame({"feature": range(len(y))})
    cv = create_grouped_cv(groups, n_splits=4)

    for train_index, test_index in cv.split(x, y, groups):
        validate_no_group_leakage(groups.iloc[train_index], groups.iloc[test_index])
