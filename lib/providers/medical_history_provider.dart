import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import 'auth_provider.dart';

class MedicalRecord {
  final String id;
  final String hospitalName;
  final String doctorName;
  final DateTime startDate;
  final DateTime? endDate;
  final String disease;
  final String treatmentStatus;

  MedicalRecord({
    required this.id,
    required this.hospitalName,
    required this.doctorName,
    required this.startDate,
    this.endDate,
    required this.disease,
    required this.treatmentStatus,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['_id'] ?? json['id'] ?? '',
      hospitalName: json['hospital']?['name'] ?? json['hospitalName'] ?? '',
      doctorName: json['doctor']?['name'] ?? json['doctorName'] ?? '',
      startDate: DateTime.parse(json['start_date'] ?? json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : 
               (json['endDate'] != null ? DateTime.parse(json['endDate']) : null),
      disease: json['disease'] ?? '',
      treatmentStatus: json['TreatmentStatus'] ?? json['treatmentStatus'] ?? '',
    );
  }
}

class MedicalHistoryNotifier extends StateNotifier<List<MedicalRecord>> {
  final ApiService _apiService;

  MedicalHistoryNotifier(this._apiService) : super([]);

  Future<void> fetchMedicalHistory() async {
    try {
      final response = await _apiService.getMedicalHistory();
      if (response.statusCode == 200) {
        final data = response.data;
        List<MedicalRecord> records = [];
        
        if (data['success'] == true && data['data'] != null) {
          final historyData = data['data'] as List;
          records = historyData.map((json) => MedicalRecord.fromJson(json)).toList();
        }
        
        state = records;
      }
    } catch (e) {
      state = [];
    }
  }
}

final medicalHistoryProvider = StateNotifierProvider<MedicalHistoryNotifier, List<MedicalRecord>>((ref) {
  return MedicalHistoryNotifier(ref.watch(apiServiceProvider));
});