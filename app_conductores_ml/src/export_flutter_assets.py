import argparse
import json
import shutil
from pathlib import Path

from config import FEATURE_COLUMNS, FLUTTER_ASSETS_DIR, MODELS_DIR


def export_assets(
    model_path: Path,
    metadata_path: Path,
    output_dir: Path,
) -> None:
    assets_models_dir = output_dir / "assets" / "models"
    assets_models_dir.mkdir(parents=True, exist_ok=True)

    if not model_path.exists():
        raise FileNotFoundError(f"No existe el modelo TFLite: {model_path}")
    if not metadata_path.exists():
        raise FileNotFoundError(f"No existe preprocessing_metadata.json: {metadata_path}")

    target_model = assets_models_dir / "drowsiness_mlp.tflite"
    target_metadata = assets_models_dir / "preprocessing_metadata.json"
    shutil.copy2(model_path, target_model)
    shutil.copy2(metadata_path, target_metadata)

    feature_columns = _feature_columns_from_metadata(metadata_path)
    readme_path = output_dir / "README_FLUTTER_INTEGRATION.md"
    readme_path.write_text(build_readme(feature_columns), encoding="utf-8")

    print("\n=== Assets Flutter exportados ===")
    print(f"Modelo: {target_model}")
    print(f"Metadata: {target_metadata}")
    print(f"Guia: {readme_path}")


def _feature_columns_from_metadata(metadata_path: Path) -> list[str]:
    try:
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
        columns = metadata.get("feature_columns", FEATURE_COLUMNS)
        return [str(column) for column in columns]
    except Exception:  # noqa: BLE001
        return FEATURE_COLUMNS


def build_readme(feature_columns: list[str]) -> str:
    feature_list = "\n".join(
        f"{index + 1}. `{column}`" for index, column in enumerate(feature_columns)
    )
    return f"""# Integracion Flutter - MagicDrive Alert Fase 2

Esta carpeta contiene los assets generados por el pipeline Python:

- `assets/models/drowsiness_mlp.tflite`
- `assets/models/preprocessing_metadata.json`

## Donde copiarlos

Copia la carpeta `assets/models/` dentro del proyecto Flutter, por ejemplo:

```text
driveawake/
  assets/
    models/
      drowsiness_mlp.tflite
      preprocessing_metadata.json
```

## pubspec.yaml

Agrega los assets:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/models/drowsiness_mlp.tflite
    - assets/models/preprocessing_metadata.json
```

## Dependencia sugerida

```yaml
dependencies:
  tflite_flutter: ^0.11.0
```

## Orden exacto de features

Flutter debe enviar las features en este orden exacto:

{feature_list}

## Preprocesamiento que debe replicar Flutter

1. Construir el vector con el orden anterior.
2. Si una feature es NaN o no esta disponible, reemplazarla por la mediana de `imputer_medians`.
3. Normalizar cada valor:

```text
valor_normalizado = (valor - scaler_means[i]) / scaler_stds[i]
```

4. Enviar un tensor `[1, feature_count]` de `float32` al modelo TFLite.
5. Leer la salida softmax `[1, 3]`.

## Features temporales

Este modelo puede incluir features enriquecidas como:

- diferencias contra la ventana anterior (`*_diff1`)
- promedios/maximos/minimos rolling de 3, 6 y 12 ventanas
- acumuladores de fatiga basados en ojos, boca y pose

Para producirlas en Flutter, manten un buffer por sesion de conduccion con las
ultimas ventanas de 10 segundos. Al iniciar una sesion, calcula las rolling
features con las ventanas disponibles; para la primera ventana los deltas deben
ser `0`, igual que en el entrenamiento.

## Interpretacion de salida

- Indice `0`: despierto
- Indice `1`: cansancio
- Indice `2`: somnoliento

Uso recomendado en la app:

- Si ojos cerrados mas de 3 segundos: alarma por regla critica.
- Si no hay rostro mas de 2 segundos: alerta por regla critica.
- Si el modelo predice `somnoliento` con alta confianza: alarma o elevacion de riesgo.
- Si el modelo predice `cansancio`: combinar con PERCLOS, bostezos y cabeza caida.
"""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Exporta assets listos para Flutter.")
    parser.add_argument(
        "--model",
        type=Path,
        default=MODELS_DIR / "drowsiness_mlp.tflite",
    )
    parser.add_argument(
        "--metadata",
        type=Path,
        default=MODELS_DIR / "preprocessing_metadata.json",
    )
    parser.add_argument("--output", type=Path, default=FLUTTER_ASSETS_DIR)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    export_assets(args.model, args.metadata, args.output)


if __name__ == "__main__":
    main()
