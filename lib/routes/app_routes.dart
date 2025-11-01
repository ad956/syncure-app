import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/appointments/appointments_screen.dart';
import '../screens/appointment_booking/appointment_booking_screen.dart';
import '../screens/payments/payments_screen.dart';
import '../screens/medical_history/medical_history_screen.dart';
import '../screens/profile/profile_screen.dart';

import '../screens/chat/chat_screen.dart';
import '../screens/lab_results/lab_results_screen.dart';
import '../screens/health_records/health_records_screen.dart';
import '../screens/doctors/doctors_screen.dart';
import '../screens/error/page_not_found_screen.dart';
import '../providers/auth_provider.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String appointments = '/appointments';
  static const String bookAppointment = '/book-appointment';
  static const String payments = '/payments';
  static const String medicalHistory = '/medical-history';
  static const String profile = '/profile';

  static const String chat = '/chat';
  static const String labResults = '/lab-results';
  static const String healthRecords = '/health-records';
  static const String doctors = '/doctors';
  static const String notFound = '/404';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    errorBuilder: (context, state) => const PageNotFoundScreen(),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.appointments,
        builder: (context, state) => const AppointmentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookAppointment,
        builder: (context, state) => const AppointmentBookingScreen(),
      ),
      GoRoute(
        path: AppRoutes.payments,
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.medicalHistory,
        builder: (context, state) => const MedicalHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.labResults,
        builder: (context, state) => const LabResultsScreen(),
      ),
      GoRoute(
        path: AppRoutes.healthRecords,
        builder: (context, state) => const HealthRecordsScreen(),
      ),
      GoRoute(
        path: AppRoutes.doctors,
        builder: (context, state) => const DoctorsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notFound,
        builder: (context, state) => const PageNotFoundScreen(),
      ),
    ],
  );
});



