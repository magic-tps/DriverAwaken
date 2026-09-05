enum DrowsinessLevel { normal, warning, danger }

extension DrowsinessLevelLabel on DrowsinessLevel {
  String get label {
    switch (this) {
      case DrowsinessLevel.normal:
        return 'NORMAL';
      case DrowsinessLevel.warning:
        return 'PRECAUCION';
      case DrowsinessLevel.danger:
        return 'PELIGRO';
    }
  }
}

class DrowsinessState {
  const DrowsinessState({
    required this.level,
    required this.faceDetected,
    required this.eyesClosed,
    required this.prolongedBlink,
    required this.yawning,
    required this.headDown,
    required this.distracted,
    required this.noFaceTooLong,
    required this.eyeOpenScore,
    required this.ear,
    required this.mar,
    required this.perclos,
    required this.perclosReady,
    required this.headX,
    required this.headY,
    required this.eyeClosedDurationSeconds,
    required this.noFaceDurationSeconds,
    required this.headDownDurationSeconds,
    required this.distractedDurationSeconds,
    required this.yawnCountWindow,
    required this.riskScore,
    required this.ruleRiskScore,
    required this.modelRiskScore,
    required this.riskReason,
    required this.alertTier,
    required this.sustainedDangerDurationSeconds,
    required this.lowLight,
    required this.imageBrightness,
    required this.signalQuality,
    required this.fps,
    required this.modelAvailable,
    required this.modelLabel,
    required this.modelConfidence,
    required this.modelAwakeProbability,
    required this.modelFatigueProbability,
    required this.modelDrowsyProbability,
    required this.calibrationReady,
    required this.calibrationStatus,
    required this.calibrationInProgress,
    required this.calibrationProgress,
    required this.calibrationInstruction,
    required this.message,
  });

  factory DrowsinessState.initial() {
    return const DrowsinessState(
      level: DrowsinessLevel.normal,
      faceDetected: false,
      eyesClosed: false,
      prolongedBlink: false,
      yawning: false,
      headDown: false,
      distracted: false,
      noFaceTooLong: false,
      eyeOpenScore: null,
      ear: null,
      mar: null,
      perclos: 0,
      perclosReady: false,
      headX: null,
      headY: null,
      eyeClosedDurationSeconds: 0,
      noFaceDurationSeconds: 0,
      headDownDurationSeconds: 0,
      distractedDurationSeconds: 0,
      yawnCountWindow: 0,
      riskScore: 0,
      ruleRiskScore: 0,
      modelRiskScore: 0,
      riskReason: 'Sistema listo',
      alertTier: 0,
      sustainedDangerDurationSeconds: 0,
      lowLight: false,
      imageBrightness: null,
      signalQuality: 0,
      fps: null,
      modelAvailable: false,
      modelLabel: null,
      modelConfidence: null,
      modelAwakeProbability: null,
      modelFatigueProbability: null,
      modelDrowsyProbability: null,
      calibrationReady: false,
      calibrationStatus: 'Calibrando rostro frontal',
      calibrationInProgress: false,
      calibrationProgress: 0,
      calibrationInstruction: 'Mira al frente',
      message: 'Conduccion normal',
    );
  }

  final DrowsinessLevel level;
  final bool faceDetected;
  final bool eyesClosed;
  final bool prolongedBlink;
  final bool yawning;
  final bool headDown;
  final bool distracted;
  final bool noFaceTooLong;
  final double? eyeOpenScore;
  final double? ear;
  final double? mar;
  final double perclos;
  final bool perclosReady;
  final double? headX;
  final double? headY;
  final double eyeClosedDurationSeconds;
  final double noFaceDurationSeconds;
  final double headDownDurationSeconds;
  final double distractedDurationSeconds;
  final int yawnCountWindow;
  final double riskScore;
  final double ruleRiskScore;
  final double modelRiskScore;
  final String riskReason;
  final int alertTier;
  final double sustainedDangerDurationSeconds;
  final bool lowLight;
  final double? imageBrightness;
  final double signalQuality;
  final double? fps;
  final bool modelAvailable;
  final String? modelLabel;
  final double? modelConfidence;
  final double? modelAwakeProbability;
  final double? modelFatigueProbability;
  final double? modelDrowsyProbability;
  final bool calibrationReady;
  final String calibrationStatus;
  final bool calibrationInProgress;
  final double calibrationProgress;
  final String calibrationInstruction;
  final String message;

