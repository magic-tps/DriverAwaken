# Catálogo de archivos de DriverAwaken Guardian

Fecha de corte: 17 de octubre de 2026, America/Lima.

Complementa [el informe completo](INFORME_COMPLETO_DRIVERAWAKEN_GUARDIAN.md). Hashes, declaraciones completas, esquema SQLite y contrato ML: [JSON](INVENTARIO_TECNICO_GUARDIAN.json).

## Alcance

Inventario de **385 archivos existentes** versionados o nuevos no ignorados. Incluye fuentes generadas que permanecen en el proyecto. Excluye este par de catálogos para evitar hashes recursivos. No enumera los archivos internos de dependencias, cachés, builds ni vídeos privados.

Las declaraciones forman un índice estático: que una clase exista no demuestra que se use en runtime. Los títulos de tests provienen del código; sus resultados ejecutados se documentan en TECHNICAL_VALIDATION.md. No se copian datos confidenciales.

## Resumen por carpeta

| Carpeta | Archivos |
| --- | ---: |
| `.github` | 2 |
| `app_conductores_ml` | 30 |
| `backend` | 8 |
| `dashboard` | 47 |
| `docs` | 17 |
| `driveawake` | 259 |
| `root` | 10 |
| `scripts` | 2 |
| `shared` | 10 |

## Inventario por ubicación

### .

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [.gitignore](../.gitignore) | 1014 | 57 | Configuración / recurso / documentación |
| [DEMO_GUIDE.md](../DEMO_GUIDE.md) | 2643 | 26 | Configuración / recurso / documentación |
| [DEPLOYMENT.md](../DEPLOYMENT.md) | 6820 | 125 | Configuración / recurso / documentación |
| [HACKTHEANDES_2026.md](../HACKTHEANDES_2026.md) | 4534 | 46 | Configuración / recurso / documentación |
| [PITCH_SCRIPT.md](../PITCH_SCRIPT.md) | 4733 | 31 | Configuración / recurso / documentación |
| [PRIVACY.md](../PRIVACY.md) | 2905 | 19 | Configuración / recurso / documentación |
| [README.md](../README.md) | 4335 | 43 | Configuración / recurso / documentación |
| [TECHNICAL_VALIDATION.md](../TECHNICAL_VALIDATION.md) | 12753 | 122 | Configuración / recurso / documentación |
| [firebase.json](../firebase.json) | 705 | 23 | Configuración / recurso / documentación |
| [proyecto.md](../proyecto.md) | 4311 | 44 | Configuración / recurso / documentación |

### .github/workflows

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [ci.yml](../.github/workflows/ci.yml) | 2449 | 96 | Configuración / recurso / documentación |
| [release.yml](../.github/workflows/release.yml) | 2266 | 65 | Configuración / recurso / documentación |

### app_conductores_ml

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [.gitignore](../app_conductores_ml/.gitignore) | 158 | 15 | Configuración / recurso / documentación |
| [README.md](../app_conductores_ml/README.md) | 8767 | 318 | Configuración / recurso / documentación |
| [pyproject.toml](../app_conductores_ml/pyproject.toml) | 259 | - | Recurso binario |
| [requirements-dev.txt](../app_conductores_ml/requirements-dev.txt) | 49 | 3 | Configuración / recurso / documentación |
| [requirements.txt](../app_conductores_ml/requirements.txt) | 251 | 13 | Configuración / recurso / documentación |

### app_conductores_ml/flutter_assets

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [README_FLUTTER_INTEGRATION.md](../app_conductores_ml/flutter_assets/README_FLUTTER_INTEGRATION.md) | 7301 | 262 | Configuración / recurso / documentación |

### app_conductores_ml/flutter_assets/assets/models

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [drowsiness_mlp.tflite](../app_conductores_ml/flutter_assets/assets/models/drowsiness_mlp.tflite) | 37552 | - | Recurso binario |
| [preprocessing_metadata.json](../app_conductores_ml/flutter_assets/assets/models/preprocessing_metadata.json) | 18410 | 747 | Configuración / recurso / documentación |

### app_conductores_ml/models

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [preprocessing_metadata.json](../app_conductores_ml/models/preprocessing_metadata.json) | 18410 | 747 | Configuración / recurso / documentación |

### app_conductores_ml/reports

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [feature_importance.csv](../app_conductores_ml/reports/feature_importance.csv) | 7847 | - | Recurso binario |
| [model_zoo_metrics.csv](../app_conductores_ml/reports/model_zoo_metrics.csv) | 1316 | - | Recurso binario |

### app_conductores_ml/src

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [__init__.py](../app_conductores_ml/src/__init__.py) | 62 | 1 | Configuración / recurso / documentación |
| [config.py](../app_conductores_ml/src/config.py) | 1972 | 98 | `infer_feature_columns`, `ensure_project_dirs` |
| [dataset_utils.py](../app_conductores_ml/src/dataset_utils.py) | 3090 | 97 | `find_video_files`, `infer_raw_label`, `model_label_from_raw`, `video_id_for_path`, `source_path_text`, `labeled_videos`, `_relative_parts`, `count_by_label` |
| [export_flutter_assets.py](../app_conductores_ml/src/export_flutter_assets.py) | 4484 | 157 | `export_assets`, `_feature_columns_from_metadata`, `build_readme`, `parse_args`, `main` |
| [extract_features.py](../app_conductores_ml/src/extract_features.py) | 18154 | 537 | `process_frame`, `process_video`, `process_video_worker`, `summarize_window`, `extract_features`, `_numeric_values`, `_stat`, `_max_abs` (+6 en JSON) |
| [feature_engineering.py](../app_conductores_ml/src/feature_engineering.py) | 9609 | 264 | `engineer_features`, `add_static_features`, `add_temporal_features`, `extract_subject_id`, `extract_fold_id`, `parse_args`, `main` |
| [inspect_dataset.py](../app_conductores_ml/src/inspect_dataset.py) | 3753 | 119 | `inspect_video`, `run`, `parse_args`, `main` |
| [landmark_utils.py](../app_conductores_ml/src/landmark_utils.py) | 3598 | 122 | `safe_float`, `nanmean`, `euclidean_distance`, `calculate_ear`, `calculate_mar`, `calculate_yaw_proxy`, `calculate_pitch_proxy`, `_xy` |
| [predict_sample.py](../app_conductores_ml/src/predict_sample.py) | 3344 | 92 | `load_model`, `select_row`, `predict`, `parse_args`, `main` |
| [run_all_phase2.py](../app_conductores_ml/src/run_all_phase2.py) | 8268 | 255 | `python_executable`, `run_command`, `run_all`, `parse_args`, `main` |
| [splitting.py](../app_conductores_ml/src/splitting.py) | 3307 | 86 | `extract_subject_groups`, `validate_no_group_leakage`, `grouped_holdout_indices`, `create_grouped_cv` |
| [train_logistic_search.py](../app_conductores_ml/src/train_logistic_search.py) | 7519 | 235 | `load_training_data`, `split_by_subject`, `build_pipeline`, `train_logistic_search`, `save_confusion_matrix`, `parse_args`, `main` |
| [train_mlp_tflite.py](../app_conductores_ml/src/train_mlp_tflite.py) | 15521 | 447 | `load_training_data`, `split_by_subject`, `split_train_validation_by_video`, `build_model`, `train`, `scale_features`, `build_callbacks`, `best_epoch_from_history` (+6 en JSON) |
| [train_model_zoo.py](../app_conductores_ml/src/train_model_zoo.py) | 12699 | 386 | `load_training_data`, `split_by_subject`, `build_models`, `train_model_zoo`, `save_confusion_matrix`, `save_feature_importance_if_available`, `parse_args`, `main` |
| [train_random_forest.py](../app_conductores_ml/src/train_random_forest.py) | 11927 | 379 | `load_training_data`, `split_by_subject`, `build_pipeline`, `fit_random_forest`, `train`, `save_confusion_matrix`, `save_feature_importance`, `print_conclusion` (+2 en JSON) |
| [validate_model_contract.py](../app_conductores_ml/src/validate_model_contract.py) | 2262 | 53 | `sha256_file`, `validate_contract`, `main` |
| [validate_product_rules.py](../app_conductores_ml/src/validate_product_rules.py) | 8230 | 194 | `safe_col`, `hybrid_product_scores`, `summarize_binary`, `main` |

### app_conductores_ml/tests

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [test_model_contract.py](../app_conductores_ml/tests/test_model_contract.py) | 2093 | 58 | `load_json`, `test_contract_matches_deployed_metadata_order`, `test_contract_hash_matches_deployed_model`, `test_shared_golden_scaling_vector` |
| [test_splitting.py](../app_conductores_ml/tests/test_splitting.py) | 2757 | 82 | `sample_data`, `test_extract_subject_groups_requires_subject_id`, `test_extract_subject_groups_rejects_unknown_values`, `test_holdout_has_zero_subject_intersection`, `test_holdout_is_reproducible_with_same_seed`, `test_different_seed_ranges_can_select_different_subjects`, `test_validate_no_group_leakage_fails_fast`, `test_grouped_cv_rejects_too_few_subjects` (+1 en JSON) |

### backend

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [firebase.test.json](../backend/firebase.test.json) | 317 | 10 | Configuración / recurso / documentación |
| [firebase.web-test.json](../backend/firebase.web-test.json) | 368 | 11 | Configuración / recurso / documentación |
| [firestore.rules](../backend/firestore.rules) | 13852 | 207 | Configuración / recurso / documentación |
| [package-lock.json](../backend/package-lock.json) | 103532 | 2787 | Configuración / recurso / documentación |
| [package.json](../backend/package.json) | 480 | 12 | Configuración / recurso / documentación |

