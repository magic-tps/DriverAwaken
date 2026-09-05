import argparse
import subprocess
import sys
from pathlib import Path

from config import (
    BASE_DIR,
    EAR_CLOSED_THRESHOLD,
    EXTRACTION_WORKERS,
    FEATURES_DIR,
    MAR_YAWN_THRESHOLD,
    MAX_FRAME_WIDTH,
    RAW_FOLD5_DIR,
    SAMPLE_FPS,
    WINDOW_SECONDS,
)


def python_executable() -> str:
    venv_python = BASE_DIR / "venv" / "Scripts" / "python.exe"
    if venv_python.exists():
        return str(venv_python)
    return sys.executable


def run_command(command: list[str]) -> None:
    print("\n> " + " ".join(command))
    subprocess.run(command, cwd=BASE_DIR, check=True)


def run_all(
    input_dir: Path,
    sample_fps: float,
    window_seconds: int,
    max_frame_width: int,
    workers: int,
    skip_existing_features: bool,
    ear_threshold: float,
    mar_threshold: float,
    rf_search_iter: int,
    rf_cv_splits: int,
    mlp_epochs: int,
    mlp_batch_size: int,
    mlp_learning_rate: float,
    mlp_patience: int,
    mlp_min_final_epochs: int,
    sampling_mode: str,
    enhanced_features: bool,
    zoo_estimators: int,
    logistic_cv_splits: int,
) -> None:
    features_csv = FEATURES_DIR / "fold5_features.csv"
    enhanced_features_csv = FEATURES_DIR / "fold5_features_enhanced.csv"
    training_csv = enhanced_features_csv if enhanced_features else features_csv
    python = python_executable()

    steps = [
        [
            python,
            "-u",
            "src/inspect_dataset.py",
            "--input",
            str(input_dir),
        ],
    ]

    if skip_existing_features and features_csv.exists():
        print(f"Reusando CSV existente: {features_csv}")
    else:
        steps.append(
            [
                python,
                "-u",
                "src/extract_features.py",
                "--input",
                str(input_dir),
                "--output",
                str(features_csv),
                "--sample_fps",
                str(sample_fps),
                "--window_seconds",
                str(window_seconds),
                "--max_frame_width",
                str(max_frame_width),
                "--workers",
                str(workers),
                "--ear_threshold",
                str(ear_threshold),
                "--mar_threshold",
                str(mar_threshold),
                "--sampling_mode",
                sampling_mode,
            ]
        )

    steps.extend(
        [
            [
                python,
                "-u",
                "src/feature_engineering.py",
                "--input",
                str(features_csv),
                "--output",
                str(enhanced_features_csv),
                "--ear_threshold",
                str(ear_threshold),
                "--mar_threshold",
                str(mar_threshold),
                "--window_seconds",
                str(window_seconds),
            ],
            [
                python,
                "-u",
                "src/train_random_forest.py",
                "--csv",
                str(training_csv),
                "--search_iter",
                str(rf_search_iter),
                "--cv_splits",
                str(rf_cv_splits),
            ],
            [
                python,
                "-u",
                "src/train_model_zoo.py",
                "--csv",
                str(training_csv),
                "--n_estimators",
                str(zoo_estimators),
            ],
            [
                python,
                "-u",
                "src/train_logistic_search.py",
                "--csv",
                str(training_csv),
                "--cv_splits",
                str(logistic_cv_splits),
            ],
            [
                python,
                "-u",
                "src/train_mlp_tflite.py",
                "--csv",
                str(training_csv),
                "--epochs",
                str(mlp_epochs),
                "--batch_size",
                str(mlp_batch_size),
                "--learning_rate",
                str(mlp_learning_rate),
                "--patience",
                str(mlp_patience),
                "--min_final_epochs",
                str(mlp_min_final_epochs),
            ],
            [
                python,
                "-u",
                "src/export_flutter_assets.py",
            ],
        ]
    )

    print("=== Pipeline Fase 2 - MagicDrive Alert ===")
    print(f"Input: {input_dir}")
    print(f"Features: {features_csv}")
    print(f"Features enriquecidas: {enhanced_features_csv}")
    print(f"CSV de entrenamiento: {training_csv}")
    print(f"Muestreo: {sample_fps} FPS")
    print(f"Ventanas: {window_seconds} segundos")
    print(f"Ancho maximo de frame: {max_frame_width}px")
    print(f"Workers de extraccion: {workers}")
    print(f"EAR cerrado: {ear_threshold}")
    print(f"MAR bostezo: {mar_threshold}")
    print(f"Modo de muestreo: {sampling_mode}")
    print(f"RF search_iter: {rf_search_iter}")
    print(f"Model zoo estimators: {zoo_estimators}")
    print(f"MLP epochs: {mlp_epochs}")
    print(f"Python: {python}")

    for index, command in enumerate(steps, start=1):
        print(f"\n--- Paso {index}/{len(steps)} ---")
        run_command(command)

    print("\nPipeline completo.")
    print(f"CSV: {features_csv}")
    if enhanced_features:
        print(f"CSV enriquecido: {enhanced_features_csv}")
    print("Modelos: models/")
    print("Reportes: reports/")
    print("Assets Flutter: flutter_assets/")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Ejecuta toda la Fase 2.")
    parser.add_argument("--input", type=Path, default=RAW_FOLD5_DIR)
    parser.add_argument("--sample_fps", type=float, default=SAMPLE_FPS)
    parser.add_argument("--window_seconds", type=int, default=WINDOW_SECONDS)
    parser.add_argument("--max_frame_width", type=int, default=MAX_FRAME_WIDTH)
    parser.add_argument("--workers", type=int, default=EXTRACTION_WORKERS)
    parser.add_argument("--ear_threshold", type=float, default=EAR_CLOSED_THRESHOLD)
    parser.add_argument("--mar_threshold", type=float, default=MAR_YAWN_THRESHOLD)
    parser.add_argument("--rf_search_iter", type=int, default=0)
    parser.add_argument("--rf_cv_splits", type=int, default=4)
    parser.add_argument("--mlp_epochs", type=int, default=500)
    parser.add_argument("--mlp_batch_size", type=int, default=32)
    parser.add_argument("--mlp_learning_rate", type=float, default=0.00025)
    parser.add_argument("--mlp_patience", type=int, default=70)
    parser.add_argument("--mlp_min_final_epochs", type=int, default=100)
    parser.add_argument("--sampling_mode", choices=["seek", "grab"], default="grab")
    parser.add_argument(
        "--base_features_only",
        action="store_true",
        help="Entrena usando solo las 20 features base. Por defecto usa features enriquecidas.",
    )
    parser.add_argument("--zoo_estimators", type=int, default=700)
    parser.add_argument("--logistic_cv_splits", type=int, default=4)
    parser.add_argument(
        "--skip_existing_features",
        action="store_true",
        help="Reusa data/features/fold5_features.csv si ya existe.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    run_all(
        input_dir=args.input,
        sample_fps=args.sample_fps,
        window_seconds=args.window_seconds,
        max_frame_width=args.max_frame_width,
        workers=max(1, args.workers),
        skip_existing_features=args.skip_existing_features,
        ear_threshold=args.ear_threshold,
        mar_threshold=args.mar_threshold,
        rf_search_iter=max(0, args.rf_search_iter),
        rf_cv_splits=max(2, args.rf_cv_splits),
        mlp_epochs=max(1, args.mlp_epochs),
        mlp_batch_size=max(1, args.mlp_batch_size),
        mlp_learning_rate=args.mlp_learning_rate,
        mlp_patience=max(1, args.mlp_patience),
        mlp_min_final_epochs=max(1, args.mlp_min_final_epochs),
        sampling_mode=args.sampling_mode,
        enhanced_features=not args.base_features_only,
        zoo_estimators=max(100, args.zoo_estimators),
        logistic_cv_splits=max(2, args.logistic_cv_splits),
    )


if __name__ == "__main__":
    main()
