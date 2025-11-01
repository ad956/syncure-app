import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';

class AuthGuard {
  static String? redirect(GoRouterState state, WidgetRef ref) {
    final authState = ref.read(authProvider);
    final isLoggedIn = authState.user != null;
    final isLoginRoute = state.matchedLocation == AppRoutes.login || 
                        state.matchedLocation == AppRoutes.signup ||
                        state.matchedLocation == AppRoutes.splash;

    if (!isLoggedIn && !isLoginRoute) {
      return AppRoutes.login;
    }
    
    if (isLoggedIn && isLoginRoute && state.matchedLocation != AppRoutes.splash) {
      return AppRoutes.dashboard;
    }
    
    return null;
  }
}