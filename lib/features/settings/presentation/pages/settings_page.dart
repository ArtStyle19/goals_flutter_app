import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:productivity/app/router/routes.dart';
import 'package:productivity/app/theme/theme_provider.dart';
import 'package:productivity/core/error/error_handler.dart';
import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/core/services/notification_scheduler.dart';
import 'package:productivity/core/services/notification_service.dart';
import 'package:productivity/core/services/fcm_service.dart';
import 'package:productivity/core/utils/date_utils.dart';
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
              'Notificaciones Locales',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _NotificationTestSection(),

          const Divider(),

          // ─── FCM Push Notifications ───────────────
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 4),
            child: Text(
              'Notificaciones Push (FCM)',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _FCMTestSection(),

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

    await ref.read(authProvider.notifier).logout();
    if (!context.mounted) return;
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

/// Section for testing notifications with instant and scheduled options.
class _NotificationTestSection extends ConsumerStatefulWidget {
  const _NotificationTestSection();

  @override
  ConsumerState<_NotificationTestSection> createState() =>
      _NotificationTestSectionState();
}

class _NotificationTestSectionState
    extends ConsumerState<_NotificationTestSection> {
  final List<_ScheduledNotification> _scheduledNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadScheduledNotifications();
  }

  Future<void> _loadScheduledNotifications() async {
    // Load from local storage using NotificationService
    final service = ref.read(notificationServiceProvider);
    final ids = await service.getScheduledTestNotificationIds();

    setState(() {
      _scheduledNotifications.clear();
      for (final id in ids) {
        _scheduledNotifications.add(
          _ScheduledNotification(
            id: id,
            scheduledTime: DateTime.now(), // Will be loaded from storage
          ),
        );
      }
    });
  }

  Future<void> _showInstantNotification() async {
    final service = ref.read(notificationServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await service.showTestNotification();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('🔔 Notificación enviada. Verifica que suene y vibre.'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${userFriendlyMessage(e)}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _scheduleNotification() async {
    // Check for exact alarm permission on Android 12+
    final canScheduleExact = await NotificationService.canScheduleExactAlarms();
    if (!canScheduleExact && mounted) {
      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permiso requerido'),
          content: const Text(
            'Para programar notificaciones exactas, necesitas habilitar el permiso '
            '"Alarmas y recordatorios" en la configuración del sistema.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Abrir configuración'),
            ),
          ],
        ),
      );

      if (shouldRequest == true) {
        final granted = await NotificationService.requestExactAlarmPermission();
        if (!granted && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permiso no concedido. La notificación podría no ser exacta.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }

    final now = DateTime.now();
    final initialDate = now.add(const Duration(minutes: 1));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Selecciona la fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (selectedDate == null || !mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: 'Selecciona la hora',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (selectedTime == null || !mounted) return;

    final scheduledDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Validate it's in the future
    if (scheduledDate.isBefore(DateTime.now())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La fecha debe ser en el futuro'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final service = ref.read(notificationServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final id = await service.scheduleTestNotification(scheduledDate);

      setState(() {
        _scheduledNotifications.add(
          _ScheduledNotification(id: id, scheduledTime: scheduledDate),
        );
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '⏰ Notificación programada para ${AppDateUtils.formatFull(scheduledDate)}',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${userFriendlyMessage(e)}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _cancelNotification(int id) async {
    final service = ref.read(notificationServiceProvider);
    await service.cancelTestNotification(id);

    setState(() {
      _scheduledNotifications.removeWhere((n) => n.id == id);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificación cancelada'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enable/Disable toggle
        SwitchListTile(
          secondary: const Icon(Icons.notifications_outlined),
          title: const Text('Habilitar notificaciones'),
          subtitle: const Text('Activa o desactiva todas las notificaciones'),
          value: notificationsEnabled,
          onChanged: (enabled) async {
            final service = ref.read(notificationServiceProvider);
            await service.setEnabled(enabled);
            ref.read(notificationsEnabledProvider.notifier).state = enabled;

            if (enabled) {
              ref.read(notificationSchedulerProvider).syncNow();
            }

            // Reload scheduled notifications state
            if (enabled) {
              await _loadScheduledNotifications();
            } else {
              setState(() => _scheduledNotifications.clear());
            }
          },
        ),

        if (notificationsEnabled) ...[
          const Divider(indent: 16, endIndent: 16, height: 1),

          // Instant test button
          ListTile(
            leading: Icon(
              Icons.notifications_active_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Test Notificación Instantánea'),
            subtitle: const Text('Envía una notificación de prueba ahora'),
            trailing: ElevatedButton.icon(
              onPressed: _showInstantNotification,
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Probar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),

          // Scheduled test button
          ListTile(
            leading: Icon(
              Icons.schedule_outlined,
              color: theme.colorScheme.secondary,
            ),
            title: const Text('Test Notificación Programada'),
            subtitle: const Text('Programa una notificación para más tarde'),
            trailing: ElevatedButton.icon(
              onPressed: _scheduleNotification,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Programar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),

          // Scheduled notifications list
          if (_scheduledNotifications.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
              child: Text(
                'Notificaciones programadas (${_scheduledNotifications.length})',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ..._scheduledNotifications.map(
              (notification) => ListTile(
                dense: true,
                leading: const Icon(
                  Icons.access_time,
                  size: 20,
                  color: Colors.grey,
                ),
                title: Text(
                  AppDateUtils.formatFull(notification.scheduledTime),
                  style: theme.textTheme.bodyMedium,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  onPressed: () => _cancelNotification(notification.id),
                  tooltip: 'Cancelar',
                ),
              ),
            ),
          ],

          // Info text
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Las notificaciones programadas funcionarán incluso si reinicias o apagas el teléfono. '
                      'Asegúrate de que los permisos de notificación estén habilitados en la configuración del sistema.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Simple data class for scheduled notifications.
class _ScheduledNotification {
  final int id;
  final DateTime scheduledTime;

  const _ScheduledNotification({required this.id, required this.scheduledTime});
}

/// Section for testing FCM push notifications from backend.
class _FCMTestSection extends ConsumerStatefulWidget {
  const _FCMTestSection();

  @override
  ConsumerState<_FCMTestSection> createState() => _FCMTestSectionState();
}

class _FCMTestSectionState extends ConsumerState<_FCMTestSection> {
  bool _isLoading = false;
  String? _fcmToken;
  Map<String, dynamic>? _backendStatus;

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
  }

  Future<void> _loadFCMToken() async {
    final fcmService = ref.read(fcmServiceProvider);
    try {
      final token = await fcmService.getToken();
      if (mounted) {
        setState(() => _fcmToken = token);
      }
    } catch (e) {
      // Token might not be available yet
    }
  }

  Future<void> _sendTestNotificationFromBackend() async {
    setState(() => _isLoading = true);

    try {
      final fcmService = ref.read(fcmServiceProvider);
      await fcmService.sendTestNotificationFromBackend(
        title: '🔔 Test desde Backend',
        body: 'Esta notificación fue enviada desde Laravel via FCM!',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Notificación enviada desde el backend. Espera unos segundos...',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${userFriendlyMessage(e)}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendTestNotificationWithActions() async {
    setState(() => _isLoading = true);

    try {
      final fcmService = ref.read(fcmServiceProvider);
      await fcmService.sendTestNotificationWithActionsFromBackend(
        title: '🧪 Test con Botones',
        body: 'Esta notificación tiene botones de acción: Completar y Omitir',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Notificación con botones enviada. Toca los botones cuando llegue!',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${userFriendlyMessage(e)}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkBackendStatus() async {
    setState(() => _isLoading = true);

    try {
      final fcmService = ref.read(fcmServiceProvider);
      final status = await fcmService.getBackendStatus();

      if (mounted) {
        setState(() => _backendStatus = status);
        _showStatusDialog(status);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${userFriendlyMessage(e)}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showStatusDialog(Map<String, dynamic> status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estado FCM Backend'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusRow(
                'FCM Configurado',
                status['fcm_configured'] == true,
              ),
              _buildStatusRow('Token Registrado', status['has_token'] == true),
              _buildStatusRow(
                'Usuario Autenticado',
                status['authenticated'] == true,
              ),
              if (status['error'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Error: ${status['error']}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _copyTokenToClipboard() async {
    if (_fcmToken == null) return;

    // Note: In a real app, you'd use Clipboard.setData
    // For now, just show the token
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FCM Token'),
        content: SelectableText(
          _fcmToken!,
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _reregisterToken() async {
    setState(() => _isLoading = true);

    try {
      final fcmService = ref.read(fcmServiceProvider);
      final success = await fcmService.registerTokenWithBackend();

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '✅ Token re-registrado exitosamente con el backend',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '❌ No se pudo re-registrar el token. Verifica logs.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${userFriendlyMessage(e)}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Test push notification from backend
        ListTile(
          leading: Icon(
            Icons.cloud_upload_outlined,
            color: theme.colorScheme.primary,
          ),
          title: const Text('Test Notificación Push'),
          subtitle: const Text('Envía notificación desde Laravel via FCM'),
          trailing: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : ElevatedButton.icon(
                  onPressed: _sendTestNotificationFromBackend,
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Enviar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
        ),

        // Test notification with action buttons
        ListTile(
          leading: Icon(
            Icons.touch_app_outlined,
            color: theme.colorScheme.tertiary,
          ),
          title: const Text('Test con Botones de Acción'),
          subtitle: const Text('Notificación con botones Completar/Omitir'),
          trailing: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : ElevatedButton.icon(
                  onPressed: _sendTestNotificationWithActions,
                  icon: const Icon(Icons.smart_button, size: 18),
                  label: const Text('Probar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    foregroundColor: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
        ),

        // Check backend status
        ListTile(
          leading: Icon(
            Icons.cloud_done_outlined,
            color: theme.colorScheme.secondary,
          ),
          title: const Text('Verificar Estado Backend'),
          subtitle: const Text(
            'Comprueba si FCM está configurado correctamente',
          ),
          trailing: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : ElevatedButton.icon(
                  onPressed: _checkBackendStatus,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Verificar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
        ),

        // Show FCM token
        if (_fcmToken != null)
          ListTile(
            leading: Icon(
              Icons.vpn_key_outlined,
              color: theme.colorScheme.tertiary,
            ),
            title: const Text('Ver FCM Token'),
            subtitle: Text(
              '${_fcmToken!.substring(0, 20)}...',
              style: theme.textTheme.bodySmall,
            ),
            trailing: TextButton.icon(
              onPressed: _copyTokenToClipboard,
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text('Ver'),
            ),
          ),

        // Re-register token button
        ListTile(
          leading: Icon(Icons.sync_outlined, color: theme.colorScheme.error),
          title: const Text('Re-registrar Token'),
          subtitle: const Text(
            'Fuerza el re-registro del token FCM con el backend',
          ),
          trailing: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : ElevatedButton.icon(
                  onPressed: _reregisterToken,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Re-registrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onErrorContainer,
                  ),
                ),
        ),

        // Info text
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Las notificaciones push (FCM) requieren que el backend Laravel '
                    'tenga configurado Firebase Cloud Messaging. Asegúrate de que '
                    'el servidor tenga las credenciales de Firebase.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
