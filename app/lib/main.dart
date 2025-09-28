import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'themes/app_theme.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/appointments/appointments_screen.dart';
import 'screens/payments/payments_screen.dart';
import 'screens/medical_history/medical_history_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/qr/qr_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/lab_results/lab_results_screen.dart';
import 'screens/appointment_booking/appointment_booking_screen.dart';
import 'screens/doctors/doctors_screen.dart';
import 'services/razorpay_service.dart';
import 'services/novu_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen()),
      GoRoute(
          path: '/appointments',
          builder: (context, state) => const AppointmentsScreen()),
      GoRoute(
          path: '/payments',
          builder: (context, state) => const PaymentsScreen()),
      GoRoute(
          path: '/medical-history',
          builder: (context, state) => const MedicalHistoryScreen()),
      GoRoute(
          path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/qr', builder: (context, state) => const QRScreen()),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
      GoRoute(path: '/lab-results', builder: (context, state) => const LabResultsScreen()),
      GoRoute(path: '/book-appointment', builder: (context, state) => const AppointmentBookingScreen()),
      GoRoute(path: '/doctors', builder: (context, state) => const DoctorsScreen()),
    ],
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Initialize services
  RazorpayService.initialize();
  await NovuService.initializeNovu();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    RazorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Syncure',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
