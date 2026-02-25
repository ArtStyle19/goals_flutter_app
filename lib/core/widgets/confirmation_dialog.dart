import 'package:flutter/material.dart';

import 'package:productivity/app/theme/app_colors.dart';

/// Shows a polished confirmation dialog and returns `true` if the user confirms.
///
/// Supports an optional [icon] displayed in a tinted circle above the title,
/// making it suitable for exit-confirmations, delete-confirmations, etc.
/// Falls back to a clean text-only layout when no icon is provided.
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
  bool isDestructive = false,
  IconData? icon,
  Color? iconColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => _ConfirmationDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
      icon: icon,
      iconColor: iconColor,
    ),
  );
  return result ?? false;
}

class _ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final IconData? icon;
  final Color? iconColor;

  const _ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDestructive,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = isDestructive
        ? theme.colorScheme.error
        : (iconColor ?? AppColors.primary);

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Icon badge ──────────────────────────────
          if (icon != null) ...[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: accentColor),
            ),
            const SizedBox(height: 20),
          ],

          // ─── Title ───────────────────────────────────
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // ─── Message ─────────────────────────────────
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            // ─── Cancel ──────────────────────────────
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelLabel),
              ),
            ),
            const SizedBox(width: 12),

            // ─── Confirm ─────────────────────────────
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: isDestructive
                    ? FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                      )
                    : null,
                child: Text(confirmLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