### backend/scripts

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [bootstrap.mjs](../backend/scripts/bootstrap.mjs) | 1637 | 28 | Configuración / recurso / documentación |
| [seed-emulators.mjs](../backend/scripts/seed-emulators.mjs) | 4487 | 59 | `loopbackPort` |

### backend/tests

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [firestore.test.mjs](../backend/tests/firestore.test.mjs) | 13325 | 181 | `deliver` |

### dashboard

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [.env.example](../dashboard/.env.example) | 286 | - | Recurso binario |
| [.gitignore](../dashboard/.gitignore) | 93 | 8 | Configuración / recurso / documentación |
| [README.md](../dashboard/README.md) | 10859 | 120 | Configuración / recurso / documentación |
| [eslint.config.mjs](../dashboard/eslint.config.mjs) | 339 | 8 | Configuración / recurso / documentación |
| [next-env.d.ts](../dashboard/next-env.d.ts) | 288 | 7 | Configuración / recurso / documentación |
| [next.config.ts](../dashboard/next.config.ts) | 198 | 9 | Configuración / recurso / documentación |
| [package-lock.json](../dashboard/package-lock.json) | 325623 | 9460 | Configuración / recurso / documentación |
| [package.json](../dashboard/package.json) | 908 | 34 | Configuración / recurso / documentación |
| [playwright.config.ts](../dashboard/playwright.config.ts) | 611 | 9 | Configuración / recurso / documentación |
| [postcss.config.mjs](../dashboard/postcss.config.mjs) | 83 | 2 | Configuración / recurso / documentación |
| [tsconfig.json](../dashboard/tsconfig.json) | 602 | 21 | Configuración / recurso / documentación |
| [vitest.config.ts](../dashboard/vitest.config.ts) | 143 | 2 | Configuración / recurso / documentación |

### dashboard/e2e

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [emulator.spec.ts](../dashboard/e2e/emulator.spec.ts) | 7218 | 98 | `login` |
| [public.spec.ts](../dashboard/e2e/public.spec.ts) | 7236 | 105 | Configuración / recurso / documentación |

### dashboard/scripts

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [emulator.mjs](../dashboard/scripts/emulator.mjs) | 1747 | 31 | `port` |
| [serve.mjs](../dashboard/scripts/serve.mjs) | 1545 | 18 | Configuración / recurso / documentación |

### dashboard/src/app

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [globals.css](../dashboard/src/app/globals.css) | 45725 | 68 | Configuración / recurso / documentación |
| [layout.tsx](../dashboard/src/app/layout.tsx) | 597 | 11 | `RootLayout` |
| [not-found.tsx](../dashboard/src/app/not-found.tsx) | 506 | 3 | `NotFound` |
| [page.tsx](../dashboard/src/app/page.tsx) | 4064 | 13 | `Home` |

### dashboard/src/app/dashboard

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [page.tsx](../dashboard/src/app/dashboard/page.tsx) | 167 | 3 | `Page` |

### dashboard/src/app/dashboard/drivers

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [page.tsx](../dashboard/src/app/dashboard/drivers/page.tsx) | 179 | 3 | `Page` |

### dashboard/src/app/dashboard/fleet

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [page.tsx](../dashboard/src/app/dashboard/fleet/page.tsx) | 171 | 3 | `Page` |

### dashboard/src/app/dashboard/incidents

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [page.tsx](../dashboard/src/app/dashboard/incidents/page.tsx) | 180 | 3 | `Page` |

### dashboard/src/app/dashboard/reports

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [page.tsx](../dashboard/src/app/dashboard/reports/page.tsx) | 189 | 3 | `Page` |

### dashboard/src/app/dashboard/rest

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [page.tsx](../dashboard/src/app/dashboard/rest/page.tsx) | 174 | 3 | `Page` |

### dashboard/src/app/dashboard/settings

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [page.tsx](../dashboard/src/app/dashboard/settings/page.tsx) | 176 | 3 | `Page` |

### dashboard/src/app/dashboard/trips

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [page.tsx](../dashboard/src/app/dashboard/trips/page.tsx) | 172 | 3 | `Page` |

### dashboard/src/app/demo

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [page.tsx](../dashboard/src/app/demo/page.tsx) | 162 | 3 | `DemoPage` |

### dashboard/src/app/pitch

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [page.tsx](../dashboard/src/app/pitch/page.tsx) | 161 | 3 | `Page` |

### dashboard/src/components

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [demo-app.tsx](../dashboard/src/components/demo-app.tsx) | 9583 | 37 | `DemoApp`, `action` |
| [demo-rest.tsx](../dashboard/src/components/demo-rest.tsx) | 3337 | 11 | `DemoRest` |
| [incidents.tsx](../dashboard/src/components/incidents.tsx) | 6641 | 31 | `IncidentBoard`, `IncidentDetail`, `submit` |
| [operational-reports.tsx](../dashboard/src/components/operational-reports.tsx) | 6156 | 32 | `OperationalReports`, `csvExport` |
| [operations.tsx](../dashboard/src/components/operations.tsx) | 29358 | 215 | `Section`, `Client`, `Data`, `timestamp`, `parseRecord`, `Operations`, `clearStreams`, `fail` (+14 en JSON) |
| [pitch.tsx](../dashboard/src/components/pitch.tsx) | 7294 | 38 | `Pitch`, `key` |
| [ui.tsx](../dashboard/src/components/ui.tsx) | 3388 | 35 | `Mark`, `Icon`, `Badge`, `Empty`, `Stat`, `PublicHeader` |

### dashboard/src/lib

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [demo-store.ts](../dashboard/src/lib/demo-store.ts) | 1622 | 34 | `getDemoServerSnapshot`, `getDemoSnapshot`, `subscribeDemo`, `storage`, `dispatchDemo` |
| [demo.ts](../dashboard/src/lib/demo.ts) | 13500 | 156 | `DemoRestSession`, `TimelineEntry`, `DemoState`, `DemoEvent`, `initialDemo`, `demoReducer`, `restoreDemo` |
| [domain.ts](../dashboard/src/lib/domain.ts) | 4205 | 58 | `IncidentType`, `Severity`, `ActionType`, `IncidentStatus`, `SyncStatus`, `Incident`, `OperatorAction`, `Trip` (+8 en JSON) |
| [firebase.ts](../dashboard/src/lib/firebase.ts) | 2461 | 38 | `emulatorPort`, `firebaseClient`, `firebaseError` |
| [operations-model.ts](../dashboard/src/lib/operations-model.ts) | 2008 | 30 | `reportedRiskLabel`, `latestIncident`, `monitoringObservation`, `driverRows` |
| [reports.ts](../dashboard/src/lib/reports.ts) | 2922 | 41 | `IncidentFilters`, `limaDay`, `filterIncidents`, `incidentAnalytics`, `csvCell`, `incidentCsv` |

### dashboard/tests

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [demo.test.ts](../dashboard/tests/demo.test.ts) | 5525 | 83 | Configuración / recurso / documentación |
| [operations-model.test.ts](../dashboard/tests/operations-model.test.ts) | 4771 | 63 | Configuración / recurso / documentación |
| [reports.test.ts](../dashboard/tests/reports.test.ts) | 1204 | 20 | Configuración / recurso / documentación |
| [rest.test.ts](../dashboard/tests/rest.test.ts) | 3208 | 52 | Configuración / recurso / documentación |

### docs

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [APP_ESPECIFICACION_COMPLETA.md](../docs/APP_ESPECIFICACION_COMPLETA.md) | 38127 | 1063 | Configuración / recurso / documentación |
| [INFORME_COMPLETO_DRIVERAWAKEN_GUARDIAN.md](../docs/INFORME_COMPLETO_DRIVERAWAKEN_GUARDIAN.md) | 77082 | 1058 | Configuración / recurso / documentación |
| [architecture.md](../docs/architecture.md) | 9447 | 141 | Configuración / recurso / documentación |
| [change_log.md](../docs/change_log.md) | 7794 | 97 | Configuración / recurso / documentación |
| [device_test_protocol.md](../docs/device_test_protocol.md) | 5175 | 107 | Configuración / recurso / documentación |
| [firebase_setup.md](../docs/firebase_setup.md) | 5804 | 63 | Configuración / recurso / documentación |
| [guardian_audit.md](../docs/guardian_audit.md) | 4129 | 37 | Configuración / recurso / documentación |
| [initial_audit.md](../docs/initial_audit.md) | 5377 | 103 | Configuración / recurso / documentación |
| [localization.md](../docs/localization.md) | 2877 | 28 | Configuración / recurso / documentación |
| [maps_setup.md](../docs/maps_setup.md) | 3410 | 27 | Configuración / recurso / documentación |
| [ml_validation_report.md](../docs/ml_validation_report.md) | 2179 | 50 | Configuración / recurso / documentación |
| [performance_observability.md](../docs/performance_observability.md) | 5185 | 72 | Configuración / recurso / documentación |
| [phase_1_safety_report.md](../docs/phase_1_safety_report.md) | 2939 | 62 | Configuración / recurso / documentación |
| [pilot_feedback_template.md](../docs/pilot_feedback_template.md) | 1013 | 20 | Configuración / recurso / documentación |
| [privacy_policy_template.md](../docs/privacy_policy_template.md) | 4931 | 59 | Configuración / recurso / documentación |
| [release_process.md](../docs/release_process.md) | 803 | 13 | Configuración / recurso / documentación |
| [repository_migration_plan.md](../docs/repository_migration_plan.md) | 519 | 5 | Configuración / recurso / documentación |

