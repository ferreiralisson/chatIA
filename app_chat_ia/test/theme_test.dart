import 'package:app_chat_ia/main.dart';
import 'package:app_chat_ia/screens/chat_screen.dart';
import 'package:app_chat_ia/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Saves and restores the appearance preference', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = await ThemeController.load();
    expect(controller.value, AppAppearance.system);
    await controller.select(AppAppearance.dark);
    final restored = await ThemeController.load();
    expect(restored.value, AppAppearance.dark);
    await restored.select(AppAppearance.system);
    final system = await ThemeController.load();
    expect(system.value, AppAppearance.system);
    controller.dispose();
    restored.dispose();
    system.dispose();
  });

  testWidgets('Settings switches themes without losing the draft',
      (tester) async {
    final controller = ThemeController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(ChatApp(themeController: controller));
    await tester.enterText(
        find.byKey(const Key('message-input')), 'Meu rascunho');
    await tester.tap(find.byIcon(CupertinoIcons.gear));
    await tester.pumpAndSettle();
    expect(find.text('Configurações'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('appearance-dark')));
    await tester.pumpAndSettle();
    expect(controller.value, AppAppearance.dark);
    expect(
        tester
            .widget<CupertinoApp>(find.byType(CupertinoApp))
            .theme!
            .brightness,
        Brightness.dark);
    await tester.tap(find.byKey(const ValueKey('appearance-light')));
    await tester.pumpAndSettle();
    expect(controller.value, AppAppearance.light);
    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();
    expect(find.text('Meu rascunho'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('System follows brightness changes; explicit mode overrides them',
      (tester) async {
    final dispatcher = tester.binding.platformDispatcher;
    addTearDown(dispatcher.clearPlatformBrightnessTestValue);
    final controller = ThemeController();
    addTearDown(controller.dispose);
    dispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpWidget(ChatApp(themeController: controller));
    Brightness brightness() =>
        CupertinoTheme.brightnessOf(tester.element(find.byType(ChatScreen)));
    expect(brightness(), Brightness.light);
    dispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.dark);
    await controller.select(AppAppearance.light);
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.light);
    await controller.select(AppAppearance.system);
    await tester.pumpAndSettle();
    expect(brightness(), Brightness.dark);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dark layout fits mobile and desktop', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = ThemeController(initial: AppAppearance.dark);
    addTearDown(controller.dispose);
    for (final size in [const Size(390, 844), const Size(1280, 800)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(ChatApp(themeController: controller));
      expect(find.text('Como posso ajudar?'), findsOneWidget);
      final context = tester.element(find.byType(ChatScreen));
      expect(CupertinoTheme.of(context).scaffoldBackgroundColor,
          ChatPalette(true).background);
      expect(tester.takeException(), isNull);
    }
  });
}
