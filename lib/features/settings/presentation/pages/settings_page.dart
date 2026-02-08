import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:productivity/app/router/routes.dart';
import 'package:productivity/app/theme/theme_provider.dart';
import 'package:productivity/core/error/error_handler.dart';
import 'package:productivity/core/services/notification_scheduler.dart';
import 'package:productivity/core/services/notification_service.dart';
import 'package:productivity/core/widgets/confirmation_dialog.dart';
import 'package:productivity/features/auth/presentation/state/auth_provider.dart';
import 'package:productivity/features/goals/presentation/state/goals_provider.dart';
import 'package:productivity/features/settings/presentation/helpers/export_helper.dart';

/// Settings page with profile info, theme toggle, export, and logout.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ─── Profile Section ───────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    user?.name.substring(0, 1).toUpperCase() ?? '?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Usuario',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // ─── Appearance ────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 4),
            child: Text(
              'Apariencia',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _ThemeModeTile(
            icon: Icons.light_mode_outlined,
            title: 'Claro',
            selected: themeMode == ThemeMode.light,
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setThemeMode(ThemeMode.light),
          ),
          _ThemeModeTile(
            icon: Icons.dark_mode_outlined,
            title: 'Oscuro',
            selected: themeMode == ThemeMode.dark,
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setThemeMode(ThemeMode.dark),
          ),
          _ThemeModeTile(
            icon: Icons.settings_brightness_outlined,
            title: 'Sistema',
            selected: themeMode == ThemeMode.system,
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setThemeMode(ThemeMode.system),
          ),

          const Divider(),

          // ─── Notifications ────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 4),
            child: Text(
              'Notificaciones',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Recordatorios de tareas'),
            subtitle: const Text('15 min antes de cada sesión'),
            value: ref.watch(notificationsEnabledProvider),
            onChanged: (enabled) async {
              final service = ref.read(notificationServiceProvider);
              await service.setEnabled(enabled);
              ref.read(notificationsEnabledProvider.notifier).state = enabled;

              // Trigger an immediate sync so active tasks get notified.
              if (enabled) {
                ref.read(notificationSchedulerProvider).syncNow();
              }
            },
          ),

          const Divider(),

          // ─── Data ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 4),
            child: Text(
              'Datos',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Exportar mis datos'),
            subtitle: const Text('Comparte un resumen de metas y tareas'),
            onTap: () => _exportData(context, ref),
          ),

          const Divider(),

          // ─── Account ───────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 4),
            child: Text(
              'Cuenta',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Cerrar sesión',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final goalsAsync = ref.read(goalsProvider);
      final goals = goalsAsync.valueOrNull ?? [];
      final text = ExportHelper.generateSummary(goals);
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(userFriendlyMessage(e))));
      }
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: '¿Cerrar sesión?',
      message: '¿Estás seguro de que quieres cerrar sesión?',
      confirmLabel: 'Cerrar sesión',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;

    ref.read(authNotifierProvider.notifier).logout();
    context.go(AppRoutes.login);
  }
}

// ─── Private Widgets ──────────────────────────────────────

class _ThemeModeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeModeTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: selected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      selected: selected,
      onTap: onTap,
    );
  }
}