### driveawake

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [.gitignore](../driveawake/.gitignore) | 813 | 50 | Configuración / recurso / documentación |
| [.metadata](../driveawake/.metadata) | 1706 | 45 | Configuración / recurso / documentación |
| [README.md](../driveawake/README.md) | 4232 | 123 | Configuración / recurso / documentación |
| [analysis_options.yaml](../driveawake/analysis_options.yaml) | 1448 | 28 | Configuración / recurso / documentación |
| [pubspec.lock](../driveawake/pubspec.lock) | 40113 | 1351 | Configuración / recurso / documentación |
| [pubspec.yaml](../driveawake/pubspec.yaml) | 1228 | 58 | Configuración / recurso / documentación |

### driveawake/android

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [.gitignore](../driveawake/android/.gitignore) | 267 | 14 | Configuración / recurso / documentación |
| [build.gradle.kts](../driveawake/android/build.gradle.kts) | 561 | 24 | Configuración / recurso / documentación |
| [gradle.properties](../driveawake/android/gradle.properties) | 192 | 4 | Configuración / recurso / documentación |
| [key.properties.example](../driveawake/android/key.properties.example) | 120 | - | Recurso binario |
| [settings.gradle.kts](../driveawake/android/settings.gradle.kts) | 865 | 27 | Configuración / recurso / documentación |

### driveawake/android/app

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [build.gradle.kts](../driveawake/android/app/build.gradle.kts) | 2981 | 96 | Configuración / recurso / documentación |
| [proguard-rules.pro](../driveawake/android/app/proguard-rules.pro) | 548 | - | Recurso binario |

### driveawake/android/app/src/debug

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [AndroidManifest.xml](../driveawake/android/app/src/debug/AndroidManifest.xml) | 385 | 7 | Configuración / recurso / documentación |

### driveawake/android/app/src/main

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [AndroidManifest.xml](../driveawake/android/app/src/main/AndroidManifest.xml) | 2284 | 56 | Configuración / recurso / documentación |

### driveawake/android/app/src/main/kotlin/com/magicdrive/alert

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [MainActivity.kt](../driveawake/android/app/src/main/kotlin/com/magicdrive/alert/MainActivity.kt) | 5863 | 153 | Configuración / recurso / documentación |

### driveawake/android/app/src/main/res/drawable

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [launch_background.xml](../driveawake/android/app/src/main/res/drawable/launch_background.xml) | 446 | 12 | Configuración / recurso / documentación |

### driveawake/android/app/src/main/res/drawable-v21

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [launch_background.xml](../driveawake/android/app/src/main/res/drawable-v21/launch_background.xml) | 450 | 12 | Configuración / recurso / documentación |

### driveawake/android/app/src/main/res/mipmap-hdpi

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [ic_launcher.png](../driveawake/android/app/src/main/res/mipmap-hdpi/ic_launcher.png) | 5775 | - | Recurso binario |

### driveawake/android/app/src/main/res/mipmap-mdpi

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [ic_launcher.png](../driveawake/android/app/src/main/res/mipmap-mdpi/ic_launcher.png) | 2930 | - | Recurso binario |

### driveawake/android/app/src/main/res/mipmap-xhdpi

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [ic_launcher.png](../driveawake/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png) | 9822 | - | Recurso binario |

### driveawake/android/app/src/main/res/mipmap-xxhdpi

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [ic_launcher.png](../driveawake/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png) | 21758 | - | Recurso binario |

### driveawake/android/app/src/main/res/mipmap-xxxhdpi

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [ic_launcher.png](../driveawake/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png) | 38624 | - | Recurso binario |

### driveawake/android/app/src/main/res/raw

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [magicdrive_alarm.wav](../driveawake/android/app/src/main/res/raw/magicdrive_alarm.wav) | 211724 | - | Recurso binario |

### driveawake/android/app/src/main/res/values

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [styles.xml](../driveawake/android/app/src/main/res/values/styles.xml) | 1014 | 18 | Configuración / recurso / documentación |

### driveawake/android/app/src/main/res/values-night

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [styles.xml](../driveawake/android/app/src/main/res/values-night/styles.xml) | 1013 | 18 | Configuración / recurso / documentación |

### driveawake/android/app/src/profile

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [AndroidManifest.xml](../driveawake/android/app/src/profile/AndroidManifest.xml) | 385 | 7 | Configuración / recurso / documentación |

### driveawake/android/gradle/wrapper

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [gradle-wrapper.properties](../driveawake/android/gradle/wrapper/gradle-wrapper.properties) | 206 | 5 | Configuración / recurso / documentación |

### driveawake/assets

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [logo.png](../driveawake/assets/logo.png) | 1072116 | - | Recurso binario |

### driveawake/assets/audio

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [magicdrive_alarm.wav](../driveawake/assets/audio/magicdrive_alarm.wav) | 211724 | - | Recurso binario |

### driveawake/assets/models

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [drowsiness_mlp.tflite](../driveawake/assets/models/drowsiness_mlp.tflite) | 37552 | - | Recurso binario |
| [model_manifest.json](../driveawake/assets/models/model_manifest.json) | 510 | 12 | Configuración / recurso / documentación |
| [preprocessing_metadata.json](../driveawake/assets/models/preprocessing_metadata.json) | 18410 | 747 | Configuración / recurso / documentación |

### driveawake/docs

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [PRIVACY_POLICY.md](../driveawake/docs/PRIVACY_POLICY.md) | 2760 | 84 | Configuración / recurso / documentación |
| [RELEASE_SIGNING.md](../driveawake/docs/RELEASE_SIGNING.md) | 1147 | 51 | Configuración / recurso / documentación |
| [VALIDATION_PROTOCOL.md](../driveawake/docs/VALIDATION_PROTOCOL.md) | 2245 | 60 | Configuración / recurso / documentación |
| [VALIDATION_RESULTS_2026-05-24.md](../driveawake/docs/VALIDATION_RESULTS_2026-05-24.md) | 1727 | 56 | Configuración / recurso / documentación |

### driveawake/ios

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [.gitignore](../driveawake/ios/.gitignore) | 603 | 34 | Configuración / recurso / documentación |

### driveawake/ios/Flutter

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [AppFrameworkInfo.plist](../driveawake/ios/Flutter/AppFrameworkInfo.plist) | 800 | 26 | Configuración / recurso / documentación |
| [Debug.xcconfig](../driveawake/ios/Flutter/Debug.xcconfig) | 31 | 1 | Configuración / recurso / documentación |
| [Release.xcconfig](../driveawake/ios/Flutter/Release.xcconfig) | 31 | 1 | Configuración / recurso / documentación |

### driveawake/ios/Runner

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [AppDelegate.swift](../driveawake/ios/Runner/AppDelegate.swift) | 404 | 13 | Configuración / recurso / documentación |
| [Info.plist](../driveawake/ios/Runner/Info.plist) | 1791 | 54 | Configuración / recurso / documentación |
| [Runner-Bridging-Header.h](../driveawake/ios/Runner/Runner-Bridging-Header.h) | 39 | 1 | Configuración / recurso / documentación |

### driveawake/ios/Runner.xcodeproj

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [project.pbxproj](../driveawake/ios/Runner.xcodeproj/project.pbxproj) | 24282 | 616 | Configuración / recurso / documentación |

### driveawake/ios/Runner.xcodeproj/project.xcworkspace

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [contents.xcworkspacedata](../driveawake/ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata) | 142 | - | Recurso binario |

### driveawake/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [IDEWorkspaceChecks.plist](../driveawake/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist) | 246 | 8 | Configuración / recurso / documentación |
| [WorkspaceSettings.xcsettings](../driveawake/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings) | 234 | - | Recurso binario |

### driveawake/ios/Runner.xcodeproj/xcshareddata/xcschemes

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [Runner.xcscheme](../driveawake/ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme) | 3934 | - | Recurso binario |

### driveawake/ios/Runner.xcworkspace

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [contents.xcworkspacedata](../driveawake/ios/Runner.xcworkspace/contents.xcworkspacedata) | 159 | - | Recurso binario |

### driveawake/ios/Runner.xcworkspace/xcshareddata

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [IDEWorkspaceChecks.plist](../driveawake/ios/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist) | 246 | 8 | Configuración / recurso / documentación |
| [WorkspaceSettings.xcsettings](../driveawake/ios/Runner.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings) | 234 | - | Recurso binario |

### driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [Contents.json](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json) | 2641 | 122 | Configuración / recurso / documentación |
| [Icon-App-1024x1024@1x.png](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024%401x.png) | 1002174 | - | Recurso binario |
| [Icon-App-20x20@1x.png](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20%401x.png) | 790 | - | Recurso binario |
| [Icon-App-20x20@2x.png](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20%402x.png) | 2192 | - | Recurso binario |
| [Icon-App-20x20@3x.png](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20%403x.png) | 4212 | - | Recurso binario |
| [Icon-App-29x29@1x.png](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29%401x.png) | 1348 | - | Recurso binario |
| [Icon-App-29x29@2x.png](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29%402x.png) | 3954 | - | Recurso binario |
| [Icon-App-29x29@3x.png](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29%403x.png) | 8255 | - | Recurso binario |
| [Icon-App-40x40@1x.png](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40%401x.png) | 2192 | - | Recurso binario |
| [Icon-App-40x40@2x.png](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40%402x.png) | 6955 | - | Recurso binario |
| [Icon-App-40x40@3x.png](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40%403x.png) | 15133 | - | Recurso binario |
| [Icon-App-60x60@2x.png](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60%402x.png) | 15133 | - | Recurso binario |
| [Icon-App-60x60@3x.png](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60%403x.png) | 33949 | - | Recurso binario |
| [Icon-App-76x76@1x.png](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76%401x.png) | 6352 | - | Recurso binario |
| [Icon-App-76x76@2x.png](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76%402x.png) | 24000 | - | Recurso binario |
| [Icon-App-83.5x83.5@2x.png](../driveawake/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5%402x.png) | 29307 | - | Recurso binario |

