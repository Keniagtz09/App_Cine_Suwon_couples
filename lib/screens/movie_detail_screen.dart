import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/irworobongdo_theme.dart';
import '../models/movie_model.dart';
import '../services/room_service.dart';
import '../services/tmdb_service.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({
    super.key,
    required this.initialMovie,
    required this.initialLanguage,
  });

  final MovieModel initialMovie;
  final String initialLanguage;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final TmdbService _tmdbService = TmdbService();
  final RoomService _roomService = RoomService();

  late String _selectedLanguage;
  late MovieModel _movie;
  bool _isLoadingDetail = false;
  bool _isSavingToRoom = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage;
    _movie = widget.initialMovie;
  }

  Future<void> _changeLanguage(String languageCode) async {
    if (_selectedLanguage == languageCode) return;

    setState(() {
      _selectedLanguage = languageCode;
      _isLoadingDetail = true;
      _errorMessage = null;
    });

    try {
      final detailedMovie = await _tmdbService.getMovieDetail(
        movieId: _movie.id,
        language: languageCode,
      );

      if (!mounted) return;
      setState(() {
        _movie = detailedMovie;
        _isLoadingDetail = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoadingDetail = false;
      });
    }
  }

  Future<void> _addToSharedWatchlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSavingToRoom = true);

    try {
      final roomSnapshot =
          await _roomService.watchUserRooms(user.uid).first;

      if (roomSnapshot.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: IrworobongdoColors.deepIndigo,
            content: Text(
              'Primero crea o únete a una sala privada.',
              style: TextStyle(color: IrworobongdoColors.ivory),
            ),
          ),
        );
        return;
      }

      final roomId = roomSnapshot.docs.first.id;
      await _roomService.addMovieToWatchlist(
        roomId: roomId,
        movie: _movie,
        addedByUid: user.uid,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: IrworobongdoColors.jade,
          content: Text(
            '«${_movie.title}» agregada a Nuestra Lista',
            style: const TextStyle(
              color: IrworobongdoColors.ivory,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: IrworobongdoColors.vermilion,
          content: Text(
            'Error al guardar: ${e.toString().replaceFirst('Exception: ', '')}',
            style: const TextStyle(color: IrworobongdoColors.ivory),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingToRoom = false);
      }
    }
  }

  String get _synopsisLabel {
    switch (_selectedLanguage) {
      case 'ko-KR':
        return '줄거리';
      case 'en-US':
        return 'Synopsis';
      default:
        return 'Sinopsis';
    }
  }

  String get _emptyOverviewLabel {
    switch (_selectedLanguage) {
      case 'ko-KR':
        return '등록된 줄거리가 없습니다.';
      case 'en-US':
        return 'No overview available for this movie.';
      default:
        return 'Sin sinopsis disponible para esta película.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final headerImage = _movie.fullBackdropUrl.isNotEmpty
        ? _movie.fullBackdropUrl
        : _movie.fullPosterUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _movie.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (headerImage.isNotEmpty)
                    Image.network(
                      headerImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildFallbackBanner(),
                    )
                  else
                    _buildFallbackBanner(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          IrworobongdoColors.nightSky.withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _movie.title,
                    style: textTheme.headlineMedium,
                  ),
                  if (_movie.originalTitle.isNotEmpty &&
                      _movie.originalTitle != _movie.title) ...[
                    const SizedBox(height: 4),
                    Text(
                      _movie.originalTitle,
                      style: textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: IrworobongdoColors.deepIndigo,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: IrworobongdoColors.warmGold
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: IrworobongdoColors.warmGold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _movie.voteAverage.toStringAsFixed(1),
                              style: textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: IrworobongdoColors.deepIndigo,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: IrworobongdoColors.borderSubtle,
                          ),
                        ),
                        child: Text(
                          _movie.releaseYear,
                          style: textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSavingToRoom ? null : _addToSharedWatchlist,
                      icon: _isSavingToRoom
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: IrworobongdoColors.ivory,
                              ),
                            )
                          : const Icon(Icons.bookmark_add_rounded),
                      label: const Text('Agregar a Nuestra Lista'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    children:
                        AppConstants.supportedLanguages.entries.map((entry) {
                      final isSelected = _selectedLanguage == entry.key;
                      return ChoiceChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (_) => _changeLanguage(entry.key),
                        selectedColor:
                            IrworobongdoColors.jade.withValues(alpha: 0.3),
                        checkmarkColor: IrworobongdoColors.ivory,
                        side: BorderSide(
                          color: isSelected
                              ? IrworobongdoColors.jade
                              : IrworobongdoColors.borderSubtle,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _synopsisLabel,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (_isLoadingDetail)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: IrworobongdoColors.vermilion,
                        ),
                      ),
                    )
                  else if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: IrworobongdoColors.vermilion,
                      ),
                    )
                  else
                    Text(
                      _movie.overview.isNotEmpty
                          ? _movie.overview
                          : _emptyOverviewLabel,
                      style: textTheme.bodyLarge?.copyWith(height: 1.55),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      color: IrworobongdoColors.elevatedIndigo,
      child: const Center(
        child: Icon(
          Icons.local_movies_rounded,
          size: 48,
          color: IrworobongdoColors.mutedIvory,
        ),
      ),
    );
  }
}