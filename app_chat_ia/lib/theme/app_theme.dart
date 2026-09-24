import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppAppearance {
  system('Sistema'),
  light('Claro'),
  dark('Escuro');

  const AppAppearance(this.label);
  final String label;
}

class ThemeController extends ValueNotifier<AppAppearance> {
  ThemeController(
      {AppAppearance initial = AppAppearance.system, this.preferences})
      : super(initial);

  static const storageKey = 'appearance';
  final SharedPreferences? preferences;

  static Future<ThemeController> load() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(storageKey);
    return ThemeController(
      initial: AppAppearance.values.firstWhere((mode) => mode.name == saved,
          orElse: () => AppAppearance.system),
      preferences: preferences,
    );
  }

  Future<void> select(AppAppearance appearance) async {
    // Update only after saving, so a failed write does not look successful.
    if (preferences != null) {
      final saved = await preferences!.setString(storageKey, appearance.name);
      if (!saved) throw StateError('Não foi possível salvar a aparência.');
    }
    value = appearance;
  }
}

class ThemeSettings extends InheritedNotifier<ThemeController> {
  const ThemeSettings(
      {super.key, required ThemeController controller, required super.child})
      : super(notifier: controller);

  static ThemeController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeSettings>()!.notifier!;
}

class ChatPalette {
  ChatPalette(this.dark);
  final bool dark;

  static ChatPalette of(BuildContext context) =>
      ChatPalette(CupertinoTheme.brightnessOf(context) == Brightness.dark);

  Color get background =>
      dark ? const Color(0xFF212121) : CupertinoColors.white;
  Color get text => dark ? const Color(0xFFECECEC) : const Color(0xFF202123);
  Color get secondaryText =>
      dark ? const Color(0xFFB4B4B4) : const Color(0xFF737373);
  Color get surface => dark ? const Color(0xFF303030) : const Color(0xFFF4F4F4);
  Color get line => dark ? const Color(0xFF424242) : const Color(0xFFEAEAEA);
  Color get sidebar => dark ? const Color(0xFF171717) : const Color(0xFFF9F9F9);
  Color get selected =>
      dark ? const Color(0xFF353535) : const Color(0xFFECECEC);
  Color get disabled =>
      dark ? const Color(0xFF505050) : const Color(0xFFD6D6D6);
  Color get onAction => dark ? const Color(0xFF212121) : CupertinoColors.white;
}
