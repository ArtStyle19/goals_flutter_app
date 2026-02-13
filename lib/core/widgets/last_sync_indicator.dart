/// Widget that displays the last sync timestamp.
///
/// Shows when data was last synchronized with the server.
/// Useful for offline-first apps to indicate data freshness.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:productivity/app/theme/app_colors.dart';

/// Provider for the last sync timestamp.
/// This is a simple state provider that can be updated by notifiers.
final lastSyncTimestampProvider = StateProvider<DateTime?>((ref) => null);

/// A small indicator showing when data was last synced.
///
/// Usage:
/// ```dart
/// LastSyncIndicator(
///   timestamp: lastSync,
///   isLoading: isLoading,
/// )
/// ```
class LastSyncIndicator extends StatelessWidget {
  /// The last sync timestamp. If null, shows "Never synced".
  final DateTime? timestamp;

  /// Whether data is currently loading.
  final bool isLoading;

  /// Optional custom text style.
  final TextStyle? textStyle;

  /// Whether to show the icon.
  final bool showIcon;

  const LastSyncIndicator({
    super.key,
    this.timestamp,
    this.isLoading = false,
    this.textStyle,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String text;
    IconData icon;
    Color color;

    if (isLoading) {
      text = 'Sincronizando...';
      icon = Icons.sync;
      color = AppColors.primary;
    } else if (timestamp == null) {
      text = 'Sin sincronizar';
      icon = Icons.sync_problem;
      color = AppColors.textSecondary;
    } else {
      final now = DateTime.now();
      final diff = now.difference(timestamp!);

      if (diff.inMinutes < 1) {
        text = 'Actualizado ahora';
      } else if (diff.inHours < 1) {
        text = 'Hace ${diff.inMinutes} min';
      } else if (diff.inDays < 1) {
        final timeStr = DateFormat.Hm().format(timestamp!);
        text = 'Hoy $timeStr';
      } else if (diff.inDays == 1) {
        final timeStr = DateFormat.Hm().format(timestamp!);
        text = 'Ayer $timeStr';
      } else {
        final dateStr = DateFormat('dd/MM HH:mm').format(timestamp!);
        text = dateStr;
      }

      // Color based on freshness
      if (diff.inHours < 1) {
        color = AppColors.success;
      } else if (diff.inDays < 1) {
        color = AppColors.primary;
      } else {
        color = AppColors.warning;
      }

      icon = Icons.check_circle;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style:
              textStyle ??
              theme.textTheme.bodySmall?.copyWith(color: color, fontSize: 12),
        ),
      ],
    );
  }
}

/// A header widget that combines title with sync indicator.
///
/// Useful for list pages that need to show sync status.
class SyncHeader extends StatelessWidget {
  final String title;
  final DateTime? lastSync;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const SyncHeader({
    super.key,
    required this.title,
    this.lastSync,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        LastSyncIndicator(timestamp: lastSync, isLoading: isLoading),
        if (onRefresh != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: isLoading ? null : onRefresh,
            tooltip: 'Actualizar',
          ),
        ],
      ],
    );
  }
}
