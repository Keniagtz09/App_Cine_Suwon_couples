import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../models/movie_model.dart';

class TmdbService {
  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  void _ensureApiKey() {
    if (AppConstants.tmdbApiKey.isEmpty) {
      throw Exception(
        'Falta la clave de TMDB. Ejecuta la app con --dart-define=TMDB_API_KEY=...',
      );
    }
  }

  /// Obtiene cartelera popular en el idioma indicado (es-MX, en-US, ko-KR)
  Future<List<MovieModel>> getPopularMovies({
    String language = 'es-MX',
    int page = 1,
  }) async {
    _ensureApiKey();

    final uri = Uri.parse('${AppConstants.tmdbBaseUrl}/movie/popular').replace(
      queryParameters: {
        'api_key': AppConstants.tmdbApiKey,
        'language': language,
        'page': page.toString(),
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error TMDB (${response.statusCode}) al cargar películas');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>? ?? [];

    return results
        .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Busca películas por texto en el idioma seleccionado
  Future<List<MovieModel>> searchMovies({
    required String query,
    String language = 'es-MX',
  }) async {
    _ensureApiKey();

    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return getPopularMovies(language: language);
    }

    final uri = Uri.parse('${AppConstants.tmdbBaseUrl}/search/movie').replace(
      queryParameters: {
        'api_key': AppConstants.tmdbApiKey,
        'language': language,
        'query': cleanQuery,
        'include_adult': 'false',
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error TMDB (${response.statusCode}) al buscar películas');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>? ?? [];

    return results
        .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene el detalle de una película en un idioma específico,
  /// con respaldo en en-US si la sinopsis viene vacía en ese idioma.
  Future<MovieModel> getMovieDetail({
    required int movieId,
    required String language,
  }) async {
    _ensureApiKey();

    final uri = Uri.parse('${AppConstants.tmdbBaseUrl}/movie/$movieId').replace(
      queryParameters: {
        'api_key': AppConstants.tmdbApiKey,
        'language': language,
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error TMDB (${response.statusCode}) al cargar detalle');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final movie = MovieModel.fromJson(data);

    // Si en es-MX o ko-KR no hay sinopsis cargada en TMDB, usamos en-US como respaldo
    if (movie.overview.isEmpty && language != 'en-US') {
      final fallbackMovie = await getMovieDetail(
        movieId: movieId,
        language: 'en-US',
      );
      return MovieModel(
        id: movie.id,
        title: movie.title,
        originalTitle: movie.originalTitle,
        overview: fallbackMovie.overview,
        posterPath: movie.posterPath,
        backdropPath: movie.backdropPath,
        releaseDate: movie.releaseDate,
        voteAverage: movie.voteAverage,
      );
    }

    return movie;
  }
}