### driveawake/ios/Runner/Assets.xcassets/LaunchImage.imageset

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [Contents.json](../driveawake/ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json) | 414 | 23 | Configuración / recurso / documentación |
| [LaunchImage.png](../driveawake/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png) | 68 | - | Recurso binario |
| [LaunchImage@2x.png](../driveawake/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage%402x.png) | 68 | - | Recurso binario |
| [LaunchImage@3x.png](../driveawake/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage%403x.png) | 68 | - | Recurso binario |
| [README.md](../driveawake/ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md) | 340 | 5 | Configuración / recurso / documentación |

### driveawake/ios/Runner/Base.lproj

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [LaunchScreen.storyboard](../driveawake/ios/Runner/Base.lproj/LaunchScreen.storyboard) | 2414 | - | Recurso binario |
| [Main.storyboard](../driveawake/ios/Runner/Base.lproj/Main.storyboard) | 1631 | - | Recurso binario |

### driveawake/ios/RunnerTests

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [RunnerTests.swift](../driveawake/ios/RunnerTests/RunnerTests.swift) | 297 | 12 | Configuración / recurso / documentación |

### driveawake/lib

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [main.dart](../driveawake/lib/main.dart) | 352 | 12 | Configuración / recurso / documentación |

### driveawake/lib/app

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [app.dart](../driveawake/lib/app/app.dart) | 1316 | 39 | `AppConductoresApp` |
| [app_config.dart](../driveawake/lib/app/app_config.dart) | 225 | 7 | `AppConfig` |
| [app_theme.dart](../driveawake/lib/app/app_theme.dart) | 3433 | 115 | `RiskTheme`, `AppTheme` |

### driveawake/lib/data/database

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [database_provider.dart](../driveawake/lib/data/database/database_provider.dart) | 442 | 20 | `DatabaseProvider` |
| [driver_awake_database.dart](../driveawake/lib/data/database/driver_awake_database.dart) | 6813 | 185 | `Trips`, `TripEvents`, `SessionDrafts`, `Calibrations`, `AppSettings`, `ModelMetadata`, `FleetOutbox`, `RestSessions` (+1 en JSON) |
| [driver_awake_database.g.dart](../driveawake/lib/data/database/driver_awake_database.g.dart) | 257349 | 7749 | `TripRow`, `TripsCompanion`, `TripEventRow`, `TripEventsCompanion`, `SessionDraftRow`, `SessionDraftsCompanion`, `CalibrationRow`, `CalibrationsCompanion` (+9 en JSON) |

### driveawake/lib/data/migration

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [database_bootstrap.dart](../driveawake/lib/data/migration/database_bootstrap.dart) | 447 | 16 | `DatabaseBootstrap` |
| [legacy_preferences_migrator.dart](../driveawake/lib/data/migration/legacy_preferences_migrator.dart) | 7111 | 219 | `LegacyPreferencesMigrator` |

### driveawake/lib/data/repositories

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [drift_trip_repository.dart](../driveawake/lib/data/repositories/drift_trip_repository.dart) | 9603 | 256 | `DriftTripRepository` |

### driveawake/lib/features/drive/application

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [controlled_recovery.dart](../driveawake/lib/features/drive/application/controlled_recovery.dart) | 1027 | 35 | `RecoveryOutcome`, `RecoveryAttempt`, `ControlledRecovery` |
| [drive_ports.dart](../driveawake/lib/features/drive/application/drive_ports.dart) | 944 | 40 | `Clock`, `SystemClock`, `Logger`, `LifecycleController`, `DebugLogger` |
| [drive_repositories.dart](../driveawake/lib/features/drive/application/drive_repositories.dart) | 1884 | 66 | `CameraRepository`, `FaceDetectionRepository`, `DrowsinessAnalyzer`, `RiskEngine`, `AlarmController`, `TripRepository`, `SessionDraftRepository`, `TelemetryRepository` |
| [drive_session_controller.dart](../driveawake/lib/features/drive/application/drive_session_controller.dart) | 6912 | 228 | `DriveSessionResources`, `DriveDelay`, `DriveSessionController` |
| [drive_state.dart](../driveawake/lib/features/drive/application/drive_state.dart) | 5592 | 161 | `DriveSessionPhase`, `DriveCameraStatus`, `DriveStreamStatus`, `DriveProcessingStatus`, `DriveAlarmStatus`, `DriveThermalStatus`, `DriveState` |
| [monitoring_watchdog.dart](../driveawake/lib/features/drive/application/monitoring_watchdog.dart) | 4688 | 143 | `MonitoringHealth`, `MonitoringWatchdogConfig`, `MonitoringAssessment`, `MonitoringWatchdog` |
| [performance_monitor.dart](../driveawake/lib/features/drive/application/performance_monitor.dart) | 8472 | 321 | `ProcessingStage`, `MonotonicClock`, `StopwatchMonotonicClock`, `StageLatencyStats`, `CircularBuffer`, `PerformanceSnapshot`, `PerformanceMonitor` |

### driveawake/lib/features/drive/infrastructure

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [flutter_drive_session_resources.dart](../driveawake/lib/features/drive/infrastructure/flutter_drive_session_resources.dart) | 21764 | 655 | `FlutterDriveSessionResources` |
| [service_adapters.dart](../driveawake/lib/features/drive/infrastructure/service_adapters.dart) | 4875 | 140 | `CameraServiceAdapter`, `FaceDetectionServiceAdapter`, `DrowsinessServiceAdapter`, `AlertServiceAdapter`, `TripSessionServiceAdapter`, `TripDraftServiceAdapter`, `DeviceTelemetryServiceAdapter` |

### driveawake/lib/fleet

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [authorized_cloud_sync.dart](../driveawake/lib/fleet/authorized_cloud_sync.dart) | 1418 | 47 | `FleetSender`, `AuthorizedCloudSync` |
| [fleet_service.dart](../driveawake/lib/fleet/fleet_service.dart) | 14536 | 424 | `AssignedFleetTrip`, `FleetService` |
| [incident_classifier.dart](../driveawake/lib/fleet/incident_classifier.dart) | 2133 | 65 | `IncidentClassifier` |
| [incident_repository.dart](../driveawake/lib/fleet/incident_repository.dart) | 2309 | 72 | `IncidentRepository` |
| [local_outbox.dart](../driveawake/lib/fleet/local_outbox.dart) | 3792 | 120 | `LocalOutbox` |

### driveawake/lib/l10n

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [app_strings.dart](../driveawake/lib/l10n/app_strings.dart) | 3001 | 89 | `AppStrings`, `_MessageTemplate`, `_StringsDelegate` |
| [locale_controller.dart](../driveawake/lib/l10n/locale_controller.dart) | 1964 | 60 | `LocaleController` |
| [localized_text.dart](../driveawake/lib/l10n/localized_text.dart) | 1316 | 50 | `LocalizedText` |
| [messages.dart](../driveawake/lib/l10n/messages.dart) | 35489 | 586 | Configuración / recurso / documentación |

### driveawake/lib/models

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [app_settings.dart](../driveawake/lib/models/app_settings.dart) | 4352 | 139 | `SensitivityLevel`, `HistoryRetention`, `AppSettings` |
| [cloud_trip_report.dart](../driveawake/lib/models/cloud_trip_report.dart) | 2954 | 80 | `CloudTripReport` |
| [device_telemetry_snapshot.dart](../driveawake/lib/models/device_telemetry_snapshot.dart) | 1499 | 45 | `DeviceTelemetrySnapshot` |
| [drowsiness_event.dart](../driveawake/lib/models/drowsiness_event.dart) | 2053 | 68 | `DrowsinessEvent` |
| [drowsiness_frame_metrics.dart](../driveawake/lib/models/drowsiness_frame_metrics.dart) | 1163 | 49 | `DrowsinessFrameMetrics` |
| [drowsiness_state.dart](../driveawake/lib/models/drowsiness_state.dart) | 8998 | 272 | `DrowsinessLevel`, `DrowsinessState` |
| [ml_prediction.dart](../driveawake/lib/models/ml_prediction.dart) | 620 | 28 | `MlPrediction` |
| [technical_session_report.dart](../driveawake/lib/models/technical_session_report.dart) | 5102 | 154 | `TechnicalSessionReport` |
| [trip_session_draft.dart](../driveawake/lib/models/trip_session_draft.dart) | 3170 | 97 | `TripSessionDraft` |
| [trip_session_summary.dart](../driveawake/lib/models/trip_session_summary.dart) | 2283 | 81 | `TripSessionSummary` |

