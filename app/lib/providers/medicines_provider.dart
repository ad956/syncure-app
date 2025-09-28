import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import 'auth_provider.dart';
import 'dart:developer' as developer;

class Medicine {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;
  final String type;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
    required this.type,
    required this.isActive,
    this.startDate,
    this.endDate,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? json['medicineName'] ?? '',
      dosage: json['dosage'] ?? json['dose'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      instructions: json['instructions'] ?? json['notes'] ?? '',
      type: json['type'] ?? json['category'] ?? 'Tablet',
      isActive: json['isActive'] ?? json['active'] ?? true,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }
}

class MedicinesNotifier extends StateNotifier<List<Medicine>?> {
  final ApiService _apiService;

  MedicinesNotifier(this._apiService) : super(null);

  Future<void> fetchMedicines() async {
    try {
      developer.log('💊 Fetching medicines data');
      final response = await _apiService.getMedicines();
      if (response.statusCode == 200) {
        final data = response.data;
        List<Medicine> medicines = [];
        
        if (data is List) {
          medicines = data.map((item) => Medicine.fromJson(item)).toList();
        } else if (data is Map && data['medicines'] != null) {
          medicines = (data['medicines'] as List).map((item) => Medicine.fromJson(item)).toList();
        } else if (data is Map && data['data'] != null) {
          medicines = (data['data'] as List).map((item) => Medicine.fromJson(item)).toList();
        }
        
        state = medicines;
        developer.log('✅ Loaded ${medicines.length} medicines');
      }
    } catch (e) {
      developer.log('❌ Medicines fetch error: $e');
      // Set empty list on error
      state = [];
    }
  }
}

final medicinesProvider = StateNotifierProvider<MedicinesNotifier, List<Medicine>?>((ref) {
  return MedicinesNotifier(ref.watch(apiServiceProvider));
});