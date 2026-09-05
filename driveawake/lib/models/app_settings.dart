enum SensitivityLevel { low, medium, high }

enum HistoryRetention { sevenDays, thirtyDays, ninetyDays, forever }

extension HistoryRetentionLabel on HistoryRetention {
  String get label => switch (this) {
    HistoryRetention.sevenDays => '7 dias',
    HistoryRetention.thirtyDays => '30 dias',
    HistoryRetention.ninetyDays => '90 dias',
    HistoryRetention.forever => 'Sin borrado automatico',
  };

  Duration? get duration => switch (this) {
    HistoryRetention.sevenDays => const Duration(days: 7),
    HistoryRetention.thirtyDays => const Duration(days: 30),
    HistoryRetention.ninetyDays => const Duration(days: 90),
    HistoryRetention.forever => null,
  };
}

extension SensitivityLevelLabel on SensitivityLevel {
  String get label {
    switch (this) {
      case SensitivityLevel.low:
        return 'Baja';
      case SensitivityLevel.medium:
        return 'Media';
      case SensitivityLevel.high:
        return 'Alta';
    }
  }

  double get riskMultiplier {
    switch (this) {
      case SensitivityLevel.low:
        return 0.88;
      case SensitivityLevel.medium:
        return 1.0;
      case SensitivityLevel.high:
        return 1.12;
    }
  }
}

class AppSettings {
  const AppSettings({
    required this.sensitivity,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.modelEnabled,
    required this.technicalPanelEnabled,
    required this.perclosWindowSeconds,
    required this.historyRetention,
  });

  factory AppSettings.defaults() {
    return const AppSettings(
      sensitivity: SensitivityLevel.medium,
      soundEnabled: true,
      vibrationEnabled: true,
      modelEnabled: false,
      technicalPanelEnabled: false,
      perclosWindowSeconds: 30,
      historyRetention: HistoryRetention.thirtyDays,
    );
  }

  final SensitivityLevel sensitivity;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool modelEnabled;
  final bool technicalPanelEnabled;
  final int perclosWindowSeconds;
  final HistoryRetention historyRetention;

  Duration get perclosWindow => Duration(seconds: perclosWindowSeconds);

  AppSettings copyWith({
    SensitivityLevel? sensitivity,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? modelEnabled,
    bool? technicalPanelEnabled,
    int? perclosWindowSeconds,
    HistoryRetention? historyRetention,
  }) {
    return AppSettings(
      sensitivity: sensitivity ?? this.sensitivity,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      modelEnabled: modelEnabled ?? this.modelEnabled,
      technicalPanelEnabled:
          technicalPanelEnabled ?? this.technicalPanelEnabled,
      perclosWindowSeconds: perclosWindowSeconds ?? this.perclosWindowSeconds,
      historyRetention: historyRetention ?? this.historyRetention,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'sensitivity': sensitivity.name,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'modelEnabled': modelEnabled,
      'technicalPanelEnabled': technicalPanelEnabled,
      'perclosWindowSeconds': perclosWindowSeconds,
      'historyRetention': historyRetention.name,
    };
  }

  factory AppSettings.fromMap(Map<String, Object?> map) {
    final defaults = AppSettings.defaults();
    final sensitivityName = map['sensitivity'] as String?;

    return AppSettings(
      sensitivity: SensitivityLevel.values.firstWhere(
        (level) => level.name == sensitivityName,
        orElse: () => defaults.sensitivity,
      ),
      soundEnabled: map['soundEnabled'] as bool? ?? defaults.soundEnabled,
      vibrationEnabled:
          map['vibrationEnabled'] as bool? ?? defaults.vibrationEnabled,
      modelEnabled: map['modelEnabled'] as bool? ?? defaults.modelEnabled,
      technicalPanelEnabled:
          map['technicalPanelEnabled'] as bool? ??
          defaults.technicalPanelEnabled,
      perclosWindowSeconds:
          (map['perclosWindowSeconds'] as num?)
              ?.toInt()
              .clamp(10, 90)
              .toInt() ??
          defaults.perclosWindowSeconds,
      historyRetention: HistoryRetention.values.firstWhere(
        (value) => value.name == map['historyRetention'],
        orElse: () => defaults.historyRetention,
      ),
    );
  }
}
