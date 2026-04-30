import 'package:flutter/material.dart';
import 'package:rick_morty/l10n/app_localizations.dart';
import 'package:rick_morty/models/character.dart';
import 'package:rick_morty/models/episode.dart';
import 'package:rick_morty/screens/characters/character_detail_screen.dart';
import 'package:rick_morty/services/api_service.dart';
import 'package:rick_morty/theme/app_theme.dart';
import 'package:rick_morty/widgets/status_badge.dart';

class EpisodeDetailScreen extends StatefulWidget {
  final Episode episode;

  const EpisodeDetailScreen({super.key, required this.episode});

  @override
  State<EpisodeDetailScreen> createState() => _EpisodeDetailScreenState();
}

class _EpisodeDetailScreenState extends State<EpisodeDetailScreen> {
  List<Character>? _characters;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    try {
      final chars = await ApiService.getCharactersByUrls(
          widget.episode.characters.take(20).toList());
      setState(() {
        _characters = chars;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ep = widget.episode;
    return Scaffold(
      appBar: AppBar(title: Text(ep.episode)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ep.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(ep.airDate,
                        style: const TextStyle(color: Colors.grey)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color:
                            AppTheme.primaryGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ep.episode,
                        style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text('${ep.characters.length} ${l10n.characters.toLowerCase()}',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.charactersSection,
            style: const TextStyle(
              color: AppTheme.primaryGreen,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator()))
          else if (_characters == null || _characters!.isEmpty)
            Text(l10n.noCharactersFound,
                style: const TextStyle(color: Colors.grey))
          else
            _buildCharacterGrid(),
        ],
      ),
    );
  }

  Widget _buildCharacterGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.78,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _characters!.length,
      itemBuilder: (context, index) {
        final char = _characters![index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    CharacterDetailScreen(character: char)),
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        char.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, _e) => Container(
                          color: AppTheme.surfaceColor,
                          child: const Icon(Icons.person,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: StatusBadge(status: char.status),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                char.name,
                style: const TextStyle(fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
