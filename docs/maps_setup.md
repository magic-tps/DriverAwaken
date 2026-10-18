# Google Maps externo

DriverAwaken no integra mapas, tiles, geocodificación, lugares ni rutas. La app
no depende de `flutter_map`, OpenStreetMap, Nominatim, Overpass, Google Maps SDK,
Places API o Routes API, y no solicita una clave de Google Maps.

Las búsquedas voluntarias usan la URL oficial:

`https://www.google.com/maps/search/?api=1&query=...`

La navegación voluntaria usa:

`https://www.google.com/maps/dir/?api=1&destination=...&travelmode=driving&dir_action=navigate`

Los parámetros se construyen con `Uri.https`. `url_launcher` intenta primero
`LaunchMode.externalApplication`; si no existe la aplicación de Google Maps,
una aplicación compatible con HTTPS puede abrir la URL. La app no afirma
lugares, distancias, horarios ni disponibilidad.

Antes de abrir la aplicación externa se informa que DriverAwaken pausará el
monitoreo. La acción exige confirmación de que el vehículo está detenido. Al
regresar, la sesión permanece pausada hasta una reanudación explícita, lo que
evita cámaras duplicadas y afirmaciones falsas de monitoreo simultáneo.

Esta integración no habilita servicios facturables de Google Maps. Firebase y
el hosting mantienen sus costos independientes según el plan configurado.
