import 'package:flutter/material.dart';

@immutable
class RiskTheme extends ThemeExtension<RiskTheme> {
  const RiskTheme({
    required this.normal,
    required this.warning,
    required this.danger,
    required this.insufficientSignal,
    required this.paused,
  });

  static const standard = RiskTheme(
    normal: Color(0xFF24D17E),
    warning: Color(0xFFFFA726),
    danger: Color(0xFFFF3B30),
    insufficientSignal: Color(0xFF8A969C),
    paused: Color(0xFF28C9FF),
  );

  final Color normal;
  final Color warning;
  final Color danger;
  final Color insufficientSignal;
  final Color paused;

  @override
  RiskTheme copyWith({
    Color? normal,
    Color? warning,
    Color? danger,
    Color? insufficientSignal,
    Color? paused,
  }) => RiskTheme(
    normal: normal ?? this.normal,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    insufficientSignal: insufficientSignal ?? this.insufficientSignal,
    paused: paused ?? this.paused,
  );

  @override
  RiskTheme lerp(covariant RiskTheme? other, double t) {
    if (other == null) return this;
    return RiskTheme(
      normal: Color.lerp(normal, other.normal, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      insufficientSignal: Color.lerp(
        insufficientSignal,
        other.insufficientSignal,
        t,
      )!,
      paused: Color.lerp(paused, other.paused, t)!,
    );
  }
}

abstract final class AppTheme {
  static const _background = Color(0xFF080B0D);
  static const _surface = Color(0xFF11171A);

  static ThemeData dark({bool highContrast = false}) {
    final risk = highContrast
        ? const RiskTheme(
            normal: Color(0xFF00F08A),
            warning: Color(0xFFFFD000),
            danger: Color(0xFFFF453A),
            insufficientSignal: Color(0xFFD0D7DA),
            paused: Color(0xFF56D6FF),
          )
        : RiskTheme.standard;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: risk.normal,
        brightness: Brightness.dark,
        surface: _surface,
      ),
      extensions: <ThemeExtension<dynamic>>[risk],
      appBarTheme: const AppBarTheme(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
    );
  }
}
