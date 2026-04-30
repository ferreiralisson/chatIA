import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rick_morty/l10n/app_localizations.dart';
import 'package:rick_morty/providers/app_settings.dart';
import 'package:rick_morty/screens/home_screen.dart';
import 'package:rick_morty/theme/app_theme.dart';

void main() {
  runApp(const RickMortyApp());
}

class RickMortyApp extends StatefulWidget {
  const RickMortyApp({super.key});

  @override
  State<RickMortyApp> createState() => _RickMortyAppState();
}

class _RickMortyAppState extends State<RickMortyApp> {
  final AppSettings _settings = AppSettings();

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      settings: _settings,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (_, __) => MaterialApp(
          title: 'Rick & Morty',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _settings.themeMode,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: isDark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
              child: Container(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppTheme.backgroundGradient
                      : AppTheme.lightBackgroundGradient,
                ),
                child: child!,
              ),
            );
          },
          locale: _settings.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt'),
            Locale('en'),
          ],
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
