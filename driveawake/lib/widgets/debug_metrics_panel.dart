import 'package:flutter/material.dart';

import '../models/drowsiness_state.dart';

class DebugMetricsPanel extends StatelessWidget {
  const DebugMetricsPanel({required this.state, super.key});

  final DrowsinessState state;

  @override
  Widget build(BuildContext context) {
    final metrics = <_Metric>[
      _Metric('Rostro', _boolText(state.faceDetected), state.faceDetected),
      _Metric('Ojos cerrados', _boolText(state.eyesClosed), state.eyesClosed),
      _Metric(
        'Parpadeo largo',
        _boolText(state.prolongedBlink),
        state.prolongedBlink,
      ),
      _Metric('Bostezo', _boolText(state.yawning), state.yawning),
      _Metric('Cabeza caida', _boolText(state.headDown), state.headDown),
      _Metric('Distraccion', _boolText(state.distracted), state.distracted),
      _Metric('Eye score', _numberText(state.eyeOpenScore), false),
      _Metric('EAR aprox.', _numberText(state.ear), false),
      _Metric('MAR aprox.', _numberText(state.mar), false),
      _Metric('PERCLOS', _numberText(state.perclos), state.perclos > 0.2),
      _Metric(
        'PERCLOS listo',
        _boolText(state.perclosReady),
        !state.perclosReady,
      ),
      _Metric('Head X', _numberText(state.headX), false),
      _Metric('Head Y', _numberText(state.headY), false),
      _Metric(
        'Ojos cerr. s',
        _numberText(state.eyeClosedDurationSeconds),
        state.eyeClosedDurationSeconds >= 1.5,
      ),
      _Metric(
        'Sin rostro s',
        _numberText(state.noFaceDurationSeconds),
        state.noFaceDurationSeconds >= 1,
      ),
      _Metric(
        'Calidad',
        _numberText(state.signalQuality),
        state.signalQuality < 0.36,
      ),
      _Metric('Brillo', _numberText(state.imageBrightness), state.lowLight),
      _Metric('FPS', _numberText(state.fps), false),
      _Metric('Tier alerta', '${state.alertTier}', state.alertTier >= 2),
      _Metric(
        'Riesgo total',
        _numberText(state.riskScore),
        state.riskScore >= 35,
      ),
      _Metric(
        'Riesgo reglas',
        _numberText(state.ruleRiskScore),
        state.ruleRiskScore >= 35,
      ),
      _Metric(
        'Riesgo modelo',
        _numberText(state.modelRiskScore),
        state.modelRiskScore >= 35,
      ),
      _Metric(
        'Modelo',
        state.modelAvailable ? state.modelLabel ?? 'listo' : 'offline',
        state.modelDrowsyProbability != null &&
            state.modelDrowsyProbability! >= 0.45,
      ),
      _Metric(
        'P somnoliento',
        _numberText(state.modelDrowsyProbability),
        state.modelDrowsyProbability != null &&
            state.modelDrowsyProbability! >= 0.45,
      ),
      _Metric(
        'Calibracion',
        state.calibrationReady ? 'ACTIVA' : 'AUTO',
        !state.calibrationReady,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 560 ? 3 : 2;
          final tileWidth =
              (constraints.maxWidth - ((columns - 1) * 8)) / columns;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.monitor_heart_outlined,
                    color: Color(0xFF24D17E),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Diagnostico en vivo',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '5 FPS',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.42),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: metrics
                    .map(
                      (metric) => SizedBox(
                        width: tileWidth,
                        height: 48,
                        child: _MetricTile(metric: metric),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  String _boolText(bool value) => value ? 'SI' : 'NO';

  String _numberText(double? value) {
    if (value == null) {
      return '--';
    }

    return value.toStringAsFixed(2);
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    final accent = metric.alert
        ? const Color(0xFFFFA726)
        : Colors.white.withValues(alpha: 0.76);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: metric.alert
            ? const Color(0xFFFFA726).withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: metric.alert
              ? const Color(0xFFFFA726).withValues(alpha: 0.24)
              : Colors.white.withValues(alpha: 0.055),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.56),
              fontSize: 10,
              height: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: accent,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric {
  const _Metric(this.label, this.value, this.alert);

  final String label;
  final String value;
  final bool alert;
}
