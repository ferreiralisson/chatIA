import 'package:flutter/material.dart';
import 'package:rick_morty/models/character.dart';
import 'package:rick_morty/theme/app_theme.dart';
import 'package:rick_morty/widgets/glass_container.dart';
import 'package:rick_morty/widgets/status_badge.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;

  const CharacterCard(
      {super.key, required this.character, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: 16,
        tintOpacity: 0.09,
        blurSigma: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      character.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppTheme.surfaceColor,
                          child: const Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2)),
                        );
                      },
                      errorBuilder: (_, __, _e) => Container(
                        color: AppTheme.surfaceColor,
                        child: const Icon(Icons.person,
                            size: 64, color: Colors.grey),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: StatusBadge(status: character.status),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    character.species,
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
