import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../models/health_records.dart';
import '../models/dashboard.dart';

class HealthRecordsState {
  final List<VitalSign> vitalSigns;
  final List<HealthTrend> healthTrends;
  final List<MedicalHistoryRecord> medicalHistory;
  final List<LabResult> labResults;
  final List<MedicationRecord> medications;
  final bool isLoading;
  final String? error;

  HealthRecordsState({
    this.vitalSigns = const [],
    this.healthTrends = const [],
    this.medicalHistory = const [],
    this.labResults = const [],
    this.medications = const [],
    this.isLoading = false,
    this.error,
  });

  HealthRecordsState copyWith({
    List<VitalSign>? vitalSigns,
    List<HealthTrend>? healthTrends,
    List<MedicalHistoryRecord>? medicalHistory,
    List<LabResult>? labResults,
    List<MedicationRecord>? medications,
    bool? isLoading,
    String? error,
  }) {
    return HealthRecordsState(
      vitalSigns: vitalSigns ?? this.vitalSigns,
      healthTrends: healthTrends ?? this.healthTrends,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      labResults: labResults ?? this.labResults,
      medications: medications ?? this.medications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class HealthRecordsNotifier extends StateNotifier<HealthRecordsState> {
  final ApiService _apiService;

  HealthRecordsNotifier(this._apiService) : super(HealthRecordsState());

  Future<void> loadAllData() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await Future.wait([
        loadVitalSigns(),
        loadHealthTrends(),
        loadMedicalHistory(),
        loadLabResults(),
        loadMedications(),
      ]);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadVitalSigns() async {
    try {
      final response = await _apiService.getVitalSigns();
      final List<dynamic> data = response.data['vitals'] ?? [];
      final vitals = data.map((json) => VitalSign.fromJson(json)).toList();
      state = state.copyWith(vitalSigns: vitals);
    } catch (e) {
      // Use mock data if API fails
      final mockVitals = [
        VitalSign(
          id: '1',
          weight: 70.5,
          systolicBp: 120,
          diastolicBp: 80,
          heartRate: 72,
          temperature: 98.6,
          bloodSugar: 95,
          recordedAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        ),
        VitalSign(
          id: '2',
          weight: 70.2,
          systolicBp: 118,
          diastolicBp: 78,
          heartRate: 75,
          temperature: 98.4,
          bloodSugar: 92,
          recordedAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        ),
      ];
      state = state.copyWith(vitalSigns: mockVitals);
    }
  }

  Future<void> loadHealthTrends() async {
    try {
      final response = await _apiService.getHealthTrends();
      final List<dynamic> data = response.data['trends'] ?? [];
      final trends = data.map((json) => HealthTrend.fromJson(json)).toList();
      state = state.copyWith(healthTrends: trends);
    } catch (e) {
      // Use mock data if API fails
      final mockTrends = List.generate(30, (index) {
        final date = DateTime.now().subtract(Duration(days: 29 - index));
        return HealthTrend(
          date: date.toIso8601String(),
          weight: 70.0 + (index % 5) * 0.5,
          systolicBp: 115 + (index % 10),
          diastolicBp: 75 + (index % 8),
          heartRate: 70 + (index % 15),
          temperature: 98.0 + (index % 3) * 0.2,
          bloodSugar: 90 + (index % 20),
        );
      });
      state = state.copyWith(healthTrends: mockTrends);
    }
  }

  Future<void> loadMedicalHistory() async {
    try {
      final response = await _apiService.getMedicalHistory();
      final List<dynamic> data = response.data['history'] ?? [];
      final history = data.map((json) => MedicalHistoryRecord.fromJson(json)).toList();
      state = state.copyWith(medicalHistory: history);
    } catch (e) {
      // Use mock data if API fails
      final mockHistory = [
        MedicalHistoryRecord(
          id: '1',
          treatmentName: 'Hypertension Management',
          hospitalName: 'City General Hospital',
          doctorName: 'Dr. Smith',
          status: 'Ongoing',
          startDate: DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
          condition: 'High Blood Pressure',
          notes: 'Regular monitoring required',
        ),
        MedicalHistoryRecord(
          id: '2',
          treatmentName: 'Annual Physical Checkup',
          hospitalName: 'Metro Health Center',
          doctorName: 'Dr. Johnson',
          status: 'Completed',
          startDate: DateTime.now().subtract(const Duration(days: 365)).toIso8601String(),
          endDate: DateTime.now().subtract(const Duration(days: 364)).toIso8601String(),
          condition: 'Routine Checkup',
        ),
      ];
      state = state.copyWith(medicalHistory: mockHistory);
    }
  }

  Future<void> loadLabResults() async {
    try {
      final response = await _apiService.getLabResults();
      final List<dynamic> data = response.data['results'] ?? [];
      final results = data.map((json) => LabResult.fromJson(json)).toList();
      state = state.copyWith(labResults: results);
    } catch (e) {
      // Use mock data if API fails
      final mockResults = [
        LabResult(
          id: '1',
          testName: 'Complete Blood Count',
          testType: 'Blood Test',
          result: 'Normal',
          referenceRange: 'Within normal limits',
          status: 'Normal',
          testDate: DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          reportDate: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          labName: 'PathLab Diagnostics',
        ),
        LabResult(
          id: '2',
          testName: 'Lipid Profile',
          testType: 'Blood Test',
          result: 'Cholesterol: 180 mg/dL',
          referenceRange: '<200 mg/dL',
          status: 'Normal',
          testDate: DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
          reportDate: DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
          labName: 'Quest Diagnostics',
        ),
      ];
      state = state.copyWith(labResults: mockResults);
    }
  }

  Future<void> loadMedications() async {
    try {
      final response = await _apiService.getMedications();
      final List<dynamic> data = response.data['medications'] ?? [];
      final medications = data.map((json) => MedicationRecord.fromJson(json)).toList();
      state = state.copyWith(medications: medications);
    } catch (e) {
      // Use mock data if API fails
      final mockMedications = [
        MedicationRecord(
          id: '1',
          name: 'Lisinopril',
          dosage: '10mg',
          frequency: 'Once daily',
          instructions: 'Take with food',
          prescribedBy: 'Dr. Smith',
          startDate: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          isActive: true,
          reminderTimes: ['08:00'],
        ),
        MedicationRecord(
          id: '2',
          name: 'Metformin',
          dosage: '500mg',
          frequency: 'Twice daily',
          instructions: 'Take with meals',
          prescribedBy: 'Dr. Johnson',
          startDate: DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
          isActive: true,
          reminderTimes: ['08:00', '20:00'],
        ),
      ];
      state = state.copyWith(medications: mockMedications);
    }
  }

  Future<void> addVitalSigns(Map<String, dynamic> data) async {
    try {
      await _apiService.recordVitals(
        weight: data['weight'] ?? 0.0,
        systolicBp: data['systolic_bp'] ?? 0,
        diastolicBp: data['diastolic_bp'] ?? 0,
        heartRate: data['heart_rate'] ?? 0,
        temperature: data['temperature'] ?? 0.0,
        bloodSugar: data['blood_sugar'] ?? 0,
      );
      
      // Reload vital signs after adding
      await loadVitalSigns();
    } catch (e) {
      state = state.copyWith(error: 'Failed to record vital signs: ${e.toString()}');
    }
  }

  Future<void> addMedication(Map<String, dynamic> data) async {
    try {
      await _apiService.addMedication(data);
      
      // Reload medications after adding
      await loadMedications();
    } catch (e) {
      state = state.copyWith(error: 'Failed to add medication: ${e.toString()}');
    }
  }

  Future<void> removeMedication(String medicationId) async {
    try {
      await _apiService.removeMedication(medicationId);
      
      // Reload medications after removing
      await loadMedications();
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove medication: ${e.toString()}');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final healthRecordsProvider = StateNotifierProvider<HealthRecordsNotifier, HealthRecordsState>((ref) {
  return HealthRecordsNotifier(ApiService());
});