/// Application color palette — "Zinc & Indigo" Professional Design System.
///
/// A robust, high-contrast dark theme inspired by modern enterprise UI design.
/// Uses a neutral "Zinc" scale for backgrounds/surfaces to maximize content readability,
/// paired with a vibrant "Indigo" primary for focus and action.
///
/// Design Principles:
/// 1. **Content-First**: Neutral backgrounds (Zinc 950/900) let content pop.
/// 2. **Subtle Boundaries**: Uses borders (Zinc 800) instead of heavy shadows for separation.
/// 3. **Semantic Clarity**: Distinct colors for success, error, and warning states.
/// 4. **Accessibility**: High contrast ratios for text and primary actions.
library;

import 'package:flutter/material.dart';

abstract final class AppColors {
  // ─── Primary (Indigo) ───────────────────────────────────
  /// Primary brand color. Used for main actions, active states, and focus.
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo 600
  static const Color secondary = Color(0xFF22C55E); // Emerald 500

  // ─── Semantic Status Colors ─────────────────────────────
  static const Color success = Color(0xFF22C55E); // Green 500
  static const Color warning = Color(0xFFEAB308); // Yellow 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // ─── Task & Goal Status (Semantic Mappings) ─────────────
  static const Color scheduled = Color(0xFF3B82F6); // Blue
  static const Color completed = Color(0xFF22C55E); // Green
  static const Color skipped = Color(0xFF71717A); // Zinc 500
  static const Color locked = Color(0xFFEAB308); // Yellow

  static const Color draft = Color(0xFF71717A); // Zinc 500
  static const Color active = Color(0xFF3B82F6); // Blue
  static const Color goalCompleted = Color(0xFF22C55E); // Green
  static const Color archived = Color(0xFF52525B); // Zinc 600

  // ─── Neutral Scale (Zinc) ───────────────────────────────
  // Used for backgrounds, surfaces, borders, and text.
  
  /// Main background color. Deepest black/zinc.
  static const Color background = Color(0xFF09090B); // Zinc 950

  /// Surface color for cards, modals, and sheets.
  static const Color surface = Color(0xFF202023); // Zinc 900 (Tweaked Lighter)

  /// Secondary surface for inputs, hover states, or subtle grouping.
  static const Color surfaceVariant = Color(0xFF27272A); // Zinc 800

  /// Tertiary surface/container.
  static const Color surfaceContainer = Color(0xFF27272A); // Zinc 800

  // ─── Borders & Dividers ────────────────────────────────
  /// Subtle border for component separation.
  static const Color border = Color(0xFF52525B); // Zinc 600 (Higher Contrast)
  
  /// Slightly stronger border for interactive elements.
  static const Color borderHighlight = Color(0xFF71717A); // Zinc 500
  
  /// Divider line color.
  static const Color divider = Color(0xFF3F3F46); // Zinc 700

  // ─── Text ───────────────────────────────────────────────
  /// High-emphasis text (Headings, primary content).
  static const Color textPrimary = Color(0xFFFAFAFA); // Zinc 50

  /// Medium-emphasis text (Body, labels, descriptions).
  static const Color textSecondary = Color(0xFFA1A1AA); // Zinc 400

  /// Low-emphasis text (Hints, disabled, placeholders).
  static const Color textHint = Color(0xFF71717A); // Zinc 500

  /// Text on colored backgrounds (Primary/Error).
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Visual Effects ─────────────────────────────────────
  static const Color shimmerBase = Color(0xFF27272A); // Zinc 800
  static const Color shimmerHighlight = Color(0xFF3F3F46); // Zinc 700
}
