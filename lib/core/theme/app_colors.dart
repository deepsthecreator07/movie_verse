import 'package:flutter/material.dart';

/// Cinematic dark color palette for MovieVerse.
class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF); // Vivid indigo
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42D4);

  // ── Secondary / Accent ───────────────────────────────
  static const Color accent = Color(0xFFFFB74D); // Warm amber/gold
  static const Color accentLight = Color(0xFFFFD180);
  static const Color accentDark = Color(0xFFF09819);

  // ── Surface / Background ─────────────────────────────
  static const Color background = Color(0xFF0D0D1A); // Near-black deep blue
  static const Color surface = Color(0xFF1A1A2E); // Dark navy card
  static const Color surfaceLight = Color(0xFF252540); // Slightly lighter
  static const Color surfaceElevated = Color(0xFF2D2D4A); // For elevated cards

  // ── Text ─────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textTertiary = Color(0xFF6E6E8A);

  // ── Status ───────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // ── Misc ─────────────────────────────────────────────
  static const Color divider = Color(0xFF2A2A40);
  static const Color shimmerBase = Color(0xFF1A1A2E);
  static const Color shimmerHighlight = Color(0xFF2D2D4A);
  static const Color overlay = Color(0x99000000);

  // ── Gradient Presets ─────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF5A52E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surface, Color(0xFF16162B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient posterOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
