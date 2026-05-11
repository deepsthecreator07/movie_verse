/// General app-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'MovieVerse';

  // ── Pagination ───────────────────────────────────────
  static const int usersPerPage = 6; // Reqres returns 6 per page
  static const int moviesPerPage = 20; // TMDB returns 20 per page

  // ── Animation Durations ──────────────────────────────
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Duration staggerDelay = Duration(milliseconds: 80);
  static const Duration fadeInDuration = Duration(milliseconds: 400);
  static const Duration heroAnimDuration = Duration(milliseconds: 350);
  static const Duration snackbarDuration = Duration(seconds: 3);

  // ── Spacing ──────────────────────────────────────────
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;
  static const double borderRadius = 16.0;
  static const double borderRadiusSm = 8.0;
  static const double cardElevation = 2.0;

  // ── WorkManager ──────────────────────────────────────
  static const String syncTaskName = 'com.movieverse.userSync';
  static const Duration syncInterval = Duration(hours: 1);
}
