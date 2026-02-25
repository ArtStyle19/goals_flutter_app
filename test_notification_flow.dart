#!/usr/bin/env dart
// Script de prueba para diagnosticar el flujo de notificaciones FCM
// Ejecutar con: dart test_notification_flow.dart

import 'dart:io';

void main() {
  print('╔════════════════════════════════════════════════════════════╗');
  print('║  SCRIPT DE DIAGNÓSTICO - NOTIFICACIONES FCM                ║');
  print('╚════════════════════════════════════════════════════════════╝');
  print('');

  // Verificar pasos del flujo
  final steps = [
    _DiagnosticStep(
      '1. Firebase inicializado',
      'Verificar que Firebase.initializeApp() se llamó sin errores',
      'Revisar logs: [FCM] Firebase initialized',
    ),
    _DiagnosticStep(
      '2. Token FCM obtenido',
      'Verificar que se obtuvo token y se registró en backend',
      'Revisar logs: [FCM] Token obtained: ...',
    ),
    _DiagnosticStep(
      '3. Permisos de notificación',
      'Verificar que el usuario aceptó permisos de notificación',
      'Revisar logs: [FCM] Permission status: authorized',
    ),
    _DiagnosticStep(
      '4. Canales de notificación creados',
      'Verificar que los canales Android se crearon correctamente',
      'Revisar logs: [FCM] Notification channels created',
    ),
    _DiagnosticStep(
      '5. Backend envía notificación',
      'Verificar que Laravel envía el mensaje FCM correctamente',
      'Revisar logs Laravel: FCM data-only message sent successfully',
    ),
    _DiagnosticStep(
      '6. App recibe mensaje en background',
      'Verificar que firebaseMessagingBackgroundHandler se ejecuta',
      'Revisar logs: [FCM] BACKGROUND MESSAGE RECEIVED',
    ),
    _DiagnosticStep(
      '7. Notificación local mostrada',
      'Verificar que se muestra notificación local con botones',
      'Revisar logs: [FCM] Local notification with actions shown',
    ),
    _DiagnosticStep(
      '8. Usuario presiona botón',
      'Verificar que se detecta la acción del botón',
      'Revisar logs: [FCM] Background notification response: action=...',
    ),
    _DiagnosticStep(
      '9. Acción almacenada en SharedPreferences',
      'Verificar que la acción se guarda para procesar al abrir app',
      'Revisar logs: [FCM] Stored pending action: ...',
    ),
    _DiagnosticStep(
      '10. App procesa acción pendiente',
      'Verificar que processPendingActions() ejecuta la acción',
      'Revisar logs: [FCM] Processing pending action: ...',
    ),
    _DiagnosticStep(
      '11. Tarea completada en backend',
      'Verificar que se llamó al endpoint de completar tarea',
      'Revisar logs: [FCM] Task X COMPLETED successfully',
    ),
  ];

  for (final step in steps) {
    step.printStep();
  }

  print('');
  print('╔════════════════════════════════════════════════════════════╗');
  print('║  COMANDOS ÚTILES PARA DEBUG                                ║');
  print('╚════════════════════════════════════════════════════════════╝');
  print('');
  print('1. Ver logs de Flutter en tiempo real:');
  print('   flutter logs | grep -i fcm');
  print('');
  print('2. Ver logs de Laravel:');
  print('   tail -f storage/logs/laravel.log | grep -i fcm');
  print('');
  print('3. Enviar notificación de prueba desde backend:');
  print('   curl -X POST http://TU_API_URL/test-notification-with-actions \\');
  print('     -H "Authorization: Bearer TU_TOKEN" \\');
  print('     -H "Content-Type: application/json" \\');
  print('     -d \'{"title":"Test","body":"Presiona Completar"}\'');
  print('');
  print('4. Verificar token FCM en dispositivo:');
  print('   - Ir a Settings > FCM Test > Ver FCM Token');
  print('');
  print('5. Re-registrar token con backend:');
  print('   - Ir a Settings > FCM Test > Re-registrar Token');
  print('');
  print('╔════════════════════════════════════════════════════════════╗');
  print('║  PROBLEMAS COMUNES Y SOLUCIONES                            ║');
  print('╚════════════════════════════════════════════════════════════╝');
  print('');
  print('❌ PROBLEMA: "No FCM token registered"');
  print('   SOLUCIÓN: Reinstalar app y aceptar permisos de notificación');
  print('');
  print('❌ PROBLEMA: "Invalid token" o "registration-token-not-registered"');
  print(
    '   SOLUCIÓN: Verificar que google-services.json coincida con proyecto Firebase',
  );
  print('');
  print('❌ PROBLEMA: Notificación llega pero botones no hacen nada');
  print(
    '   SOLUCIÓN: Verificar que backend envía mensaje DATA-ONLY (sin notification payload)',
  );
  print('');
  print('❌ PROBLEMA: Acción no se ejecuta al presionar botón');
  print(
    '   SOLUCIÓN: Verificar que processPendingActions() se llama en main.dart',
  );
  print('');
  print('❌ PROBLEMA: Tarea no se completa en backend');
  print(
    '   SOLUCIÓN: Verificar que taskRepositoryProvider está configurado correctamente',
  );
  print('');
}

class _DiagnosticStep {
  final String title;
  final String description;
  final String check;

  _DiagnosticStep(this.title, this.description, this.check);

  void printStep() {
    print('┌────────────────────────────────────────────────────────────┐');
    print('│ $title');
    print('├────────────────────────────────────────────────────────────┤');
    print('│ Descripción: $description');
    print('│ Verificación: $check');
    print('└────────────────────────────────────────────────────────────┘');
    print('');
  }
}
