import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rick_morty/l10n/app_localizations.dart';
import 'package:rick_morty/providers/app_settings.dart';
import 'package:rick_morty/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = AppSettingsScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.settings),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.10 : 0.55),
                    Colors.white.withValues(alpha: isDark ? 0.03 : 0.20),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.40),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 80,
          20,
          112,
        ),
        children: [
          _SectionHeader(label: l10n.theme, isDark: isDark),
          const SizedBox(height: 8),
          _GlassCard(
            isDark: isDark,
            children: [
              _OptionTile(
                isDark: isDark,
                icon: Icons.dark_mode_outlined,
                label: l10n.darkTheme,
                selected: settings.themeMode == ThemeMode.dark,
                onTap: () => settings.setThemeMode(ThemeMode.dark),
              ),
              _Divider(isDark: isDark),
              _OptionTile(
                isDark: isDark,
                icon: Icons.light_mode_outlined,
                label: l10n.lightTheme,
                selected: settings.themeMode == ThemeMode.light,
                onTap: () => settings.setThemeMode(ThemeMode.light),
              ),
            ],
          ),

          const SizedBox(height: 28),

          _SectionHeader(label: l10n.language, isDark: isDark),
          const SizedBox(height: 8),
          _GlassCard(
            isDark: isDark,
            children: [
              _OptionTile(
                isDark: isDark,
                label: l10n.langPortuguese,
                flag: '🇧🇷',
                selected: settings.locale.languageCode == 'pt',
                onTap: () => settings.setLocale(const Locale('pt')),
              ),
              _Divider(isDark: isDark),
              _OptionTile(
                isDark: isDark,
                label: l10n.langEnglish,
                flag: '🇺🇸',
                selected: settings.locale.languageCode == 'en',
                onTap: () => settings.setLocale(const Locale('en')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppTheme.primaryGreen.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;

  const _GlassCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.04),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.72),
                      Colors.white.withValues(alpha: 0.45),
                    ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.55),
              width: 0.8,
            ),
          ),
          child: Column(children: children),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? flag;
  final bool isDark;

  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
    this.icon,
    this.flag,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtleColor = isDark ? Colors.white54 : Colors.black45;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            if (flag != null)
              Text(flag!, style: const TextStyle(fontSize: 22))
            else if (icon != null)
              Icon(icon, size: 22, color: subtleColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? Container(
                      key: const ValueKey(true),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          size: 15, color: Colors.black),
                    )
                  : SizedBox(
                      key: const ValueKey(false),
                      width: 24,
                      height: 24,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 54,
      endIndent: 18,
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.07),
    );
  }
}
