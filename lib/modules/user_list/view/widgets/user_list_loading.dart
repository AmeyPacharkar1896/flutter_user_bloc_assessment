import 'package:flutter/material.dart';

class UserListLoadingIndicator extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const UserListLoadingIndicator({this.margin, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2.0),
    );
  }
}

class UserListErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const UserListErrorView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error: $message',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: theme.colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
