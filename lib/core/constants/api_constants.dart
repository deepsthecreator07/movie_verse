/// API configuration constants for MovieVerse.
///
/// Replace the placeholder keys with your actual API keys.
class ApiConstants {
  ApiConstants._();

  // ── TMDB ──────────────────────────────────────────────
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbApiKey = String.fromEnvironment('TMDB_API_KEY');
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';
  static const String posterW342 = '$tmdbImageBaseUrl/w342';
  static const String posterW500 = '$tmdbImageBaseUrl/w500';
  static const String posterOriginal = '$tmdbImageBaseUrl/original';
  static const String backdropW780 = '$tmdbImageBaseUrl/w780';

  // ── OMDB (backup) ────────────────────────────────────
  static const String omdbBaseUrl = 'https://www.omdbapi.com';
  static const String omdbApiKey = String.fromEnvironment('OMDB_API_KEY');

  // ── Reqres (users API) ───────────────────────────────
  static const String reqresBaseUrl = 'https://reqres.in/api';
  static const String reqresApiKey = String.fromEnvironment('REQRES_API_KEY');

  // ── Timeouts ─────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ── Retry Config ─────────────────────────────────────
  static const int maxRetries = 3;
  static const Duration retryBaseDelay = Duration(seconds: 1);
}
