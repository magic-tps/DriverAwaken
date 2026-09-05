class DrowsinessThresholds {
  const DrowsinessThresholds._();

  static const Duration frameInterval = Duration(milliseconds: 170);
  static const Duration modelInferenceInterval = Duration(seconds: 1);
  static const double warningRiskScore = 40;
  static const double dangerRiskScore = 70;
  static const double eyeOpenScoreClosed = 0.35;
  static const double earClosed = 0.16;
  static const Duration prolongedBlinkWarning = Duration(milliseconds: 1500);
  static const Duration prolongedBlinkDanger = Duration(seconds: 3);
  static const double yawnMar = 0.55;
  static const Duration yawnWindow = Duration(seconds: 60);
  static const int yawnDangerCount = 3;
  static const double headDownAngle = 22;
  static const double distractionAngleY = 28;
  static const Duration sustainedHeadDownWarning = Duration(milliseconds: 750);
  static const Duration sustainedDistractionWarning = Duration(
    milliseconds: 1400,
  );
  static const Duration noFaceWarning = Duration(milliseconds: 600);
  static const Duration noFaceDanger = Duration(seconds: 2);
  static const Duration perclosWindow = Duration(seconds: 30);
  static const int perclosMinimumSamples = 30;
  static const double perclosWarning = 0.20;
  static const double perclosDanger = 0.35;
  static const double poorBrightness = 34;
  static const double weakBrightness = 48;
  static const Duration warningAlertCooldown = Duration(seconds: 18);
  static const Duration dangerAlertCooldown = Duration(seconds: 7);
  static const Duration sustainedDangerTier4 = Duration(seconds: 14);
  static const Duration eventCooldown = Duration(seconds: 6);
}
