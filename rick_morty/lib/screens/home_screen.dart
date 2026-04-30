import 'package:flutter/material.dart';
import 'package:rick_morty/l10n/app_localizations.dart';
import 'package:rick_morty/screens/characters/characters_screen.dart';
import 'package:rick_morty/screens/episodes/episodes_screen.dart';
import 'package:rick_morty/screens/locations/locations_screen.dart';
import 'package:rick_morty/screens/settings/settings_screen.dart';
import 'package:rick_morty/theme/app_theme.dart';
import 'package:rick_morty/widgets/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _screens = [
    CharactersScreen(),
    EpisodesScreen(),
    LocationsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: GlassContainer(
            borderRadius: 32,
            blurSigma: 30,
            tintColor: isDark ? Colors.white : Colors.black,
            tintOpacity: isDark ? 0.14 : 0.05,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _navItem(0, Icons.people_alt_outlined, Icons.people_alt,
                    l10n.characters, isDark)),
                Expanded(child: _navItem(1, Icons.tv_outlined, Icons.tv, l10n.episodes, isDark)),
                Expanded(child: _navItem(2, Icons.explore_outlined, Icons.explore,
                    l10n.locations, isDark)),
                Expanded(child: _navItem(3, Icons.settings_outlined, Icons.settings,
                    l10n.settings, isDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label,
      bool isDark) {
    final isSelected = _currentIndex == index;

    final activePillColor = isDark
        ? Colors.white.withValues(alpha: 0.92)
        : AppTheme.darkBackground.withValues(alpha: 0.88);
    final activeContentColor =
        isDark ? AppTheme.darkBackground : Colors.white;
    final inactiveContentColor =
        isDark ? Colors.white70 : Colors.black54;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: SizedBox(
        width: double.infinity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: isSelected ? activePillColor : Colors.transparent,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? activeContentColor : inactiveContentColor,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: isSelected ? activeContentColor : inactiveContentColor,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.normal,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
