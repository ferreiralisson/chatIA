import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rick_morty/l10n/app_localizations.dart';
import 'package:rick_morty/models/episode.dart';
import 'package:rick_morty/screens/episodes/episode_detail_screen.dart';
import 'package:rick_morty/services/api_service.dart';
import 'package:rick_morty/theme/app_theme.dart';

class EpisodesScreen extends StatefulWidget {
  const EpisodesScreen({super.key});

  @override
  State<EpisodesScreen> createState() => _EpisodesScreenState();
}

class _EpisodesScreenState extends State<EpisodesScreen> {
  final List<Episode> _episodes = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
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

  Future<void> _loadEpisodes({bool reset = false}) async {
    if (_isLoading) return;
    if (reset) {
      _currentPage = 1;
      _episodes.clear();
    }
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getEpisodes(
        page: _currentPage,
        name: _searchQuery.isEmpty ? null : _searchQuery,
      );
      setState(() {
        _totalPages = response.info.pages;
        _episodes.addAll(response.results);
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
      final response = await ApiService.getEpisodes(
        page: _currentPage,
        name: _searchQuery.isEmpty ? null : _searchQuery,
      );
      setState(() {
        _episodes.addAll(response.results);
        _isLoadingMore = false;
      });
    } catch (_) {
      _currentPage--;
      setState(() => _isLoadingMore = false);
    }
  }

  Map<String, List<Episode>> get _bySeason {
    final map = <String, List<Episode>>{};
    for (final ep in _episodes) {
      final season = ep.episode.length >= 3 ? ep.episode.substring(0, 3) : ep.episode;
      map.putIfAbsent(season, () => []).add(ep);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.episodes.toUpperCase()),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.10),
                    Colors.white.withValues(alpha: 0.03),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == val) {
                    _searchQuery = val;
                    _loadEpisodes(reset: true);
                  }
                });
              },
              decoration: InputDecoration(
                hintText: l10n.searchEpisodes,
                prefixIcon: const Icon(Icons.search),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading && _episodes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_episodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.tv_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.noEpisodesFound,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final seasons = _bySeason;
    final keys = seasons.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: () => _loadEpisodes(reset: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 134, 16, 112),
        itemCount: keys.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == keys.length) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator()));
          }
          final season = keys[index];
          return _seasonSection(context, season, seasons[season]!);
        },
      ),
    );
  }

  Widget _seasonSection(BuildContext context, String season, List<Episode> episodes) {
    final l10n = AppLocalizations.of(context)!;
    final num = season.replaceAll(RegExp(r'[^0-9]'), '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.5)),
            ),
            child: Text(
              l10n.season(num),
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        ...episodes.map((ep) => _episodeTile(ep)),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _episodeTile(Episode episode) {
    final epCode = episode.episode.length >= 6
        ? episode.episode.substring(4)
        : episode.episode;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EpisodeDetailScreen(episode: episode)),
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              epCode,
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
        title: Text(episode.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(episode.airDate,
            style:
                const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 13, color: Colors.grey),
      ),
    );
  }
}
