import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../models/appointment.dart';
import 'auth_provider.dart';

class AppointmentsNotifier extends StateNotifier<List<Appointment>> {
  final ApiService _apiService;

  AppointmentsNotifier(this._apiService) : super([]);

  Future<void> fetchAppointments() async {
    try {
      final response = await _apiService.getAppointments();
      final appointments = (response.data as List)
          .map((json) => Appointment.fromJson(json))
          .toList();
      state = appointments;
    } catch (e) {
      // Handle error
    }
  }
}

final appointmentsProvider = StateNotifierProvider<AppointmentsNotifier, List<Appointment>>((ref) {
  return AppointmentsNotifier(ref.watch(apiServiceProvider));
});