import 'package:flutter/material.dart';
import '../services/toast_service.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? fallbackMessage;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallbackMessage,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFEF4444),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              widget.fallbackMessage ?? 'Something went wrong',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  hasError = false;
                  errorMessage = null;
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return widget.child;
  }

  void _handleError(dynamic error) {
    setState(() {
      hasError = true;
      errorMessage = error.toString();
    });
    ToastService.showError('Widget error: ${widget.fallbackMessage ?? 'Unknown'}');
  }
}

class SafeWidget extends StatelessWidget {
  final Widget child;
  final String? fallbackMessage;

  const SafeWidget({
    super.key,
    required this.child,
    this.fallbackMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      fallbackMessage: fallbackMessage,
      child: child,
    );
  }
}