import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidad')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: const <Widget>[
            _PolicyHeader(),
            SizedBox(height: 18),
            _NoticeCard(),
            _PolicySection(
              title: 'Procesamiento local',
              text:
                  'La camara frontal se analiza en el dispositivo. DriverAwake no graba video, no guarda imagenes y no envia frames a servidores en esta version.',
            ),
            _PolicySection(
              title: 'Datos almacenados',
              text:
                  'Se guardan localmente eventos, fechas, niveles de alerta, duraciones, PERCLOS, riesgo y telemetria del viaje. Si creas una cuenta opcional, Firebase Authentication gestiona tu correo y acceso. Solo al confirmar Copiar informes se envian resumenes a Cloud Firestore; nunca imagenes ni videos.',
            ),
            _PolicySection(
              title: 'Conservacion y eliminacion',
              text:
                  'El usuario puede elegir 7, 30 o 90 dias, o conservar el historial local sin borrado automatico. Las copias en la nube se conservan hasta borrarlas desde Mis copias en la nube, donde tambien puedes eliminar tu cuenta. Borrar datos locales no elimina las copias remotas.',
            ),
            _PolicySection(
              title: 'Exportacion',
              text:
                  'Los informes se comparten o copian en la nube tras confirmacion. La copia en Firebase contiene fechas, duraciones, alertas, riesgo y telemetria. Las exportaciones a otras aplicaciones dependen del destinatario elegido.',
            ),
            _PolicySection(
              title: 'Permisos y terceros',
              text:
                  'La camara se usa para deteccion en tiempo real; audio y vibracion para alertas. ML Kit y TensorFlow Lite se ejecutan localmente. Firebase Authentication y Cloud Firestore, servicios de Google, gestionan la cuenta y las copias opcionales.',
            ),
            _PolicySection(
              title: 'Derechos en Peru',
              text:
                  'Puedes consultar y borrar el historial local desde la app y eliminar las copias y tu cuenta desde Mis copias en la nube. El canal formal del responsable para solicitudes de privacidad debe definirse antes de publicar.',
            ),
            _PolicySection(
              title: 'Responsable pendiente',
              text:
                  'Responsable legal: PENDIENTE. Correo de privacidad: PENDIENTE. Domicilio y canal ARCO: PENDIENTES. Esta informacion es obligatoria antes de distribuir la aplicacion al publico.',
            ),
            _PolicySection(
              title: 'Limites',
              text:
                  'DriverAwake es una herramienta experimental. No sustituye la atencion del conductor, una evaluacion medica ni un sistema vehicular certificado.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyHeader extends StatelessWidget {
  const _PolicyHeader();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF11171A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.privacy_tip_outlined, size: 34),
            SizedBox(height: 14),
            Text(
              'Aviso preliminar de privacidad',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 8),
            Text('Ambito inicial: Peru · Revision legal pendiente'),
          ],
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.info_outline_rounded),
        title: Text('No es una politica definitiva'),
        subtitle: Text(
          'Debe completarse la identidad del responsable y recibir revision legal antes de una publicacion publica.',
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. $text',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(text, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
