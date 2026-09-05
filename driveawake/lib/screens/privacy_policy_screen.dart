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
                  'Se guardan localmente eventos, fechas, niveles de alerta, duraciones, PERCLOS, riesgo y telemetria tecnica del viaje. No se crean cuentas ni perfiles en un servidor.',
            ),
            _PolicySection(
              title: 'Conservacion y eliminacion',
              text:
                  'El usuario puede elegir 7, 30 o 90 dias, o conservar el historial sin borrado automatico. Ajustes permite eliminar el historial y la calibracion del dispositivo.',
            ),
            _PolicySection(
              title: 'Exportacion',
              text:
                  'Un reporte solo sale del dispositivo tras confirmacion. Desde ese momento, su tratamiento depende de la aplicacion o destinatario elegido por el usuario.',
            ),
            _PolicySection(
              title: 'Permisos y terceros',
              text:
                  'La camara se usa para deteccion en tiempo real; audio y vibracion para alertas. ML Kit y TensorFlow Lite se ejecutan localmente en esta version.',
            ),
            _PolicySection(
              title: 'Derechos en Peru',
              text:
                  'La Ley N.° 29733 reconoce derechos de acceso, rectificacion, cancelacion y oposicion (ARCO). Como los datos actuales permanecen en el telefono, el usuario puede consultar o eliminar el historial desde la app. El canal formal del responsable debe definirse antes de publicar.',
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