### driveawake/lib/navigation

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [guardian_map.dart](../driveawake/lib/navigation/guardian_map.dart) | 7001 | 225 | `OpenStreetMapProvider`, `GuardianMap`, `_GuardianMapState` |
| [navigation_contracts.dart](../driveawake/lib/navigation/navigation_contracts.dart) | 3556 | 142 | `GeoPoint`, `LocationFix`, `Destination`, `NearbyPlace`, `RoadRoute`, `GpsState`, `LocationProvider`, `DestinationSearchProvider` (+4 en JSON) |
| [navigation_providers.dart](../driveawake/lib/navigation/navigation_providers.dart) | 9370 | 272 | `DeviceLocationProvider`, `NoInternalRouting`, `OpenStreetMapServices` |
| [rest_recommendation_engine.dart](../driveawake/lib/navigation/rest_recommendation_engine.dart) | 2540 | 82 | `RestRecommendation`, `RestRecommendationEngine` |
| [rest_repository.dart](../driveawake/lib/navigation/rest_repository.dart) | 2779 | 87 | `RestRepository` |
| [smart_navigation.dart](../driveawake/lib/navigation/smart_navigation.dart) | 12333 | 411 | `SmartNavigation` |
| [voice_assistant.dart](../driveawake/lib/navigation/voice_assistant.dart) | 3967 | 140 | `VoiceOutput`, `LocalVoiceOutput`, `VoiceAssistant` |

### driveawake/lib/screens

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [app_entry_screen.dart](../driveawake/lib/screens/app_entry_screen.dart) | 2141 | 87 | `AppEntryScreen`, `_AppEntryScreenState` |
| [cloud_reports_screen.dart](../driveawake/lib/screens/cloud_reports_screen.dart) | 12838 | 342 | `CloudReportsScreen`, `_CloudReportsScreenState` |
| [drive_mode_screen.dart](../driveawake/lib/screens/drive_mode_screen.dart) | 38912 | 1087 | `DriveModeScreen`, `_DriveModeScreenState`, `_ExitAction`, `_DriveBackdrop`, `_DriveTopBar`, `_CameraViewfinder`, `_CameraPreviewCover`, `_Chip` (+9 en JSON) |
| [fleet_screen.dart](../driveawake/lib/screens/fleet_screen.dart) | 7090 | 186 | `FleetScreen`, `_FleetScreenState` |
| [history_screen.dart](../driveawake/lib/screens/history_screen.dart) | 20569 | 622 | `HistoryScreen`, `_HistoryScreenState`, `_ExportFormat`, `_HistoryDayGroup`, `_FilterBar`, `_DaySection`, `_EventTile`, `_EmptyHistory` (+1 en JSON) |
| [home_screen.dart](../driveawake/lib/screens/home_screen.dart) | 63982 | 2088 | `HomeScreen`, `_HomeScreenState`, `_DashboardBackdrop`, `_DashboardBackdropPainter`, `_DashboardTopBar`, `_GradientTitle`, `_GlassIconButton`, `_IntroMonitoringPanel` (+23 en JSON) |
| [login_screen.dart](../driveawake/lib/screens/login_screen.dart) | 12478 | 326 | `LoginScreen`, `_LoginScreenState` |
| [navigation_screen.dart](../driveawake/lib/screens/navigation_screen.dart) | 19286 | 487 | `NavigationScreen`, `_NavigationScreenState` |
| [privacy_policy_screen.dart](../driveawake/lib/screens/privacy_policy_screen.dart) | 8626 | 174 | `PrivacyPolicyScreen`, `_PolicyHeader`, `_NoticeCard`, `_PolicySection` |
| [saved_trips_screen.dart](../driveawake/lib/screens/saved_trips_screen.dart) | 3719 | 106 | `SavedTripsScreen`, `_SavedTripsScreenState` |
| [settings_screen.dart](../driveawake/lib/screens/settings_screen.dart) | 10913 | 312 | `SettingsScreen`, `_SettingsScreenState`, `_SectionTitle`, `_SettingsCard` |
| [trip_summary_screen.dart](../driveawake/lib/screens/trip_summary_screen.dart) | 10151 | 288 | `TripSummaryScreen`, `_SummaryGrid`, `_SummaryTile`, `_SummaryItem` |

### driveawake/lib/services

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [account_session.dart](../driveawake/lib/services/account_session.dart) | 218 | 6 | `AccountSession` |
| [alarm_service.dart](../driveawake/lib/services/alarm_service.dart) | 73 | 3 | `AlarmService` |
| [alert_service.dart](../driveawake/lib/services/alert_service.dart) | 5176 | 198 | `AlertService`, `AlertActuator`, `DeviceAlertActuator`, `AlertCooldownGate` |
| [calibration_service.dart](../driveawake/lib/services/calibration_service.dart) | 12187 | 392 | `CalibrationService`, `CalibrationObservation` |
| [camera_service.dart](../driveawake/lib/services/camera_service.dart) | 3791 | 129 | `CameraService` |
| [cloud_report_service.dart](../driveawake/lib/services/cloud_report_service.dart) | 6712 | 192 | `CloudReportService` |
| [device_telemetry_service.dart](../driveawake/lib/services/device_telemetry_service.dart) | 1882 | 76 | `DeviceTelemetryService` |
| [drowsiness_engine.dart](../driveawake/lib/services/drowsiness_engine.dart) | 9653 | 343 | `DrowsinessEngine`, `DrowsinessSignalSnapshot`, `RiskDecision`, `RollingValueSmoother`, `DurationTracker` |
| [drowsiness_model_service.dart](../driveawake/lib/services/drowsiness_model_service.dart) | 7830 | 226 | `DrowsinessModelService` |
| [drowsiness_service.dart](../driveawake/lib/services/drowsiness_service.dart) | 19106 | 623 | `DrowsinessService` |
| [emergency_service.dart](../driveawake/lib/services/emergency_service.dart) | 1288 | 39 | `EmergencyService` |
| [face_detection_service.dart](../driveawake/lib/services/face_detection_service.dart) | 614 | 24 | `FaceDetectionService` |
| [feature_window_service.dart](../driveawake/lib/services/feature_window_service.dart) | 11653 | 345 | `FeatureWindowService` |
| [history_export_service.dart](../driveawake/lib/services/history_export_service.dart) | 17150 | 575 | `HistoryExportService`, `_DailySummary`, `_MetricSummary` |
| [local_history_service.dart](../driveawake/lib/services/local_history_service.dart) | 4389 | 128 | `LocalHistoryService` |
| [model_input_preprocessor.dart](../driveawake/lib/services/model_input_preprocessor.dart) | 1654 | 46 | `ModelInputPreprocessor` |
| [personal_calibration_service.dart](../driveawake/lib/services/personal_calibration_service.dart) | 4347 | 161 | `PersonalCalibrationService`, `_CalibrationSample` |
| [settings_service.dart](../driveawake/lib/services/settings_service.dart) | 3082 | 98 | `SettingsService` |
| [technical_report_export_service.dart](../driveawake/lib/services/technical_report_export_service.dart) | 1414 | 47 | `ShareConfirmation`, `TechnicalReportExportService` |
| [trip_session_draft_service.dart](../driveawake/lib/services/trip_session_draft_service.dart) | 1674 | 56 | `TripSessionDraftService` |
| [trip_session_service.dart](../driveawake/lib/services/trip_session_service.dart) | 11802 | 382 | `TripSessionService` |

### driveawake/lib/utils

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [adaptive_frame_scheduler.dart](../driveawake/lib/utils/adaptive_frame_scheduler.dart) | 2337 | 79 | `ThermalLoad`, `AdaptiveFrameScheduler` |
| [drowsiness_thresholds.dart](../driveawake/lib/utils/drowsiness_thresholds.dart) | 1615 | 33 | `DrowsinessThresholds` |
| [input_image_converter.dart](../driveawake/lib/utils/input_image_converter.dart) | 4527 | 159 | `InputImageConverter`, `_ImageBytes` |
| [perclos_tracker.dart](../driveawake/lib/utils/perclos_tracker.dart) | 5092 | 168 | `PerclosTracker`, `PerclosSnapshot`, `PerclosSample` |

### driveawake/lib/widgets

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [account_card.dart](../driveawake/lib/widgets/account_card.dart) | 2442 | 75 | `AccountCard` |
| [alert_overlay.dart](../driveawake/lib/widgets/alert_overlay.dart) | 5650 | 138 | `AlertOverlay` |
| [debug_metrics_panel.dart](../driveawake/lib/widgets/debug_metrics_panel.dart) | 7334 | 229 | `DebugMetricsPanel`, `_MetricTile`, `_Metric` |
| [face_landmark_overlay.dart](../driveawake/lib/widgets/face_landmark_overlay.dart) | 10184 | 324 | `FaceLandmarkOverlayData`, `FaceLandmarkOverlayPainter` |
| [guardian_navigation_card.dart](../driveawake/lib/widgets/guardian_navigation_card.dart) | 3845 | 107 | `GuardianNavigationCard` |
| [language_selector.dart](../driveawake/lib/widgets/language_selector.dart) | 1492 | 48 | `LanguageSelector` |
| [navigation_readout.dart](../driveawake/lib/widgets/navigation_readout.dart) | 4548 | 137 | `NavigationReadout`, `_NavigationReadoutState` |
| [status_card.dart](../driveawake/lib/widgets/status_card.dart) | 7036 | 212 | `StatusCard`, `_RiskBadge`, `_RiskBar` |

### driveawake/linux

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [.gitignore](../driveawake/linux/.gitignore) | 19 | 1 | Configuración / recurso / documentación |
| [CMakeLists.txt](../driveawake/linux/CMakeLists.txt) | 4887 | 128 | Configuración / recurso / documentación |

### driveawake/linux/flutter

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [CMakeLists.txt](../driveawake/linux/flutter/CMakeLists.txt) | 2903 | 88 | Configuración / recurso / documentación |
| [generated_plugin_registrant.cc](../driveawake/linux/flutter/generated_plugin_registrant.cc) | 736 | 19 | Configuración / recurso / documentación |
| [generated_plugin_registrant.h](../driveawake/linux/flutter/generated_plugin_registrant.h) | 303 | 15 | Configuración / recurso / documentación |
| [generated_plugins.cmake](../driveawake/linux/flutter/generated_plugins.cmake) | 800 | 26 | Configuración / recurso / documentación |

