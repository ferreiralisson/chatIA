import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('pt');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }
}

class AppSettingsScope extends InheritedNotifier<AppSettings> {
  const AppSettingsScope({
    super.key,
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);

  static AppSettings of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>()!
        .notifier!;
  }
}
