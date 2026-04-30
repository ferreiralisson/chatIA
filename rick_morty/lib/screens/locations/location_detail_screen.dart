import 'package:flutter/material.dart';
import 'package:rick_morty/l10n/app_localizations.dart';
import 'package:rick_morty/models/character.dart';
import 'package:rick_morty/models/location.dart';
import 'package:rick_morty/screens/characters/character_detail_screen.dart';
import 'package:rick_morty/services/api_service.dart';
import 'package:rick_morty/theme/app_theme.dart';
import 'package:rick_morty/widgets/status_badge.dart';

class LocationDetailScreen extends StatefulWidget {
  final Location location;

  const LocationDetailScreen({super.key, required this.location});

  @override
  State<LocationDetailScreen> createState() =>
      _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  List<Character>? _residents;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResidents();
  }

  Future<void> _loadResidents() async {
    if (widget.location.residents.isEmpty) {
      setState(() {
        _residents = [];
        _isLoading = false;
      });
      return;
    }
    try {
      final urls = widget.location.residents.take(20).toList();
      final chars = await ApiService.getCharactersByUrls(urls);
      setState(() {
        _residents = chars;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loc = widget.location;
    return Scaffold(
      appBar: AppBar(title: Text(loc.name)),
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
              children: [
                _row(l10n.fieldType, loc.type.isNotEmpty ? loc.type : '—'),
                _divider(),
                _row(l10n.dimension,
                    loc.dimension.isNotEmpty ? loc.dimension : '—'),
                _divider(),
                _row(l10n.residents, '${loc.residents.length}'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            loc.residents.length > 20
                ? l10n.residentsShowing(loc.residents.length)
                : l10n.residents,
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
          else if (_residents == null || _residents!.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.noResidentsFound,
                  style: const TextStyle(color: Colors.grey)),
            )
          else
            _buildResidentGrid(),
        ],
      ),
    );
  }

  Widget _buildResidentGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.78,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _residents!.length,
      itemBuilder: (context, index) {
        final char = _residents![index];
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

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
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
      height: 1, color: Color(0xFF2A2A4A), indent: 0, endIndent: 0);
}