### driveawake/linux/runner

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [CMakeLists.txt](../driveawake/linux/runner/CMakeLists.txt) | 1000 | 26 | Configuración / recurso / documentación |
| [main.cc](../driveawake/linux/runner/main.cc) | 186 | 6 | Configuración / recurso / documentación |
| [my_application.cc](../driveawake/linux/runner/my_application.cc) | 5498 | 144 | Configuración / recurso / documentación |
| [my_application.h](../driveawake/linux/runner/my_application.h) | 406 | 18 | Configuración / recurso / documentación |

### driveawake/macos

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [.gitignore](../driveawake/macos/.gitignore) | 96 | 7 | Configuración / recurso / documentación |

### driveawake/macos/Flutter

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [Flutter-Debug.xcconfig](../driveawake/macos/Flutter/Flutter-Debug.xcconfig) | 49 | 1 | Configuración / recurso / documentación |
| [Flutter-Release.xcconfig](../driveawake/macos/Flutter/Flutter-Release.xcconfig) | 49 | 1 | Configuración / recurso / documentación |
| [GeneratedPluginRegistrant.swift](../driveawake/macos/Flutter/GeneratedPluginRegistrant.swift) | 1583 | 34 | Configuración / recurso / documentación |

### driveawake/macos/Runner

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [AppDelegate.swift](../driveawake/macos/Runner/AppDelegate.swift) | 324 | 13 | Configuración / recurso / documentación |
| [DebugProfile.entitlements](../driveawake/macos/Runner/DebugProfile.entitlements) | 360 | - | Recurso binario |
| [Info.plist](../driveawake/macos/Runner/Info.plist) | 1092 | 32 | Configuración / recurso / documentación |
| [MainFlutterWindow.swift](../driveawake/macos/Runner/MainFlutterWindow.swift) | 403 | 15 | Configuración / recurso / documentación |
| [Release.entitlements](../driveawake/macos/Runner/Release.entitlements) | 248 | - | Recurso binario |

### driveawake/macos/Runner.xcodeproj

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [project.pbxproj](../driveawake/macos/Runner.xcodeproj/project.pbxproj) | 27090 | 705 | Configuración / recurso / documentación |

### driveawake/macos/Runner.xcodeproj/project.xcworkspace/xcshareddata

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [IDEWorkspaceChecks.plist](../driveawake/macos/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist) | 246 | 8 | Configuración / recurso / documentación |

### driveawake/macos/Runner.xcodeproj/xcshareddata/xcschemes

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [Runner.xcscheme](../driveawake/macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme) | 3798 | - | Recurso binario |

### driveawake/macos/Runner.xcworkspace

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [contents.xcworkspacedata](../driveawake/macos/Runner.xcworkspace/contents.xcworkspacedata) | 159 | - | Recurso binario |

### driveawake/macos/Runner.xcworkspace/xcshareddata

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [IDEWorkspaceChecks.plist](../driveawake/macos/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist) | 246 | 8 | Configuración / recurso / documentación |

### driveawake/macos/Runner/Assets.xcassets/AppIcon.appiconset

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [Contents.json](../driveawake/macos/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json) | 1359 | 68 | Configuración / recurso / documentación |
| [app_icon_1024.png](../driveawake/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png) | 1002174 | - | Recurso binario |
| [app_icon_128.png](../driveawake/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png) | 17176 | - | Recurso binario |
| [app_icon_16.png](../driveawake/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png) | 611 | - | Recurso binario |
| [app_icon_256.png](../driveawake/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png) | 69298 | - | Recurso binario |
| [app_icon_32.png](../driveawake/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png) | 1579 | - | Recurso binario |
| [app_icon_512.png](../driveawake/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png) | 272475 | - | Recurso binario |
| [app_icon_64.png](../driveawake/macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png) | 4716 | - | Recurso binario |

### driveawake/macos/Runner/Base.lproj

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [MainMenu.xib](../driveawake/macos/Runner/Base.lproj/MainMenu.xib) | 24072 | - | Recurso binario |

### driveawake/macos/Runner/Configs

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [AppInfo.xcconfig](../driveawake/macos/Runner/Configs/AppInfo.xcconfig) | 622 | 14 | Configuración / recurso / documentación |
| [Debug.xcconfig](../driveawake/macos/Runner/Configs/Debug.xcconfig) | 79 | 2 | Configuración / recurso / documentación |
| [Release.xcconfig](../driveawake/macos/Runner/Configs/Release.xcconfig) | 81 | 2 | Configuración / recurso / documentación |
| [Warnings.xcconfig](../driveawake/macos/Runner/Configs/Warnings.xcconfig) | 593 | 13 | Configuración / recurso / documentación |

### driveawake/macos/RunnerTests

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [RunnerTests.swift](../driveawake/macos/RunnerTests/RunnerTests.swift) | 302 | 12 | Configuración / recurso / documentación |

### driveawake/test

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [adaptive_frame_scheduler_test.dart](../driveawake/test/adaptive_frame_scheduler_test.dart) | 2138 | 77 | Configuración / recurso / documentación |
| [alert_cooldown_test.dart](../driveawake/test/alert_cooldown_test.dart) | 475 | 13 | Configuración / recurso / documentación |
| [alert_service_test.dart](../driveawake/test/alert_service_test.dart) | 1423 | 60 | `_FakeAlertActuator` |
| [cloud_trip_report_test.dart](../driveawake/test/cloud_trip_report_test.dart) | 2810 | 99 | Configuración / recurso / documentación |
| [controlled_recovery_test.dart](../driveawake/test/controlled_recovery_test.dart) | 2435 | 92 | Configuración / recurso / documentación |
| [drift_persistence_test.dart](../driveawake/test/drift_persistence_test.dart) | 10548 | 262 | Configuración / recurso / documentación |
| [drive_mode_screen_test.dart](../driveawake/test/drive_mode_screen_test.dart) | 4412 | 135 | `_WidgetResources` |
| [drive_session_controller_test.dart](../driveawake/test/drive_session_controller_test.dart) | 7305 | 234 | `_FakeResources` |
| [drowsiness_engine_test.dart](../driveawake/test/drowsiness_engine_test.dart) | 4070 | 133 | Configuración / recurso / documentación |
| [emergency_service_test.dart](../driveawake/test/emergency_service_test.dart) | 1783 | 41 | Configuración / recurso / documentación |
| [fleet_outbox_test.dart](../driveawake/test/fleet_outbox_test.dart) | 10383 | 336 | Configuración / recurso / documentación |
| [history_retention_test.dart](../driveawake/test/history_retention_test.dart) | 1660 | 45 | Configuración / recurso / documentación |
| [home_camera_startup_test.dart](../driveawake/test/home_camera_startup_test.dart) | 5574 | 171 | `_Camera`, `_Drowsiness` |
| [local_history_fallback_test.dart](../driveawake/test/local_history_fallback_test.dart) | 1671 | 43 | Configuración / recurso / documentación |
| [localization_test.dart](../driveawake/test/localization_test.dart) | 7628 | 224 | `_Session` |
| [localized_export_test.dart](../driveawake/test/localized_export_test.dart) | 2455 | 71 | Configuración / recurso / documentación |
| [model_input_preprocessor_test.dart](../driveawake/test/model_input_preprocessor_test.dart) | 2713 | 84 | Configuración / recurso / documentación |
| [monitoring_watchdog_test.dart](../driveawake/test/monitoring_watchdog_test.dart) | 3388 | 112 | `PerformanceFixture`, `FakeClock` |
| [navigation_live_test.dart](../driveawake/test/navigation_live_test.dart) | 2337 | 58 | `_RealNetwork` |
| [perclos_tracker_test.dart](../driveawake/test/perclos_tracker_test.dart) | 5381 | 179 | Configuración / recurso / documentación |
| [performance_monitor_test.dart](../driveawake/test/performance_monitor_test.dart) | 3594 | 111 | `FakeMonotonicClock` |
| [privacy_policy_screen_test.dart](../driveawake/test/privacy_policy_screen_test.dart) | 886 | 24 | Configuración / recurso / documentación |
| [recovery_alarm_integration_test.dart](../driveawake/test/recovery_alarm_integration_test.dart) | 4649 | 160 | `FakeMonotonicClock`, `FakeWallClock`, `FakeCamera`, `FakeFaceDetection`, `FakeAnalyzer`, `FakeAlarm`, `FakeTrip`, `FakeTelemetry` |
| [settings_migration_test.dart](../driveawake/test/settings_migration_test.dart) | 1456 | 43 | Configuración / recurso / documentación |
| [signal_status_card_test.dart](../driveawake/test/signal_status_card_test.dart) | 1198 | 36 | Configuración / recurso / documentación |
| [smart_navigation_test.dart](../driveawake/test/smart_navigation_test.dart) | 12872 | 417 | `_Location`, `_DelayedLocation`, `_DelayedStopLocation` |
| [technical_session_report_test.dart](../driveawake/test/technical_session_report_test.dart) | 1670 | 47 | Configuración / recurso / documentación |
| [trip_session_draft_test.dart](../driveawake/test/trip_session_draft_test.dart) | 1837 | 60 | Configuración / recurso / documentación |
| [voice_assistant_test.dart](../driveawake/test/voice_assistant_test.dart) | 3464 | 107 | `_Output` |
| [widget_test.dart](../driveawake/test/widget_test.dart) | 6391 | 204 | `_Session` |

