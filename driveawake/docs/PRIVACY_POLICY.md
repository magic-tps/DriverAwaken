# Politica de Privacidad - MagicDrive Alert

Fecha de vigencia: 24 de mayo de 2026

MagicDrive Alert es un sistema preventivo de alerta temprana para conductores.
No es un diagnostico medico, no reemplaza la responsabilidad del conductor y no
garantiza la prevencion de accidentes.

## Datos que procesa

La app usa la camara frontal para detectar senales faciales y de postura en
tiempo real:

- rostro detectado o ausente;
- ojos abiertos/cerrados;
- parpadeos prolongados;
- bostezos;
- posicion aproximada de cabeza;
- distraccion lateral;
- metricas como EAR, MAR, PERCLOS y score de riesgo;
- prediccion local del modelo: despierto, cansancio o somnoliento;
- telemetria tecnica del dispositivo durante el viaje: bateria, temperatura,
  FPS aproximado y estado de carga.

## Datos que no guarda

- No graba videos.
- No guarda imagenes.
- No guarda frames de la camara.
- No envia imagenes a servidores.
- No entrena modelos con datos del usuario dentro de la app.

## Historial local

La app puede guardar eventos locales como:

- fecha y hora;
- tipo de alerta;
- nivel de riesgo;
- duracion aproximada;
- PERCLOS;
- prediccion y confianza del modelo;
- metricas tecnicas del viaje.

Este historial se guarda solo en el dispositivo y puede borrarse desde Ajustes
o Historial.

## Procesamiento offline

La deteccion facial, las reglas criticas y el modelo TensorFlow Lite se ejecutan
en el dispositivo. La app no necesita conexion a internet para detectar
somnolencia.

## Uso de permisos

La app solicita:

- Camara: necesaria para procesar senales faciales en tiempo real.
- Vibracion: necesaria para alertas de seguridad.

## Seguridad vial

MagicDrive Alert debe usarse solo como apoyo preventivo. Si el usuario siente
cansancio, sueno, mareo o perdida de atencion, debe detenerse en un lugar
seguro y descansar.

## Contacto

Responsable del proyecto: MagicDrive Alert / AppConductores.
