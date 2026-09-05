abstract final class AppConfig {
  static const productName = 'DriverAwake';
  static const appVersion = '1.1.0+2';
  static const technicalFeaturesEnabled = bool.fromEnvironment(
    'DRIVERAWAKE_TECHNICAL_FEATURES',
  );
}