### driveawake/web

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [favicon.png](../driveawake/web/favicon.png) | 1579 | - | Recurso binario |
| [index.html](../driveawake/web/index.html) | 1295 | 38 | Configuración / recurso / documentación |
| [manifest.json](../driveawake/web/manifest.json) | 990 | 35 | Configuración / recurso / documentación |

### driveawake/web/icons

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [Icon-192.png](../driveawake/web/icons/Icon-192.png) | 38624 | - | Recurso binario |
| [Icon-512.png](../driveawake/web/icons/Icon-512.png) | 272475 | - | Recurso binario |
| [Icon-maskable-192.png](../driveawake/web/icons/Icon-maskable-192.png) | 38624 | - | Recurso binario |
| [Icon-maskable-512.png](../driveawake/web/icons/Icon-maskable-512.png) | 272475 | - | Recurso binario |

### driveawake/windows

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [.gitignore](../driveawake/windows/.gitignore) | 308 | 17 | Configuración / recurso / documentación |
| [CMakeLists.txt](../driveawake/windows/CMakeLists.txt) | 4264 | 108 | Configuración / recurso / documentación |

### driveawake/windows/flutter

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [CMakeLists.txt](../driveawake/windows/flutter/CMakeLists.txt) | 3851 | 109 | Configuración / recurso / documentación |
| [generated_plugin_registrant.cc](../driveawake/windows/flutter/generated_plugin_registrant.cc) | 1691 | 38 | Configuración / recurso / documentación |
| [generated_plugin_registrant.h](../driveawake/windows/flutter/generated_plugin_registrant.h) | 302 | 15 | Configuración / recurso / documentación |
| [generated_plugins.cmake](../driveawake/windows/flutter/generated_plugins.cmake) | 933 | 33 | Configuración / recurso / documentación |

### driveawake/windows/runner

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [CMakeLists.txt](../driveawake/windows/runner/CMakeLists.txt) | 1836 | 40 | Configuración / recurso / documentación |
| [Runner.rc](../driveawake/windows/runner/Runner.rc) | 3160 | - | Recurso binario |
| [flutter_window.cpp](../driveawake/windows/runner/flutter_window.cpp) | 2193 | 71 | Configuración / recurso / documentación |
| [flutter_window.h](../driveawake/windows/runner/flutter_window.h) | 961 | 33 | Configuración / recurso / documentación |
| [main.cpp](../driveawake/windows/runner/main.cpp) | 1307 | 43 | Configuración / recurso / documentación |
| [resource.h](../driveawake/windows/runner/resource.h) | 448 | 16 | Configuración / recurso / documentación |
| [runner.exe.manifest](../driveawake/windows/runner/runner.exe.manifest) | 616 | - | Recurso binario |
| [utils.cpp](../driveawake/windows/runner/utils.cpp) | 1862 | 65 | Configuración / recurso / documentación |
| [utils.h](../driveawake/windows/runner/utils.h) | 691 | 19 | Configuración / recurso / documentación |
| [win32_window.cpp](../driveawake/windows/runner/win32_window.cpp) | 8822 | 288 | Configuración / recurso / documentación |
| [win32_window.h](../driveawake/windows/runner/win32_window.h) | 3624 | 102 | Configuración / recurso / documentación |

### driveawake/windows/runner/resources

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [app_icon.ico](../driveawake/windows/runner/resources/app_icon.ico) | 96412 | - | Recurso binario |

### scripts

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [check_repository_hygiene.py](../scripts/check_repository_hygiene.py) | 1458 | 52 | `tracked_files`, `violations`, `main` |
| [firebase_smoke_test.mjs](../scripts/firebase_smoke_test.mjs) | 5113 | 87 | `request`, `field` |

### shared/model_contract

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [README.md](../shared/model_contract/README.md) | 565 | 11 | Configuración / recurso / documentación |
| [feature_schema.json](../shared/model_contract/feature_schema.json) | 26643 | 1278 | Configuración / recurso / documentación |
| [model_contract.json](../shared/model_contract/model_contract.json) | 6907 | 240 | Configuración / recurso / documentación |

### shared/test_vectors

| Archivo | Bytes | Líneas | Declaraciones principales |
| --- | ---: | ---: | --- |
| [expected_base_features.json](../shared/test_vectors/expected_base_features.json) | 123 | 6 | Configuración / recurso / documentación |
| [expected_probabilities.json](../shared/test_vectors/expected_probabilities.json) | 218 | 6 | Configuración / recurso / documentación |
| [expected_scaled_input.json](../shared/test_vectors/expected_scaled_input.json) | 4673 | 186 | Configuración / recurso / documentación |
| [expected_temporal_features.json](../shared/test_vectors/expected_temporal_features.json) | 199 | 5 | Configuración / recurso / documentación |
| [frame_metrics.json](../shared/test_vectors/frame_metrics.json) | 194 | 5 | Configuración / recurso / documentación |
| [manifest.json](../shared/test_vectors/manifest.json) | 463 | 15 | Configuración / recurso / documentación |
| [raw_features.json](../shared/test_vectors/raw_features.json) | 7502 | 186 | Configuración / recurso / documentación |

## Pruebas declaradas por archivo

No sustituye el conteo ejecutado: parametrización, loops y proyectos de navegador pueden multiplicar casos.

### `backend/tests/firestore.test.mjs`

- unauthenticated users cannot access tenant or personal data
- tenant isolation for driver and operator, including queries
- driver cannot elevate role, bootstrap org, create trips or forge assignments
- only ADMIN manages valid members vehicles assignments and assigned trips
- driver publishes valid immutable incident only for assigned active trip
- invalid incident fields values times and missing trip rejected
- unavailable signal is INFO with zero fatigue risk
- operator actions append with authenticated identity, never rewrite detection
- trip lifecycle prevents reassignment timestamps spoofing and resurrection
- delayed health keeps its observed time and cannot move backwards
- revoked membership blocks pending publication
- real emulator flow: assigned trip → incident → idempotent retry → acknowledgement → action history
- personal reports remain owner-only with original validated schema
- completed voluntary rests are validated, immutable and tenant-scoped
- late rest sync remains possible for own completed trip within its interval

### `dashboard/e2e/emulator.spec.ts`

- operator sees driver-SDK event, appends a response, and selection survives navigation
- driver cannot open operations central
- operator sees actual driver membership, rest and consistently filtered report export
- operator reads completed self-declared rest from driver SDK without edit controls
- administrator registers vehicle, membership and assigned trip

### `dashboard/e2e/public.spec.ts`

- public landing navigates to isolated demo, no Firebase requests
- offline → persisted incident → reconnect → human action → complete → reset
- caution cooldown groups duplicate events
- synthetic destination and voluntary rest never imply real navigation or recovery
- pitch has ten slides, keyboard controls and working demo link
- protected routes require configuration or an authenticated session
- main public pages fit the viewport and support keyboard focus

### `driveawake/test/adaptive_frame_scheduler_test.dart`

- uses 4-5 FPS during normal monitoring
- raises sampling while suspicious and throttles on heat
- uses hysteresis before leaving critical thermal load
- reduces FPS on low battery when not charging

### `driveawake/test/alert_cooldown_test.dart`

- cooldown evita disparos repetidos

### `driveawake/test/alert_service_test.dart`

- stopAllAlerts detiene audio y vibracion de forma idempotente
- dispose detiene alertas y libera el actuador

### `driveawake/test/cloud_trip_report_test.dart`

- report round trip preserves timing, risk, counts and optional telemetry
- cloud payload has an explicit schema without frames, location or credentials
- repeated backup uses the same ID after decoding persisted data
- unknown report versions are rejected
- timeout message does not claim a queued cloud write was cancelled

### `driveawake/test/controlled_recovery_test.dart`

- successful recovery stops after first valid attempt
- exhausted recovery is limited and uses growing backoff
- pause during recovery invalidates the pending generation
- background before recovery prevents camera attempt
- finish during recovery prevents further attempts

### `driveawake/test/drift_persistence_test.dart`

- migra datos realistas, conserva corruptos y marca finalizacion
- ejecutar migracion dos veces no duplica eventos
- JSON global corrupto no bloquea la migracion
- finalizar guarda viaje y elimina borrador atomico
- informes recuperan m?tricas sin incluir viajes activos y respetan borrado
- recupera borrador despues de recrear repositorio
- descartar elimina borrador, viaje y eventos asociados
- retencion elimina viaje vencido y conserva el reciente
- datos sobreviven reinicio de la base SQLite

### `driveawake/test/drive_mode_screen_test.dart`

- la pantalla observa estado y envia pausa al controlador
- estado NORMAL is prohibited when monitoring is unavailable
- finish requires confirmation and cancel retains the trip
- compact landscape layout keeps primary controls visible without overflow

### `driveawake/test/drive_session_controller_test.dart`

- inicia una sesion y activa monitoreo
- pausa doble es idempotente
- reanudacion doble ejecuta una unica cuenta y stream
- background durante reanudacion cancela el inicio
- finalizacion doble es idempotente
- descarte usa una sola ruta y no finaliza
- error de camara queda como recuperable y limpia recursos
- error de procesamiento repetido se propaga desde recursos
- pausa silencia una alarma activa

### `driveawake/test/drowsiness_engine_test.dart`

- ojos cerrados mas de 3 segundos fuerza peligro
- modelo somnoliento con baja confianza no decide solo
- modelo con confianza alta suma riesgo sin saltar a peligro solo
- mala iluminacion no genera peligro por si sola
- sin rostro no infiere somnolencia incluso después de peligro

### `driveawake/test/emergency_service_test.dart`

- emergency contact remains local, validates digits and can be removed
- dialer passes a validated contact or opens an empty dialer

