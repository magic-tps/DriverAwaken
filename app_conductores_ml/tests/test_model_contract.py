import json
from pathlib import Path

import numpy as np

from validate_model_contract import validate_contract

ROOT = Path(__file__).resolve().parents[2]
METADATA_PATH = ROOT / "driveawake" / "assets" / "models" / "preprocessing_metadata.json"
CONTRACT_PATH = ROOT / "shared" / "model_contract" / "model_contract.json"
RAW_FIXTURE_PATH = ROOT / "shared" / "test_vectors" / "raw_features.json"
EXPECTED_PATH = ROOT / "shared" / "test_vectors" / "expected_scaled_input.json"


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def test_contract_matches_deployed_metadata_order() -> None:
    metadata = load_json(METADATA_PATH)
    contract = load_json(CONTRACT_PATH)

    assert contract["features"]["order"] == metadata["feature_columns"]
    assert contract["features"]["count"] == len(metadata["feature_columns"])
    assert contract["model"]["input_shape"] == [1, len(metadata["feature_columns"])]
    assert contract["deployment_status"] == "disabled_by_default"
    assert contract["compatibility"]["parity_verified"] is False


def test_contract_hash_matches_deployed_model() -> None:
    result = validate_contract(
        CONTRACT_PATH,
        METADATA_PATH,
        ROOT / "driveawake" / "assets" / "models" / "drowsiness_mlp.tflite",
    )

    assert result["feature_count"] == 181
    assert result["parity_verified"] is False


def test_shared_golden_scaling_vector() -> None:
    metadata = load_json(METADATA_PATH)
    raw = load_json(RAW_FIXTURE_PATH)["features"]
    expected_fixture = load_json(EXPECTED_PATH)
    columns = metadata["feature_columns"]
    values = np.asarray([raw[column] for column in columns], dtype=float)
    means = np.asarray(metadata["scaler_means"], dtype=float)
    stds = np.asarray(metadata["scaler_stds"], dtype=float)

    actual = (values - means) / np.where(stds == 0, 1.0, stds)
    expected = np.asarray(expected_fixture["values"], dtype=float)

    np.testing.assert_allclose(
        actual,
        expected,
        rtol=0,
        atol=float(expected_fixture["absolute_tolerance"]),
    )
