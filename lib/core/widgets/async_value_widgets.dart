/// Reusable widgets for AsyncValue states.
///
/// Provides consistent loading, error, and empty states across the app.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/core/error/error_handler.dart';
import 'package:productivity/core/widgets/app_error_widget.dart';
import 'package:productivity/core/widgets/empty_state_widget.dart';
import 'package:productivity/core/widgets/loading_widget.dart';

/// Extension to provide convenient UI methods on AsyncValue.
extension AsyncValueUI<T> on AsyncValue<T> {
  /// Builds a widget based on AsyncValue state with consistent styling.
  Widget build({
    required Widget Function(T data) data,
    VoidCallback? onRetry,
    String? emptyMessage,
    Widget? loadingWidget,
    Widget? errorWidget,
    bool skipLoadingOnRefresh = true,
  }) {
    return when(
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      loading: () => loadingWidget ?? const LoadingWidget(),
      error: (error, stackTrace) =>
          errorWidget ??
          AppErrorWidget(message: userFriendlyMessage(error), onRetry: onRetry),
      data: (value) {
        // Handle empty lists
        if (value is List && value.isEmpty && emptyMessage != null) {
          return EmptyStateWidget(
            title: emptyMessage,
            subtitle: 'Intenta crear uno nuevo.',
            icon: Icons.inbox_outlined,
          );
        }
        return data(value);
      },
    );
  }

  /// Shows a snackbar when the AsyncValue transitions to error state.
  void showErrorSnackbar(BuildContext context, {VoidCallback? onRetry}) {
    if (hasError && !isLoading) {
      final message = userFriendlyMessage(error!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: onRetry != null
              ? SnackBarAction(
                  label: 'Reintentar',
                  onPressed: onRetry,
                  textColor: Theme.of(context).colorScheme.onError,
                )
              : null,
        ),
      );
    }
  }
}

/// A widget that handles all AsyncValue states declaratively.
class AsyncValueHandler<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final String? emptyMessage;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final bool skipLoadingOnRefresh;

  const AsyncValueHandler({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.emptyMessage,
    this.loadingWidget,
    this.errorWidget,
    this.skipLoadingOnRefresh = true,
  });

  @override
  Widget build(BuildContext context) {
    return value.build(
      data: data,
      onRetry: onRetry,
      emptyMessage: emptyMessage,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
    );
  }
}

/// A widget that provides pull-to-refresh for AsyncValue data.
class AsyncValueRefreshHandler<T> extends ConsumerWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Future<void> Function() onRefresh;
  final VoidCallback? onRetry;
  final String? emptyMessage;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const AsyncValueRefreshHandler({
    super.key,
    required this.value,
    required this.data,
    required this.onRefresh,
    this.onRetry,
    this.emptyMessage,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: value.build(
        data: data,
        onRetry: onRetry,
        emptyMessage: emptyMessage,
        loadingWidget: loadingWidget,
        errorWidget: errorWidget,
        skipLoadingOnRefresh: true,
      ),
    );
  }
}

/// A widget that listens to an AsyncValue provider and shows a snackbar on error.
class AsyncValueErrorListener<T> extends ConsumerWidget {
  final ProviderListenable<AsyncValue<T>> provider;
  final Widget child;
  final VoidCallback? onRetry;

  const AsyncValueErrorListener({
    super.key,
    required this.provider,
    required this.child,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<T>>(provider, (previous, next) {
      next.showErrorSnackbar(context, onRetry: onRetry);
    });

    return child;
  }
}

/// A widget that shows a loading overlay when AsyncValue is loading.
class AsyncValueLoadingOverlay<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget child;
  final String? message;

  const AsyncValueLoadingOverlay({
    super.key,
    required this.value,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (value.isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: 8),
                        Text(message!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
