import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import 'auth_provider.dart';
import 'dart:developer' as developer;

class DashboardData {
  final int upcomingAppointments;
  final int pendingPayments;
  final int healthScore;
  final int waterBalance;
  final int currentTreatment;
  final double totalSpent;
  final String? lastVisit;

  DashboardData({
    required this.upcomingAppointments,
    required this.pendingPayments,
    required this.healthScore,
    required this.waterBalance,
    required this.currentTreatment,
    required this.totalSpent,
    this.lastVisit,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      upcomingAppointments: json['upcomingAppointments'] ?? 0,
      pendingPayments: json['pendingPayments'] ?? 0,
      healthScore: json['healthScore'] ?? 85,
      waterBalance: json['waterBalance'] ?? 78,
      currentTreatment: json['currentTreatment'] ?? 10,
      totalSpent: (json['totalSpent'] ?? 0.0).toDouble(),
      lastVisit: json['lastVisit'],
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardData?> {
  final ApiService _apiService;

  DashboardNotifier(this._apiService) : super(null);

  Future<void> fetchDashboard() async {
    try {
      developer.log('📊 Fetching dashboard data');
      final response = await _apiService.getDashboard();
      if (response.statusCode == 200) {
        developer.log('📋 Dashboard API Response: ${response.data}');
        _apiService.logApiResponse('/patient/dashboard', response.data);
        final dashboardData = DashboardData.fromJson(response.data);
        state = dashboardData;
        developer.log('✅ Dashboard data loaded successfully');
      }
    } catch (e) {
      developer.log('❌ Dashboard fetch error: $e');
      // Set default values on error
      state = DashboardData(
        upcomingAppointments: 0,
        pendingPayments: 0,
        healthScore: 85,
        waterBalance: 78,
        currentTreatment: 10,
        totalSpent: 0.0,
      );
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardData?>((ref) {
  return DashboardNotifier(ref.watch(apiServiceProvider));
});