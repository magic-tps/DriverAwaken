import 'package:flutter/material.dart';

abstract final class AppConfig {
  static const productName = 'DriverAwake';
  static const appVersion = '1.0.0+1';
  static const locale = Locale('es');
  static const technicalFeaturesEnabled = bool.fromEnvironment(
    'DRIVERAWAKE_TECHNICAL_FEATURES',
  );
}
