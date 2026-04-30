import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rick_morty/l10n/app_localizations.dart';
import 'package:rick_morty/models/location.dart';
import 'package:rick_morty/screens/locations/location_detail_screen.dart';
import 'package:rick_morty/services/api_service.dart';
import 'package:rick_morty/theme/app_theme.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final List<Location> _locations = [];
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
    _loadLocations();
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

  Future<void> _loadLocations({bool reset = false}) async {
    if (_isLoading) return;
    if (reset) {
      _currentPage = 1;
      _locations.clear();
    }
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getLocations(
        page: _currentPage,
        name: _searchQuery.isEmpty ? null : _searchQuery,
      );
      setState(() {
        _totalPages = response.info.pages;
        _locations.addAll(response.results);
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
      final response = await ApiService.getLocations(
        page: _currentPage,
        name: _searchQuery.isEmpty ? null : _searchQuery,
      );
      setState(() {
        _locations.addAll(response.results);
        _isLoadingMore = false;
      });
    } catch (_) {
      _currentPage--;
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.locations.toUpperCase()),
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
                    _loadLocations(reset: true);
                  }
                });
              },
              decoration: InputDecoration(
                hintText: l10n.searchLocations,
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
    if (_isLoading && _locations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_locations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.noLocationsFound,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _loadLocations(reset: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 134, 16, 112),
        itemCount: _locations.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _locations.length) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator()));
          }
          return _locationCard(_locations[index]);
        },
      ),
    );
  }

  Widget _locationCard(Location location) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  LocationDetailScreen(location: location)),
        ),
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.place, color: AppTheme.primaryGreen),
        ),
        title: Text(location.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(location.type,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 12)),
            if (location.dimension.isNotEmpty &&
                location.dimension != 'unknown')
              Text(
                location.dimension,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people, size: 14, color: Colors.grey),
            const SizedBox(height: 2),
            Text(
              '${location.residents.length}',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
