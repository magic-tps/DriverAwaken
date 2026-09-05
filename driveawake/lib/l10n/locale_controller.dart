import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language preference is independent of trip data and account identity.
class LocaleController extends ChangeNotifier with WidgetsBindingObserver {
  LocaleController();
  static final instance = LocaleController();
  static const preferenceKey = 'app_language';
  static const supportedLocales = [Locale('es'), Locale('en')];
  String _selection = 'system';
  SharedPreferences? _preferences;

  String get selection => _selection;
  Locale? get locale => _selection == 'system' ? null : Locale(_selection);
  Locale get effectiveLocale =>
      locale ?? resolve(PlatformDispatcher.instance.locales);

  static Locale resolve(List<Locale>? locales) {
    for (final locale in locales ?? <Locale>[]) {
      if (locale.languageCode == 'en' || locale.languageCode == 'es') {
        return Locale(locale.languageCode);
      }
    }
    return const Locale('es');
  }

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
    final stored = _preferences!.getString(preferenceKey);
    _selection = ['es', 'en'].contains(stored) ? stored! : 'system';
    WidgetsBinding.instance.removeObserver(this);
    WidgetsBinding.instance.addObserver(this);
    notifyListeners();
  }

  Future<void> select(String value) async {
    if (!['system', 'es', 'en'].contains(value)) {
      throw ArgumentError.value(value, 'language');
    }
    _preferences ??= await SharedPreferences.getInstance();
    if (!await _preferences!.setString(preferenceKey, value)) {
      throw StateError('Language preference could not be saved');
    }
    _selection = value;
    notifyListeners();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (_selection == 'system') notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
