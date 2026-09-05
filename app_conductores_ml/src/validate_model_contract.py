import argparse
import hashlib
import json
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CONTRACT = PROJECT_ROOT / "shared" / "model_contract" / "model_contract.json"
DEFAULT_METADATA = PROJECT_ROOT / "driveawake" / "assets" / "models" / "preprocessing_metadata.json"
DEFAULT_MODEL = PROJECT_ROOT / "driveawake" / "assets" / "models" / "drowsiness_mlp.tflite"


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate_contract(contract_path: Path, metadata_path: Path, model_path: Path) -> dict:
    contract = json.loads(contract_path.read_text(encoding="utf-8"))
    metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    columns = metadata.get("feature_columns")
    if not isinstance(columns, list) or not columns:
        raise ValueError("Metadata sin feature_columns validas.")
    if contract["features"]["order"] != columns:
        raise ValueError("El orden de features no coincide con el contrato.")
    if contract["features"]["count"] != len(columns):
        raise ValueError("El numero de features no coincide con el contrato.")
    expected_hash = str(contract["model"]["sha256"]).lower()
    actual_hash = sha256_file(model_path)
    if actual_hash != expected_hash:
        raise ValueError("El hash SHA-256 del modelo no coincide con el contrato.")
    return {
        "model_sha256": actual_hash,
        "feature_count": len(columns),
        "deployment_status": contract["deployment_status"],
        "parity_verified": bool(contract["compatibility"]["parity_verified"]),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Valida contrato, metadata y modelo TFLite.")
    parser.add_argument("--contract", type=Path, default=DEFAULT_CONTRACT)
    parser.add_argument("--metadata", type=Path, default=DEFAULT_METADATA)
    parser.add_argument("--model", type=Path, default=DEFAULT_MODEL)
    args = parser.parse_args()
    result = validate_contract(args.contract, args.metadata, args.model)
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
