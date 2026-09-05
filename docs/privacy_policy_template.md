# Plantilla de privacidad de DriverAwake — Perú

> Borrador técnico, no política legal definitiva. Debe revisarlo un profesional y completarse cada campo `[[...]]` antes de distribuir públicamente.

- Responsable: `[[NOMBRE O RAZÓN SOCIAL]]`
- RUC/documento aplicable: `[[IDENTIFICADOR]]`
- Domicilio: `[[DOMICILIO]]`
- Correo de privacidad y canal ARCO: `[[CORREO/CANAL]]`
- Banco de datos personales y registro, si corresponde: `[[DETALLE]]`
- Fecha de vigencia y versión: `[[FECHA / VERSIÓN]]`
- Territorios adicionales en Latinoamérica: `[[PAÍSES O SOLO PERÚ]]`

## Marco previsto

El lanzamiento inicial se proyecta para Perú. La revisión legal debe considerar la Ley N.° 29733 y el Reglamento aprobado por Decreto Supremo N.° 016-2024-JUS, vigente desde el 31 de marzo de 2025. La ANPD reconoce los derechos de acceso, rectificación, cancelación y oposición (ARCO).

Fuentes oficiales:

- [Nuevo Reglamento de Protección de Datos Personales](https://www.gob.pe/institucion/anpd/campañas/128319-nuevo-reglamento-de-proteccion-de-datos-personales)
- [Decreto Supremo N.° 016-2024-JUS](https://www.gob.pe/institucion/anpd/normas-legales/6554453-n-016-2024-jus)
- [Orientación oficial sobre derechos ARCO](https://www.gob.pe/9270-que-son-los-derechos-arco)

Si se distribuye en otros países latinoamericanos, se requiere una revisión separada por jurisdicción; cumplir en Perú no implica cumplimiento automático regional.

## Tratamiento actual

La versión actual procesa localmente la cámara frontal para obtener señales de somnolencia. No guarda imágenes ni vídeo y no transmite frames a un backend. Conserva localmente eventos, métricas de riesgo, calibración y telemetría técnica del dispositivo.

Finalidades exactas: `[[DESCRIBIR Y VALIDAR]]`. Base jurídica y, cuando corresponda, mecanismo de consentimiento: `[[DEFINIR]]`.

## Conservación, eliminación y backup

El usuario puede seleccionar 7, 30 o 90 días, o conservación indefinida. Debe justificarse la opción predeterminada y documentarse cualquier obligación adicional. La app permite borrar historial y calibración; Android tiene backup automático deshabilitado.

Procedimiento externo de eliminación y atención ARCO: `[[PROCEDIMIENTO, RESPONSABLE Y PLAZOS]]`.

## Exportación

La exportación exige confirmación explícita. El usuario elige la aplicación o destinatario, que puede conservar una copia fuera del control de DriverAwake. No existe exportación técnica para reentrenamiento en esta etapa.

## Terceros y transferencias

ML Kit y TensorFlow Lite se usan localmente en la versión actual. Analítica, crash reporting, servicios cloud, encargados, transferencias nacionales o internacionales: `[[CONFIRMAR O DECLARAR QUE NO EXISTEN]]`.

## Menores, incidentes y contacto

- Política de edad y tratamiento de menores: `[[DEFINIR]]`.
- Procedimiento de incidentes y notificaciones: `[[DEFINIR]]`.
- Solicitudes ARCO y reclamos: `[[CANAL DEL RESPONSABLE]]`.

La ANPD informa que el titular debe solicitar primero sus derechos al responsable; los detalles y plazos deben ser revisados legalmente para el flujo concreto del producto.
