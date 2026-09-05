# Auditoria inicial de DriverAwake

Fecha: 2026-07-17

## Alcance y arquitectura encontrada

El workspace contiene tres areas principales:

- `driveawake/`: aplicacion Flutter orientada principalmente a Android.
- `app_conductores_ml/`: extraccion de features, entrenamiento, exportacion TFLite y validacion en Python.
- `Data/`: aproximadamente 112 GB de videos. No se modifica ni se versiona.

La aplicacion procesa la camara frontal con ML Kit, construye metricas temporales,
combina reglas deterministas con un modelo TFLite y guarda eventos localmente.
El pipeline Python entrena el modelo con features extraidas mediante MediaPipe.

## Estado de Git y automatizacion

- No se encontro un repositorio Git en la raiz ni en los componentes inspeccionados.
- No existe `.github/workflows/`.
- Existen `.gitignore` separados en Flutter y Python, pero no uno en la raiz.
- Hay un `key.properties` y un keystore locales. No se leen, modifican ni versionan.

## Dependencias relevantes

Flutter usa `camera`, Google ML Kit Face Detection, `tflite_flutter`,
`shared_preferences`, vibracion, PDF y exportacion/comparticion.

Python usa OpenCV, MediaPipe, TensorFlow 2.16.1, scikit-learn, pandas y NumPy.
La instalacion inicial de `requirements.txt` completo, pero genero conflictos con
otros paquetes del Python global. Las ejecuciones posteriores deben usar un
entorno virtual aislado.

## Problemas criticos

1. PERCLOS conecta muestras validas separadas por ausencia de rostro.
2. La pausa del viaje solo pausa estadisticas, no camara, inferencia ni alarmas.
3. Volver a riesgo normal no cancela inmediatamente audio y vibracion.
4. Salir con Atras puede perder el resumen del viaje.
5. Release usa firma debug si falta configuracion release.
6. El modelo experimental esta activo por defecto.
7. El modelo fue entrenado con features MediaPipe que no son matematicamente
   equivalentes a las features ML Kit generadas en Flutter.
8. Los splits de ML agrupan por video. La reproduccion del split actual encontro
   que el 100% de los sujetos del test tambien aparece en entrenamiento.
9. La validacion historica ejecuta el modelo sobre todo el CSV, incluyendo datos
   usados durante entrenamiento, y no reproduce completamente el motor Dart.

## Tests existentes

Flutter contiene pruebas unitarias basicas para el motor de riesgo, PERCLOS y
cooldowns, mas un smoke test de widgets. No hay tests Python propios.

Faltan pruebas de lifecycle, pausa, alarmas, persistencia, compatibilidad del
modelo, paridad de features, splits por sujeto y recuperacion de sesiones.

## Estado inicial de comandos

| Comando | Resultado inicial |
|---|---|
| `flutter pub get` | Bloqueado sin salida; proceso detenido despues de 60 s. |
| `dart format --output=none --set-exit-if-changed lib test` | 41 archivos, 0 cambios; fallo final por permisos de telemetria fuera del workspace. |
| `dart analyze lib test` | `No issues found`; fallo final por permisos de telemetria fuera del workspace. |
| `flutter test` | Bloqueado sin salida en ejecucion previa; no se considera aprobado. |
| `python -m pip install -r requirements.txt` | Completo con conflictos en el entorno global. |
| `python -m ruff check .` | Ruff no instalado. |
| `python -m pytest` | 0 tests recolectados. |

## Riesgos de seguridad y privacidad

- El release puede firmarse con credenciales debug.
- El historial de conduccion usa `SharedPreferences` y no define una politica
  explicita de backup o retencion.
- Varias rutas criticas silencian excepciones, dificultando detectar fallos
  repetidos de camara o alarmas.
- La politica de privacidad no debe completarse con datos legales inventados.

## Riesgos de machine learning

- Fuga de identidad por split basado en `video_id`.
- Diferencia de detector y formulas entre entrenamiento y produccion.
- Metricas historicas no equivalen a validacion independiente del producto.
- El manifiesto actual no valida hash, shapes, compatibilidad del extractor ni
  probabilidades no finitas antes de habilitar inferencia.

## Orden de implementacion

1. Corregir PERCLOS y cubrirlo con tests.
2. Implementar pausa, cancelacion de alertas y salida segura.
3. Añadir borradores recuperables y endurecer firma release.
4. Desactivar el modelo por defecto y validar fallos seguros.
5. Eliminar fuga de sujetos y añadir tests Python.
6. Crear contrato compartido y fixtures de paridad.
7. Refactorizar hacia un controlador de sesion inyectable.
8. Mejorar persistencia, rendimiento, UX, privacidad y CI.

## Nota sobre el entorno Python del host

El comando solicitado `python -m pip install -r requirements.txt` se ejecutó inicialmente sobre el Python global y dejó incompatibilidades con paquetes ajenos al proyecto (entre ellos FiftyOne, OpenCV, SHAP y tf-keras). No se intentó reparar globalmente porque exigiría modificar herramientas fuera del alcance del repositorio. Las validaciones posteriores usan exclusivamente `app_conductores_ml/venv`, donde `pip check` informa `No broken requirements found`.

## Verificacion posterior a la auditoria

El bloqueo de Flutter se identifico como falta de acceso a `C:\flutter\bin\cache\lockfile`, no como un fallo del proyecto. Ejecutando el runner con acceso al SDK, la suite alcanzo 33 pruebas aprobadas y `flutter build apk --debug` genero correctamente el APK. La tabla anterior se conserva como fotografia del estado inicial.
