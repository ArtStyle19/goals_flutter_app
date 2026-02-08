/// Application color palette.
library;

import 'package:flutter/material.dart';

abstract final class AppColors {
  // ─── Primary ────────────────────────────────────────────
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // ─── Status ─────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Task Status ────────────────────────────────────────
  static const Color scheduled = Color(0xFF3B82F6);
  static const Color completed = Color(0xFF10B981);
  static const Color skipped = Color(0xFF9CA3AF);
  static const Color locked = Color(0xFFF59E0B);

  // ─── Goal Status ────────────────────────────────────────
  static const Color draft = Color(0xFF9CA3AF);
  static const Color active = Color(0xFF3B82F6);
  static const Color goalCompleted = Color(0xFF10B981);

  // ─── Background ─────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // ─── Text ───────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
}
