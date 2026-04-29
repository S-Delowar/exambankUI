import 'package:flutter/material.dart';

import '../models/api_result.dart';

class ErrorView extends StatelessWidget {
  final ApiError? error;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, this.error, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isOffline = error?.isOffline ?? false;
    final title = isOffline ? "You're offline" : 'Something went wrong';
    final body = message ??
        error?.message ??
        (isOffline
            ? 'Check your connection and try again.'
            : 'Please try again in a moment.');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.error_outline,
              size: 48,
              color: cs.error,
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
