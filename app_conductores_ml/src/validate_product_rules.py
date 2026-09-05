import argparse
import json
from pathlib import Path

import joblib
import numpy as np
import pandas as pd
from sklearn.metrics import classification_report, confusion_matrix

from config import CLASS_NAMES, FEATURES_DIR, MODELS_DIR, REPORTS_DIR, infer_feature_columns


def safe_col(df: pd.DataFrame, name: str, default: float = 0.0) -> pd.Series:
    if name not in df.columns:
        return pd.Series(default, index=df.index, dtype=float)
    return pd.to_numeric(df[name], errors="coerce").fillna(default)


def hybrid_product_scores(df: pd.DataFrame, model_path: Path | None) -> pd.DataFrame:
    out = df.copy()
    perclos = safe_col(out, "perclos")
    closed = safe_col(out, "max_eye_closed_duration")
    yawn_count = safe_col(out, "yawn_count")
    yawn_count_roll6 = safe_col(out, "yawn_count_roll6_sum")
    no_face = safe_col(out, "no_face_ratio")
    yaw = safe_col(out, "yaw_proxy_max_abs")
    pitch = safe_col(out, "pitch_proxy_max")
    face_ratio = safe_col(out, "face_ratio", 1.0)

    rule_risk = np.zeros(len(out), dtype=float)
    reasons = np.array(["normal"] * len(out), dtype=object)

    def raise_risk(mask: pd.Series, score: float, reason: str) -> None:
        nonlocal rule_risk, reasons
        mask_values = mask.to_numpy(dtype=bool)
        update = mask_values & (score > rule_risk)
        rule_risk[update] = score
        reasons[update] = reason

    raise_risk(closed >= 3.0, 96, "ojos_cerrados_mas_3s")
    raise_risk((closed >= 1.5) & (closed < 3.0), 56, "ojos_cerrados_mas_1_5s")
    raise_risk((perclos >= 0.35) & (face_ratio >= 0.45), 78, "perclos_alto")
    raise_risk((perclos >= 0.20) & (perclos < 0.35) & (face_ratio >= 0.45), 44, "perclos_medio")
    raise_risk((yawn_count >= 3) | (yawn_count_roll6 >= 3), 76, "bostezos_repetidos")
    raise_risk(yawn_count >= 1, 30, "bostezo")
    raise_risk(no_face >= 0.35, 62, "rostro_ausente")
    raise_risk(no_face >= 0.15, 42, "rostro_ausente_breve")
    raise_risk(pitch.abs() >= 0.24, 42, "cabeza_caida")
    raise_risk(yaw.abs() >= 0.30, 41, "distraccion")

    model_risk = np.zeros(len(out), dtype=float)
    model_pred = np.zeros(len(out), dtype=int)
    model_conf = np.zeros(len(out), dtype=float)
    if model_path and model_path.exists():
        model = joblib.load(model_path)
        feature_columns = infer_feature_columns(list(out.columns))
        x = out[feature_columns].apply(pd.to_numeric, errors="coerce")
        if hasattr(model, "predict_proba"):
            probabilities = model.predict_proba(x)
            model_pred = probabilities.argmax(axis=1)
            model_conf = probabilities.max(axis=1)
            drowsy = probabilities[:, 2] if probabilities.shape[1] > 2 else np.zeros(len(out))
            fatigue = probabilities[:, 1] if probabilities.shape[1] > 1 else np.zeros(len(out))
            awake = probabilities[:, 0]
            model_risk = np.clip((drowsy * 44) + (fatigue * 24) - (awake * 8), 0, 82)
            model_risk[(model_pred == 2) & (model_conf >= 0.80)] = np.maximum(
                model_risk[(model_pred == 2) & (model_conf >= 0.80)],
                66,
            )
            model_risk[(model_pred == 2) & (model_conf >= 0.65)] = np.maximum(
                model_risk[(model_pred == 2) & (model_conf >= 0.65)],
                48,
            )
            model_risk[(model_pred == 1) & (model_conf >= 0.60)] = np.maximum(
                model_risk[(model_pred == 1) & (model_conf >= 0.60)],
                36,
            )

    total_risk = np.maximum(rule_risk, model_risk)
    combined = (rule_risk >= 40) & (model_risk >= 35)
    total_risk[combined] = np.maximum(total_risk[combined], 72)
    level = np.where(total_risk >= 70, 2, np.where(total_risk >= 40, 1, 0))

    out["product_rule_risk"] = rule_risk
    out["product_model_risk"] = model_risk
    out["product_total_risk"] = total_risk
    out["product_level"] = level
    out["product_reason"] = reasons
    out["product_model_pred"] = model_pred
    out["product_model_conf"] = model_conf
    return out


