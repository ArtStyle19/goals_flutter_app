/// Dependency Injection container using Riverpod providers.
///
/// Centralizes the creation and wiring of all app dependencies.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:productivity/app/config/app_config.dart';
import 'package:productivity/core/constants/api_constants.dart';
import 'package:productivity/core/database/app_database.dart';
import 'package:productivity/core/network/api_client.dart';
import 'package:productivity/core/network/api_interceptors.dart';

// ─── Auth imports ─────────────────────────────────────────
import 'package:productivity/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:productivity/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:productivity/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:productivity/features/auth/domain/repositories/auth_repository.dart';

// ─── Goals imports ────────────────────────────────────────
import 'package:productivity/features/goals/data/datasources/goal_local_datasource.dart';
import 'package:productivity/features/goals/data/datasources/goal_remote_datasource.dart';
import 'package:productivity/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:productivity/features/goals/domain/repositories/goal_repository.dart';

// ─── Tasks imports ────────────────────────────────────────
import 'package:productivity/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:productivity/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:productivity/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:productivity/features/tasks/domain/repositories/task_repository.dart';

// ─── Calendar imports ─────────────────────────────────────
import 'package:productivity/features/calendar/data/datasources/calendar_local_datasource.dart';
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
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
});

/// Database provider - singleton instance.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Timezone interceptor for API requests.
final timezoneInterceptorProvider = Provider<TimezoneInterceptor>((ref) {
  throw UnimplementedError('TimezoneInterceptor must be overridden at startup');
});

/// Dio HTTP client with interceptors.
final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final timezoneInterceptor = ref.watch(timezoneInterceptorProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
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

final goalLocalDataSourceProvider = Provider<GoalLocalDataSource>((ref) {
  return GoalLocalDataSourceImpl(
    ref.watch(appDatabaseProvider),
    taskLocalDataSource: ref.watch(taskLocalDataSourceProvider),
  );
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl(
    remoteDataSource: ref.watch(goalRemoteDataSourceProvider),
    localDataSource: ref.watch(goalLocalDataSourceProvider),
    taskLocalDataSource: ref.watch(taskLocalDataSourceProvider),
  );
});

// ═══════════════════════════════════════════════════════════
// TASKS PROVIDERS
// ═══════════════════════════════════════════════════════════

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  return TaskLocalDataSourceImpl(ref.watch(appDatabaseProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    remoteDataSource: ref.watch(taskRemoteDataSourceProvider),
    localDataSource: ref.watch(taskLocalDataSourceProvider),
    calendarLocalDataSource: ref.watch(calendarLocalDataSourceProvider),
  );
});

// ═══════════════════════════════════════════════════════════
// CALENDAR PROVIDERS
// ═══════════════════════════════════════════════════════════

final calendarRemoteDataSourceProvider = Provider<CalendarRemoteDataSource>((
  ref,
) {
  return CalendarRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final calendarLocalDataSourceProvider = Provider<CalendarLocalDataSource>((
  ref,
) {
  return CalendarLocalDataSourceImpl(ref.watch(appDatabaseProvider));
});

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepositoryImpl(
    remoteDataSource: ref.watch(calendarRemoteDataSourceProvider),
    localDataSource: ref.watch(calendarLocalDataSourceProvider),
  );
});
