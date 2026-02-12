/// Dependency Injection container using Riverpod providers.
///
/// Centralizes the creation and wiring of all app dependencies.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:productivity/app/config/app_config.dart';
import 'package:productivity/app/config/env_config.dart';
import 'package:productivity/core/network/api_client.dart';
import 'package:productivity/core/network/api_interceptors.dart';

// ─── Auth imports ─────────────────────────────────────────
import 'package:productivity/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:productivity/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:productivity/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:productivity/features/auth/domain/repositories/auth_repository.dart';

// ─── Goals imports ────────────────────────────────────────
import 'package:productivity/features/goals/data/datasources/goal_remote_datasource.dart';
import 'package:productivity/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:productivity/features/goals/domain/repositories/goal_repository.dart';

// ─── Tasks imports ────────────────────────────────────────
import 'package:productivity/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:productivity/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:productivity/features/tasks/domain/repositories/task_repository.dart';

// ─── Calendar imports ─────────────────────────────────────
import 'package:productivity/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:productivity/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:productivity/features/calendar/domain/repositories/calendar_repository.dart';

// ═══════════════════════════════════════════════════════════
// CORE PROVIDERS
// ═══════════════════════════════════════════════════════════

/// SharedPreferences instance — must be initialized before app starts.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at startup');
});

/// Secure storage for sensitive data (tokens).
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

/// Singleton timezone interceptor — initialized at app startup.
final timezoneInterceptorProvider = Provider<TimezoneInterceptor>((ref) {
  return TimezoneInterceptor();
});

/// Dio HTTP client with interceptors.
final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final timezoneInterceptor = ref.watch(timezoneInterceptorProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: EnvConfig.apiConnectTimeout,
      receiveTimeout: EnvConfig.apiReceiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(secureStorage),
    timezoneInterceptor,
    LoggingInterceptor(),
  ]);

  return dio;
});

/// API client wrapper.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

// ═══════════════════════════════════════════════════════════
// AUTH PROVIDERS
// ═══════════════════════════════════════════════════════════

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(
    ref.watch(secureStorageProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
  );
});

// ═══════════════════════════════════════════════════════════
// GOALS PROVIDERS
// ═══════════════════════════════════════════════════════════

final goalRemoteDataSourceProvider = Provider<GoalRemoteDataSource>((ref) {
  return GoalRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl(ref.watch(goalRemoteDataSourceProvider));
});

// ═══════════════════════════════════════════════════════════
// TASKS PROVIDERS
// ═══════════════════════════════════════════════════════════

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(taskRemoteDataSourceProvider));
});

// ═══════════════════════════════════════════════════════════
// CALENDAR PROVIDERS
// ═══════════════════════════════════════════════════════════

final calendarRemoteDataSourceProvider = Provider<CalendarRemoteDataSource>((
  ref,
) {
  return CalendarRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepositoryImpl(ref.watch(calendarRemoteDataSourceProvider));
});
