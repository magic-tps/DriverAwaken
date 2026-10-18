abstract final class AppConfig {
  static const productName = 'DriverAwake';
  static const appVersion = '1.1.1+3';
  static const technicalFeaturesEnabled = bool.fromEnvironment(
    'DRIVERAWAKE_TECHNICAL_FEATURES',
  );
}
