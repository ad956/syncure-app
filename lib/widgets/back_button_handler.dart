import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/toast_service.dart';
import '../routes/app_routes.dart';

class BackButtonHandler extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const BackButtonHandler({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<BackButtonHandler> createState() => _BackButtonHandlerState();
}

class _BackButtonHandlerState extends State<BackButtonHandler> {
  DateTime? _lastBackPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        if (widget.currentRoute == AppRoutes.dashboard) {
          _handleDashboardBack();
        } else {
          _handleRegularBack();
        }
      },
      child: widget.child,
    );
  }

  void _handleDashboardBack() {
    final now = DateTime.now();
    if (_lastBackPressed == null || 
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ToastService.showInfo('Press back again to exit');
    } else {
      SystemNavigator.pop();
    }
  }

  void _handleRegularBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.dashboard);
    }
  }
}