import 'package:flutter/material.dart';

import '../models/drowsiness_state.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({required this.state, super.key});

  final DrowsinessState state;

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(state.level);
    final icon = _levelIcon(state.level);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.7), width: 1.3),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 27),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            state.level.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: color,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        _RiskBadge(score: state.riskScore, color: color),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _RiskBar(color: color, score: state.riskScore),
          const SizedBox(height: 7),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  state.riskReason,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 11,
                    height: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  state.lowLight
                      ? 'Luz insuficiente'
                      : '${state.calibrationStatus} - Tier ${state.alertTier}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: state.calibrationReady
                        ? const Color(0xFF24D17E)
                        : Colors.white.withValues(alpha: 0.58),
                    fontSize: 11,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _levelColor(DrowsinessLevel level) {
    switch (level) {
      case DrowsinessLevel.normal:
        return const Color(0xFF24D17E);
      case DrowsinessLevel.warning:
        return const Color(0xFFFFA726);
      case DrowsinessLevel.danger:
        return const Color(0xFFFF3B30);
    }
  }

  IconData _levelIcon(DrowsinessLevel level) {
    switch (level) {
      case DrowsinessLevel.normal:
        return Icons.shield_outlined;
      case DrowsinessLevel.warning:
        return Icons.warning_amber_rounded;
      case DrowsinessLevel.danger:
        return Icons.report_rounded;
    }
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.score, required this.color});

  final double score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final value = score.clamp(0, 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        '$value%',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _RiskBar extends StatelessWidget {
  const _RiskBar({required this.color, required this.score});

  final Color color;
  final double score;

  @override
  Widget build(BuildContext context) {
    final normalized = (score / 100).clamp(0, 1).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: normalized,
        minHeight: 6,
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
