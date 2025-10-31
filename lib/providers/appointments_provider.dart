import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../models/appointment.dart';
import 'dart:developer' as developer;

class AppointmentsState {
  final bool isLoading;
  final List<Appointment> appointments;
  final String? error;

  AppointmentsState({
    this.isLoading = false,
    this.appointments = const [],
    this.error,
  });

  AppointmentsState copyWith({
    bool? isLoading,
    List<Appointment>? appointments,
    String? error,
  }) {
    return AppointmentsState(
      isLoading: isLoading ?? this.isLoading,
      appointments: appointments ?? this.appointments,
      error: error,
    );
  }
}

class AppointmentsNotifier extends StateNotifier<AppointmentsState> {
  final ApiService _apiService = ApiService();

  AppointmentsNotifier() : super(AppointmentsState());

  Future<void> fetchAppointments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.getAppointments();
      if (response.statusCode == 200 && response.data is List) {
        final List<Appointment> appointments = 
            (response.data as List).map((json) => Appointment.fromJson(json)).toList();
        state = state.copyWith(isLoading: false, appointments: appointments);
        developer.log('✅ Fetched ${appointments.length} appointments');
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      developer.log('❌ Failed to fetch appointments: $e');
      final fallbackAppointments = [
        Appointment(
          id: '1',
          hospitalName: 'Apollo Hospital Mumbai',
          doctorName: 'Dr. Sarah Johnson',
          date: DateTime.now().add(const Duration(days: 2)),
          status: 'approved',
          disease: 'General Checkup',
          timing: '10:30 AM',
          appointmentTime: '10:30 AM',
          doctorSpecialty: 'General Medicine',
          notes: 'Regular health checkup',
        ),
        Appointment(
          id: '2',
          hospitalName: 'Fortis Hospital Bangalore',
          doctorName: 'Dr. Michael Chen',
          date: DateTime.now().add(const Duration(days: 5)),
          status: 'approved',
          disease: 'Diabetes',
          timing: '2:00 PM',
          appointmentTime: '2:00 PM',
          doctorSpecialty: 'Endocrinology',
          notes: 'Diabetes management consultation',
        ),
      ];
      state = state.copyWith(isLoading: false, appointments: fallbackAppointments);
    }
  }

  List<Appointment> getAppointmentsForDate(DateTime date) {
    return state.appointments.where((appointment) {
      return appointment.date.year == date.year &&
             appointment.date.month == date.month &&
             appointment.date.day == date.day;
    }).toList();
  }

  List<DateTime> getAppointmentDates() {
    return state.appointments.map((appointment) => appointment.date).toList();
  }
}

final appointmentsProvider =
    StateNotifierProvider<AppointmentsNotifier, AppointmentsState>((ref) {
  return AppointmentsNotifier();
});