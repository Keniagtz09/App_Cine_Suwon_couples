class AppConstants {
  AppConstants._();

  static const String appName = 'Cine Suwon';

  // Clave de TMDB inyectada en tiempo de ejecución con:
  // flutter run --dart-define=TMDB_API_KEY=tu_clave_aqui
  static const String tmdbApiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: '',
  );

  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String tmdbBackdropBaseUrl = 'https://image.tmdb.org/t/p/w780';

  // Idiomas soportados en TMDB
  static const Map<String, String> supportedLanguages = {
    'es-MX': 'Español',
    'en-US': 'English',
    'ko-KR': '한국어',
  };

  // Límite cerrado por sala de pareja
  static const int maxRoomMembers = 2;
}