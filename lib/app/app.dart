import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/app/router/app_router.dart';
import 'package:productivity/app/theme/app_theme.dart';
import 'package:productivity/app/theme/theme_provider.dart';

/// Root application widget.
///
/// Uses [MaterialApp.router] with GoRouter for declarative navigation.
class ProductivityApp extends ConsumerWidget {
  const ProductivityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Productivity Planner',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
