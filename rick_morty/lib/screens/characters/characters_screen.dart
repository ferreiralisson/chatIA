import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rick_morty/l10n/app_localizations.dart';
import 'package:rick_morty/models/character.dart';
import 'package:rick_morty/screens/characters/character_detail_screen.dart';
import 'package:rick_morty/services/api_service.dart';
import 'package:rick_morty/theme/app_theme.dart';
import 'package:rick_morty/widgets/character_card.dart';

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  final List<Character> _characters = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    _loadCharacters();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadCharacters({bool reset = false}) async {
    if (_isLoading) return;
    if (reset) {
      _currentPage = 1;
      _characters.clear();
    }
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getCharacters(
        page: _currentPage,
        name: _searchQuery.isEmpty ? null : _searchQuery,
        status: _statusFilter.isEmpty ? null : _statusFilter,
      );
      setState(() {
        _totalPages = response.info.pages;
        _characters.addAll(response.results);
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    _currentPage++;
    setState(() => _isLoadingMore = true);
    try {
      final response = await ApiService.getCharacters(
        page: _currentPage,
        name: _searchQuery.isEmpty ? null : _searchQuery,
        status: _statusFilter.isEmpty ? null : _statusFilter,
      );
      setState(() {
        _characters.addAll(response.results);
        _isLoadingMore = false;
      });
    } catch (_) {
      _currentPage--;
      setState(() => _isLoadingMore = false);
    }
  }

  void _setStatus(String status) {
    setState(() => _statusFilter = _statusFilter == status ? '' : status);
    _loadCharacters(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.appTitle),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Builder(
              builder: (context) {
                final isDark =
                    Theme.of(context).brightness == Brightness.dark;
                final tint = isDark ? Colors.black : Colors.white;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        tint.withValues(alpha: isDark ? 0.55 : 0.72),
                        tint.withValues(alpha: isDark ? 0.38 : 0.55),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_searchController.text == val) {
                        _searchQuery = val;
                        _loadCharacters(reset: true);
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: l10n.searchCharacters,
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _filterChip(l10n.statusAlive, 'alive', Colors.green),
                    const SizedBox(width: 8),
                    _filterChip(l10n.statusDead, 'dead', Colors.red),
                    const SizedBox(width: 8),
                    _filterChip(l10n.statusUnknown, 'unknown', Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _filterChip(String label, String value, Color color) {
    final selected = _statusFilter == value;
    return GestureDetector(
      onTap: () => _setStatus(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.25)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                  color: selected ? color : Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading && _characters.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_characters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.noCharactersFound,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _loadCharacters(reset: true),
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top + 180, 12, 112),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _characters.length + (_isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= _characters.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final character = _characters[index];
          return CharacterCard(
            character: character,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CharacterDetailScreen(character: character),
              ),
            ),
          );
        },
      ),
    );
  }
}