def summarize_binary(y_true: pd.Series, y_pred: pd.Series) -> dict:
    report = classification_report(y_true, y_pred, output_dict=True, zero_division=0)
    matrix = confusion_matrix(y_true, y_pred, labels=[0, 1]).tolist()
    tn, fp, fn, tp = confusion_matrix(y_true, y_pred, labels=[0, 1]).ravel()
    return {
        "confusion_matrix_labels": ["negative", "positive"],
        "confusion_matrix": matrix,
        "true_negative": int(tn),
        "false_positive": int(fp),
        "false_negative": int(fn),
        "true_positive": int(tp),
        "false_positive_rate": float(fp / max(1, fp + tn)),
        "false_negative_rate": float(fn / max(1, fn + tp)),
        "classification_report": report,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", type=Path, default=FEATURES_DIR / "fold5_features_enhanced.csv")
    parser.add_argument("--model", type=Path, default=MODELS_DIR / "drowsiness_best_tabular.joblib")
    parser.add_argument("--output_dir", type=Path, default=REPORTS_DIR)
    args = parser.parse_args()

    args.output_dir.mkdir(parents=True, exist_ok=True)
    df = pd.read_csv(args.csv)
    if "label" not in df.columns:
        raise ValueError("El CSV debe incluir columna label.")

    scored = hybrid_product_scores(df, args.model)
    y = scored["label"].astype(int)
    alert_true = (y > 0).astype(int)
    alert_pred = (scored["product_level"] > 0).astype(int)
    danger_true = (y == 2).astype(int)
    danger_pred = (scored["product_level"] == 2).astype(int)

    alert_fp = scored[(alert_true == 0) & (alert_pred == 1)]
    alert_fn = scored[(alert_true == 1) & (alert_pred == 0)]
    danger_fp = scored[(danger_true == 0) & (danger_pred == 1)]
    danger_fn = scored[(danger_true == 1) & (danger_pred == 0)]

    selected_columns = [
        "video_id",
        "window_id",
        "start_second",
        "end_second",
        "label",
        "product_level",
        "product_total_risk",
        "product_rule_risk",
        "product_model_risk",
        "product_reason",
        "perclos",
        "max_eye_closed_duration",
        "yawn_count",
        "no_face_ratio",
    ]
    selected_columns = [column for column in selected_columns if column in scored.columns]
    alert_fp[selected_columns].to_csv(
        args.output_dir / "product_alert_false_positives.csv", index=False
    )
    alert_fn[selected_columns].to_csv(
        args.output_dir / "product_alert_false_negatives.csv", index=False
    )
    danger_fp[selected_columns].to_csv(
        args.output_dir / "product_danger_false_positives.csv", index=False
    )
    danger_fn[selected_columns].to_csv(
        args.output_dir / "product_danger_false_negatives.csv", index=False
    )

    metrics = {
        "dataset_rows": int(len(scored)),
        "class_names": CLASS_NAMES,
        "model_used": str(args.model) if args.model and args.model.exists() else None,
        "alert_definition": "label > 0 versus product_level > 0",
        "danger_definition": "label == 2 versus product_level == 2",
        "alert_metrics": summarize_binary(alert_true, alert_pred),
        "danger_metrics": summarize_binary(danger_true, danger_pred),
        "predicted_levels": {
            str(k): int(v) for k, v in scored["product_level"].value_counts().sort_index().items()
        },
        "rule_reason_counts": {
            str(k): int(v) for k, v in scored["product_reason"].value_counts().head(20).items()
        },
    }
    with (args.output_dir / "product_validation_metrics.json").open("w", encoding="utf-8") as file:
        json.dump(metrics, file, indent=2, ensure_ascii=False)

    print("=== Validacion producto hibrido ===")
    print(f"Filas evaluadas: {len(scored)}")
    print(f"Modelo usado: {metrics['model_used']}")
    print(f"Alert FP: {metrics['alert_metrics']['false_positive']}")
    print(f"Alert FN: {metrics['alert_metrics']['false_negative']}")
    print(f"Danger FP: {metrics['danger_metrics']['false_positive']}")
    print(f"Danger FN: {metrics['danger_metrics']['false_negative']}")
    print(f"Reporte: {args.output_dir / 'product_validation_metrics.json'}")


if __name__ == "__main__":
    main()