  DrowsinessState copyWith({
    DrowsinessLevel? level,
    bool? faceDetected,
    bool? eyesClosed,
    bool? prolongedBlink,
    bool? yawning,
    bool? headDown,
    bool? distracted,
    bool? noFaceTooLong,
    double? eyeOpenScore,
    bool clearEyeOpenScore = false,
    double? ear,
    bool clearEar = false,
    double? mar,
    bool clearMar = false,
    double? perclos,
    bool? perclosReady,
    double? headX,
    bool clearHeadX = false,
    double? headY,
    bool clearHeadY = false,
    double? eyeClosedDurationSeconds,
    double? noFaceDurationSeconds,
    double? headDownDurationSeconds,
    double? distractedDurationSeconds,
    int? yawnCountWindow,
    double? riskScore,
    double? ruleRiskScore,
    double? modelRiskScore,
    String? riskReason,
    int? alertTier,
    double? sustainedDangerDurationSeconds,
    bool? lowLight,
    double? imageBrightness,
    bool clearImageBrightness = false,
    double? signalQuality,
    double? fps,
    bool clearFps = false,
    bool? modelAvailable,
    String? modelLabel,
    bool clearModelLabel = false,
    double? modelConfidence,
    bool clearModelConfidence = false,
    double? modelAwakeProbability,
    bool clearModelAwakeProbability = false,
    double? modelFatigueProbability,
    bool clearModelFatigueProbability = false,
    double? modelDrowsyProbability,
    bool clearModelDrowsyProbability = false,
    bool? calibrationReady,
    String? calibrationStatus,
    bool? calibrationInProgress,
    double? calibrationProgress,
    String? calibrationInstruction,
    String? message,
  }) {
    return DrowsinessState(
      level: level ?? this.level,
      faceDetected: faceDetected ?? this.faceDetected,
      eyesClosed: eyesClosed ?? this.eyesClosed,
      prolongedBlink: prolongedBlink ?? this.prolongedBlink,
      yawning: yawning ?? this.yawning,
      headDown: headDown ?? this.headDown,
      distracted: distracted ?? this.distracted,
      noFaceTooLong: noFaceTooLong ?? this.noFaceTooLong,
      eyeOpenScore: clearEyeOpenScore
          ? null
          : eyeOpenScore ?? this.eyeOpenScore,
      ear: clearEar ? null : ear ?? this.ear,
      mar: clearMar ? null : mar ?? this.mar,
      perclos: perclos ?? this.perclos,
      perclosReady: perclosReady ?? this.perclosReady,
      headX: clearHeadX ? null : headX ?? this.headX,
      headY: clearHeadY ? null : headY ?? this.headY,
      eyeClosedDurationSeconds:
          eyeClosedDurationSeconds ?? this.eyeClosedDurationSeconds,
      noFaceDurationSeconds:
          noFaceDurationSeconds ?? this.noFaceDurationSeconds,
      headDownDurationSeconds:
          headDownDurationSeconds ?? this.headDownDurationSeconds,
      distractedDurationSeconds:
          distractedDurationSeconds ?? this.distractedDurationSeconds,
      yawnCountWindow: yawnCountWindow ?? this.yawnCountWindow,
      riskScore: riskScore ?? this.riskScore,
      ruleRiskScore: ruleRiskScore ?? this.ruleRiskScore,
      modelRiskScore: modelRiskScore ?? this.modelRiskScore,
      riskReason: riskReason ?? this.riskReason,
      alertTier: alertTier ?? this.alertTier,
      sustainedDangerDurationSeconds:
          sustainedDangerDurationSeconds ?? this.sustainedDangerDurationSeconds,
      lowLight: lowLight ?? this.lowLight,
      imageBrightness: clearImageBrightness
          ? null
          : imageBrightness ?? this.imageBrightness,
      signalQuality: signalQuality ?? this.signalQuality,
      fps: clearFps ? null : fps ?? this.fps,
      modelAvailable: modelAvailable ?? this.modelAvailable,
      modelLabel: clearModelLabel ? null : modelLabel ?? this.modelLabel,
      modelConfidence: clearModelConfidence
          ? null
          : modelConfidence ?? this.modelConfidence,
      modelAwakeProbability: clearModelAwakeProbability
          ? null
          : modelAwakeProbability ?? this.modelAwakeProbability,
      modelFatigueProbability: clearModelFatigueProbability
          ? null
          : modelFatigueProbability ?? this.modelFatigueProbability,
      modelDrowsyProbability: clearModelDrowsyProbability
          ? null
          : modelDrowsyProbability ?? this.modelDrowsyProbability,
      calibrationReady: calibrationReady ?? this.calibrationReady,
      calibrationStatus: calibrationStatus ?? this.calibrationStatus,
      calibrationInProgress:
          calibrationInProgress ?? this.calibrationInProgress,
      calibrationProgress: calibrationProgress ?? this.calibrationProgress,
      calibrationInstruction:
          calibrationInstruction ?? this.calibrationInstruction,
      message: message ?? this.message,
    );
  }
}