### `driveawake/test/fleet_outbox_test.dart`

- stable IDs deduplicate without modifying original payload
- offline failure persists with bounded exponential backoff; reconnect retries same ID
- lost acknowledgement does not create a second server incident
- revoked consent blocks sends and removes local queue
- data erased after worker snapshot is not sent
- FIFO keeps completion behind failed incident, batches at most ten
- retention applies to queued and synced records
- outbox survives SQLite file close/reopen and v1 migration preserves history
- incident cooldown survives repository restart and critical escalation bypasses it
- missing face is signal unavailable, never fatigue or critical evidence
- classifier requires reliable visible face and repeated yawns, ignores aggregate alarms

### `driveawake/test/history_retention_test.dart`

- retention removes expired events from persistent storage

### `driveawake/test/home_camera_startup_test.dart`

- abre cámara al inicio y continúa después de 25 segundos
- pausa en segundo plano y reinicia al volver
- diálogo de permiso no duplica inicialización pendiente
- permission denial shows retry without a zero risk reading
- background during opening cancels stream and resume opens once

### `driveawake/test/local_history_fallback_test.dart`

- async SQLite read error reaches legacy history fallback with no retention query

### `driveawake/test/localization_test.dart`

- language preference survives a new controller and resolves device locale
- catalog preserves every placeholder and translates dynamic messages
- selector translates login in place, preserving entered data and validation
- locale changes preserve the active route and translate constant privacy sections
- account and safety messages fit a narrow phone in $language

### `driveawake/test/localized_export_test.dart`

- PDF contains $language labels and translates existing stored notes

### `driveawake/test/model_input_preprocessor_test.dart`

- golden compartido conserva orden, imputacion y escalado
- rechaza metadata con longitudes incompatibles
- imputa NaN antes de escalar

### `driveawake/test/monitoring_watchdog_test.dart`

- healthy with recent valid frames and acceptable latency
- degraded when total P95 is high
- degraded when drop ratio is excessive
- recovering has explicit priority
- unavailable after recovery attempts are exhausted
- unavailable when valid frame is critically stale

### `driveawake/test/navigation_live_test.dart`

- live OSM destination, nearby response and one actual PNG tile

### `driveawake/test/perclos_tracker_test.dart`

- calcula ojos cerrados continuos
- calcula ojos abiertos continuos
- calcula cambio abierto a cerrado ponderado por tiempo
- rostro ausente rompe el segmento entre muestras validas
- intervalo superior a 600 ms no se integra
- timestamps duplicados o fuera de orden se ignoran
- tracker vacio devuelve snapshot determinista
- cobertura insuficiente no habilita PERCLOS
- reset elimina muestras y estado de suficiencia
- pausa y reanudacion pueden reiniciar el tracker

### `driveawake/test/performance_monitor_test.dart`

- percentiles with zero samples are zero
- percentiles with one sample equal that sample
- circular buffer keeps only newest samples in order
- reset clears counters, timestamps and latency samples
- tracks busy and scheduler drops separately
- negative out-of-order latency is ignored
- actual FPS uses monotonic processed-frame timestamps
- frames without a face do not count as a valid monitoring frame

### `driveawake/test/privacy_policy_screen_test.dart`

- privacy notice is honest about pending legal identity

### `driveawake/test/recovery_alarm_integration_test.dart`

- alarm is stopped when watchdog enters recovery

### `driveawake/test/settings_migration_test.dart`

- migrates legacy settings without losing values
- old maps receive safe retention default

### `driveawake/test/signal_status_card_test.dart`

- unreliable observation is not presented as normal; reliable critical warning remains

### `driveawake/test/smart_navigation_test.dart`

- a late foreground stop cannot undo a newer background stop
- background invalidates a GPS permission request still in flight
- only valid recent accurate GPS is usable; unknown speed remains unknown
- external navigation URI uses bounded coordinates and safe parameters
- no internal route provider returns no invented road distance or ETA
- GPS authorization ${state.name} never starts a position stream
- GPS stream staleness and app background clear live position
- destination search is explicit bounded cached and URL encoded
- empty destination is a genuine empty result; invalid request avoids network
- provider HTTP $code surfaces failure without fabricated results
- offline search and malformed server JSON are handled
- nearby query is limited/cached; missing truck suitability stays unknown
- critical recommendation is immediate and does not need GPS or a place search
- missing face never becomes a fatigue diagnosis; warning needs sustained window
- declared rest persists, cannot duplicate open interval, and closes idempotently

### `driveawake/test/technical_session_report_test.dart`

- technical report exports sanitized JSON without sensitive data

### `driveawake/test/trip_session_draft_test.dart`

- serializa y restaura todos los contadores del borrador
- servicio guarda, carga y elimina un borrador

### `driveawake/test/voice_assistant_test.dart`

- pause cancels speech waiting for offline engine configuration
- critical speech bypasses global cooldown and cancels lower priority
- selected English locale translates the safety message
- missing offline voice remains recoverable without consuming cooldown
- disabling voice invalidates pending speech

### `driveawake/test/widget_test.dart`

- signed out launch shows login and allows local use
- restored session opens dashboard
- guest can enter while account restoration is pending
- valid login enters dashboard; empty fields never call auth
- registration checks confirmation and keeps login on network failure
- account actions fit a narrow phone and have visible labels

## Tablas SQLite y columnas

### Trips

| Columna Dart | Tipo de columna |
| --- | --- |
| `id` | `TextColumn` |
| `startedAt` | `DateTimeColumn` |
| `endedAt` | `DateTimeColumn` |
| `status` | `TextColumn` |
| `drivingDurationMs` | `IntColumn` |
| `warningAlerts` | `IntColumn` |
| `dangerAlerts` | `IntColumn` |
| `yawnCount` | `IntColumn` |
| `noFaceEvents` | `IntColumn` |
| `normalSamples` | `IntColumn` |
| `warningSamples` | `IntColumn` |
| `dangerSamples` | `IntColumn` |
| `sampleCount` | `IntColumn` |
| `riskSum` | `RealColumn` |
| `maxRisk` | `RealColumn` |
| `closedEyeDurationMs` | `IntColumn` |
| `startBatteryLevel` | `RealColumn` |
| `endBatteryLevel` | `RealColumn` |
| `startTemperatureC` | `RealColumn` |
| `endTemperatureC` | `RealColumn` |
| `maxTemperatureC` | `RealColumn` |
| `isCharging` | `BoolColumn` |
| `createdAt` | `DateTimeColumn` |
| `updatedAt` | `DateTimeColumn` |

### TripEvents

| Columna Dart | Tipo de columna |
| --- | --- |
| `id` | `TextColumn` |
| `tripId` | `TextColumn` |
| `occurredAt` | `DateTimeColumn` |
| `level` | `TextColumn` |
| `eventType` | `TextColumn` |
| `durationSeconds` | `RealColumn` |
| `riskScore` | `RealColumn` |
| `perclos` | `RealColumn` |
| `modelPrediction` | `TextColumn` |
| `modelConfidence` | `RealColumn` |
| `notes` | `TextColumn` |
| `createdAt` | `DateTimeColumn` |

### SessionDrafts

| Columna Dart | Tipo de columna |
| --- | --- |
| `tripId` | `TextColumn` |
| `payloadJson` | `TextColumn` |
| `startedAt` | `DateTimeColumn` |
| `updatedAt` | `DateTimeColumn` |
| `incomplete` | `BoolColumn` |

### Calibrations

| Columna Dart | Tipo de columna |
| --- | --- |
| `id` | `TextColumn` |
| `version` | `IntColumn` |
| `payloadJson` | `TextColumn` |
| `updatedAt` | `DateTimeColumn` |

### AppSettings

| Columna Dart | Tipo de columna |
| --- | --- |
| `id` | `TextColumn` |
| `version` | `IntColumn` |
| `payloadJson` | `TextColumn` |
| `updatedAt` | `DateTimeColumn` |

### ModelMetadata

| Columna Dart | Tipo de columna |
| --- | --- |
| `id` | `TextColumn` |
| `payloadJson` | `TextColumn` |
| `updatedAt` | `DateTimeColumn` |

### FleetOutbox

| Columna Dart | Tipo de columna |
| --- | --- |
| `id` | `TextColumn` |
| `organizationId` | `TextColumn` |
| `ownerId` | `TextColumn` |
| `cloudTripId` | `TextColumn` |
| `localTripId` | `TextColumn` |
| `kind` | `TextColumn` |
| `payloadJson` | `TextColumn` |
| `syncStatus` | `TextColumn` |
| `attempts` | `IntColumn` |
| `nextAttemptAt` | `DateTimeColumn` |
| `createdAt` | `DateTimeColumn` |
| `updatedAt` | `DateTimeColumn` |
| `lastError` | `TextColumn` |

### RestSessions

| Columna Dart | Tipo de columna |
| --- | --- |
| `id` | `TextColumn` |
| `tripId` | `TextColumn` |
| `startedAt` | `DateTimeColumn` |
| `endedAt` | `DateTimeColumn` |
| `durationMs` | `IntColumn` |
| `recommendationReason` | `TextColumn` |
| `voluntarilyConfirmed` | `BoolColumn` |
| `fleetBindingJson` | `TextColumn` |

## Artefacto debug observado

- Ruta: `driveawake/build/app/outputs/flutter-apk/app-debug.apk`.
- Tamaño: 242,518,875 bytes.
- SHA-256: `a7898fce0b4bd9c9e5f0a84bd298f254662ceef6fda323293573148ad5868224`.

El APK es un artefacto local ignorado; el hash no convierte debug en release ni acredita pruebas físicas.
