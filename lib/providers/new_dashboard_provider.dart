import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../models/dashboard.dart';
import 'auth_provider.dart';
import 'dart:developer' as developer;

class NewDashboardNotifier extends StateNotifier<DashboardResponse?> {
  final ApiService _apiService;

  NewDashboardNotifier(this._apiService) : super(null);

  Future<void> fetchDashboard() async {
    try {
      developer.log('📊 Fetching dashboard data');
      final response = await _apiService.getDashboard();
      if (response.statusCode == 200) {
        developer.log('📋 Dashboard API Response: ${response.data}');
        _apiService.logApiResponse('/patient/dashboard', response.data);
        final dashboardData = DashboardResponse.fromJson(response.data);
        state = dashboardData;
        developer.log('✅ Dashboard data loaded successfully');
      }
    } catch (e) {
      developer.log('❌ Dashboard fetch error: $e');
      // Set mock data on error
      state = _getMockDashboard();
    }
  }

  Future<void> recordVitals({
    required double weight,
    required int systolicBp,
    required int diastolicBp,
    required int heartRate,
    required double temperature,
    required int bloodSugar,
  }) async {
    try {
      await _apiService.recordVitals(
        weight: weight,
        systolicBp: systolicBp,
        diastolicBp: diastolicBp,
        heartRate: heartRate,
        temperature: temperature,
        bloodSugar: bloodSugar,
      );
      // Refresh dashboard after recording vitals
      await fetchDashboard();
    } catch (e) {
      developer.log('❌ Error recording vitals: $e');
    }
  }

  Future<void> takeMedication(String medicationId) async {
    try {
      await _apiService.takeMedication(medicationId);
      // Update local state
      if (state != null) {
        final updatedMedications = state!.medications.map((med) {
          if (med.id == medicationId) {
            return Medication(
              id: med.id,
              name: med.name,
              dosage: med.dosage,
              frequency: med.frequency,
              instructions: med.instructions,
              nextDose: med.nextDose,
              wasTaken: true,
            );
          }
          return med;
        }).toList();
        
        state = DashboardResponse(
          patient: state!.patient,
          healthMetrics: state!.healthMetrics,
          nextAppointment: state!.nextAppointment,
          todaysVitals: state!.todaysVitals,
          recentVitals: state!.recentVitals,
          medications: updatedMedications,
          progress: state!.progress,
        );
      }
    } catch (e) {
      developer.log('❌ Error taking medication: $e');
    }
  }

  DashboardResponse _getMockDashboard() {
    return DashboardResponse(
      patient: Patient(
        id: 'patient_123',
        name: 'John Doe',
        firstname: 'John',
        email: 'john@example.com',
        contact: '+1 9876543210',
        physicalDetails: PhysicalDetails(height: 175, weight: 70),
        updatedAt: DateTime.now().toIso8601String(),
      ),
      healthMetrics: HealthMetrics(
        healthScore: 85,
        activeMedications: 3,
        bmiStatus: 'Normal',
        bmi: '22.9',
      ),
      nextAppointment: NextAppointment(
        date: DateTime.now().add(Duration(days: 7)).toIso8601String(),
        doctor: 'Dr. Smith',
        hospital: 'General Hospital',
        specialty: 'Cardiology',
      ),
      todaysVitals: [
        VitalSign(
          id: 'vital_1',
          weight: 70,
          systolicBp: 120,
          diastolicBp: 80,
          heartRate: 72,
          temperature: 36.5,
          bloodSugar: 95,
          recordedAt: DateTime.now().toIso8601String(),
        ),
      ],
      recentVitals: [],
      medications: [
        Medication(
          id: 'med_1',
          name: 'Aspirin',
          dosage: '100mg',
          frequency: 'Once daily',
          instructions: 'Take with food',
          nextDose: '8:00 AM',
          wasTaken: false,
        ),
      ],
      progress: Progress(
        generalHealth: 85,
        waterBalance: 78,
        currentTreatment: 92,
        pendingAppointments: 1,
      ),
    );
  }
}

final newDashboardProvider = StateNotifierProvider<NewDashboardNotifier, DashboardResponse?>((ref) {
  return NewDashboardNotifier(ref.watch(apiServiceProvider));
});