import 'package:flutter/material.dart';
import 'package:rick_morty/l10n/app_localizations.dart';
import 'package:rick_morty/models/character.dart';
import 'package:rick_morty/theme/app_theme.dart';
import 'package:rick_morty/widgets/status_badge.dart';

class CharacterDetailScreen extends StatelessWidget {
  final Character character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                character.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    character.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, _e) => Container(
                      color: AppTheme.surfaceColor,
                      child: const Icon(Icons.person,
                          size: 80, color: Colors.grey),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.darkBackground.withValues(alpha: 0.95),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge(status: character.status),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          character.type.isNotEmpty
                              ? '${character.species} — ${character.type}'
                              : character.species,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle(l10n.information),
                  const SizedBox(height: 10),
                  _infoCard([
                    _infoRow(l10n.gender, character.gender),
                    _divider(),
                    _infoRow(l10n.origin, character.origin.name),
                    _divider(),
                    _infoRow(l10n.lastLocation, character.location.name),
                    _divider(),
                    _infoRow(
                        l10n.episodes, '${character.episode.length}'),
                  ]),
                  const SizedBox(height: 24),
                  _sectionTitle(
                      l10n.episodesCount(character.episode.length)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: character.episode.map((url) {
                      final ep = url.split('/').last;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryGreen
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'EP $ep',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryGreen),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          color: AppTheme.primaryGreen,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _infoCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: children),
      );

  Widget _infoRow(String label, String value) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      );

  Widget _divider() => Divider(
      height: 1, color: Color(0xFF2A2A4A), indent: 16, endIndent: 16);
}
