import '../l10n/localized_text.dart';
import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/calibration_service.dart';
import '../services/device_telemetry_service.dart';
import '../services/local_history_service.dart';
import '../services/settings_service.dart';
import 'privacy_policy_screen.dart';
import '../widgets/language_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService.instance;
  final CalibrationService _calibrationService = CalibrationService();
  final DeviceTelemetryService _deviceTelemetryService =
      DeviceTelemetryService();
  AppSettings _settings = AppSettings.defaults();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _settingsService.initialize();
    await _calibrationService.initialize();
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = _settingsService.settings;
      _loading = false;
    });
  }

  Future<void> _update(AppSettings settings) async {
    final retentionChanged =
        settings.historyRetention != _settings.historyRetention;
    setState(() {
      _settings = settings;
    });
    await _settingsService.update(settings);
    if (retentionChanged) {
      await LocalHistoryService.instance.enforceRetentionPolicy();
    }
  }

  Future<void> _resetCalibration() async {
    await _calibrationService.reset();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: LocalizedText('Calibracion restablecida')),
    );
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const LocalizedText('Borrar historial'),
        content: const LocalizedText('Esta accion no se puede deshacer.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const LocalizedText('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const LocalizedText('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await LocalHistoryService.instance.clear();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: LocalizedText('Historial borrado')));
  }

  Future<void> _resetDefaults() async {
    await _settingsService.resetDefaults();
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = _settingsService.settings;
    });
  }

  Future<void> _testAlarm() async {
    await _deviceTelemetryService.playAlarm(repeat: 1);
  }

  void _openPrivacy() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const LocalizedText('Ajustes')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: <Widget>[
            const LanguageSelector(),
            const SizedBox(height: 20),
            const _SectionTitle('Deteccion'),
            _SettingsCard(
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const LocalizedText('Conservar historial'),
                  trailing: DropdownButton<HistoryRetention>(
                    value: _settings.historyRetention,
                    items: HistoryRetention.values
                        .map(
                          (value) => DropdownMenuItem<HistoryRetention>(
                            value: value,
                            child: LocalizedText(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _update(_settings.copyWith(historyRetention: value));
                      }
                    },
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const LocalizedText('Sensibilidad'),
                  subtitle: LocalizedText(_settings.sensitivity.label),
                  trailing: DropdownButton<SensitivityLevel>(
                    value: _settings.sensitivity,
                    items: SensitivityLevel.values
                        .map(
                          (level) => DropdownMenuItem<SensitivityLevel>(
                            value: level,
                            child: LocalizedText(level.label),
                          ),
                        )
                        .toList(),
                    onChanged: (level) {
                      if (level == null) {
                        return;
                      }
                      _update(_settings.copyWith(sensitivity: level));
                    },
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const LocalizedText('Modelo IA local'),
                  subtitle: const LocalizedText(
                    'Suma riesgo, no reemplaza reglas',
                  ),
                  value: _settings.modelEnabled,
                  onChanged: (value) =>
                      _update(_settings.copyWith(modelEnabled: value)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const LocalizedText('Panel tecnico'),
                  value: _settings.technicalPanelEnabled,
                  onChanged: (value) =>
                      _update(_settings.copyWith(technicalPanelEnabled: value)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const LocalizedText('Ventana PERCLOS'),
                  subtitle: Slider(
                    min: 10,
                    max: 90,
                    divisions: 8,
                    value: _settings.perclosWindowSeconds.toDouble(),
                    label: '${_settings.perclosWindowSeconds}s',
                    onChanged: (value) => _update(
                      _settings.copyWith(perclosWindowSeconds: value.round()),
                    ),
                  ),
                  trailing: LocalizedText('${_settings.perclosWindowSeconds}s'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _SectionTitle('Alertas'),
            _SettingsCard(
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const LocalizedText('Sonido'),
                  value: _settings.soundEnabled,
                  onChanged: (value) =>
                      _update(_settings.copyWith(soundEnabled: value)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const LocalizedText('Vibracion'),
                  value: _settings.vibrationEnabled,
                  onChanged: (value) =>
                      _update(_settings.copyWith(vibrationEnabled: value)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.volume_up_rounded),
                  title: const LocalizedText('Probar alarma real'),
                  subtitle: const LocalizedText(
                    'Reproduce el audio local de alerta',
                  ),
                  onTap: _testAlarm,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _SectionTitle('Datos locales'),
            _SettingsCard(
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.restart_alt_rounded),
                  title: const LocalizedText('Restablecer calibracion'),
                  onTap: _resetCalibration,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: const LocalizedText('Borrar historial'),
                  onTap: _clearHistory,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.settings_backup_restore_rounded),
                  title: const LocalizedText('Restablecer valores por defecto'),
                  onTap: _resetDefaults,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const LocalizedText('Politica de privacidad'),
                  onTap: _openPrivacy,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LocalizedText(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.72),
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF11171A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(children: children),
    );
  }
}
