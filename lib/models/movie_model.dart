import '../core/constants/app_constants.dart';

class MovieModel {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;

  const MovieModel({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : (json['original_title'] as String? ?? 'Sin título'),
      originalTitle: json['original_title'] as String? ?? '',
      overview: (json['overview'] as String?)?.trim() ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get fullPosterUrl =>
      posterPath != null && posterPath!.isNotEmpty
          ? '${AppConstants.tmdbImageBaseUrl}$posterPath'
          : '';

  String get fullBackdropUrl =>
      backdropPath != null && backdropPath!.isNotEmpty
          ? '${AppConstants.tmdbBackdropBaseUrl}$backdropPath'
          : '';

  String get releaseYear =>
      releaseDate.length >= 4 ? releaseDate.substring(0, 4) : 'N/D';
}