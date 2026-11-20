import 'dart:async';
import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/irworobongdo_theme.dart';
import '../models/movie_model.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TmdbService _tmdbService = TmdbService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  String _selectedLanguage = 'es-MX';
  List<MovieModel> _movies = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final query = _searchController.text.trim();
      final results = query.isEmpty
          ? await _tmdbService.getPopularMovies(language: _selectedLanguage)
          : await _tmdbService.searchMovies(
              query: query,
              language: _selectedLanguage,
            );

      if (!mounted) return;
      setState(() {
        _movies = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _fetchMovies);
    setState(() {});
  }

  void _onLanguageChanged(String languageCode) {
    if (_selectedLanguage == languageCode) return;
    setState(() {
      _selectedLanguage = languageCode;
    });
    _fetchMovies();
  }

  String get _searchHint {
    switch (_selectedLanguage) {
      case 'ko-KR':
        return '영화 제목 검색...';
      case 'en-US':
        return 'Search movies...';
      default:
        return 'Buscar películas...';
    }
  }

  String get _sectionHeading {
    final isSearching = _searchController.text.trim().isNotEmpty;
    switch (_selectedLanguage) {
      case 'ko-KR':
        return isSearching ? '검색 결과' : '인기 영화';
      case 'en-US':
        return isSearching ? 'Search Results' : 'Popular Movies';
      default:
        return isSearching ? 'Resultados de búsqueda' : 'Películas populares';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cine Suwon · 수원 영화'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _fetchMovies(),
              decoration: InputDecoration(
                hintText: _searchHint,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: IrworobongdoColors.mutedIvory,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: IrworobongdoColors.mutedIvory,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _fetchMovies();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: AppConstants.supportedLanguages.entries.map((entry) {
                final isSelected = _selectedLanguage == entry.key;
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (_) => _onLanguageChanged(entry.key),
                  selectedColor: IrworobongdoColors.jade.withValues(alpha: 0.3),
                  checkmarkColor: IrworobongdoColors.ivory,
                  side: BorderSide(
                    color: isSelected
                        ? IrworobongdoColors.jade
                        : IrworobongdoColors.borderSubtle,
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              _sectionHeading,
              style: textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: _buildBody(textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(TextTheme textTheme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: IrworobongdoColors.vermilion,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 44,
                color: IrworobongdoColors.vermilion,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: _fetchMovies,
                  child: const Text('Reintentar'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_movies.isEmpty) {
      return Center(
        child: Text(
          'Sin resultados / 검색 결과가 없습니다',
          style: textTheme.bodyMedium,
        ),
      );
    }

    return RefreshIndicator(
      color: IrworobongdoColors.vermilion,
      backgroundColor: IrworobongdoColors.deepIndigo,
      onRefresh: _fetchMovies,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          final movie = _movies[index];
return MovieCard(
            movie: movie,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MovieDetailScreen(
                    initialMovie: movie,
                    initialLanguage: _selectedLanguage,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}