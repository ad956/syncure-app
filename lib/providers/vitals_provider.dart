import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../models/dashboard.dart';
import 'auth_provider.dart';
import 'dart:developer' as developer;

class VitalsNotifier extends StateNotifier<AsyncValue<List<VitalSign>>> {
  final ApiService _apiService;

  VitalsNotifier(this._apiService) : super(const AsyncValue.loading());

  Future<void> fetchVitals() async {
    state = const AsyncValue.loading();
    try {
      developer.log('💓 Fetching vital signs data');
      final response = await _apiService.getVitalSigns();
      
      if (response.statusCode == 200) {
        developer.log('📋 Vitals API Response: ${response.data}');
        
        if (response.data['success'] == true) {
          final vitalsData = response.data['data']['vitals'] as List;
          final vitals = vitalsData.map((v) => VitalSign.fromJson(v)).toList();
          
          state = AsyncValue.data(vitals);
          developer.log('✅ Loaded ${vitals.length} vital signs from API');
        } else {
          state = const AsyncValue.data([]);
        }
      } else {
        state = AsyncValue.error('API returned ${response.statusCode}', StackTrace.current);
      }
    } catch (e, stack) {
      developer.log('❌ Vitals fetch error: $e');
      state = AsyncValue.error(e, stack);
    }
  }
}

final vitalsProvider = StateNotifierProvider<VitalsNotifier, AsyncValue<List<VitalSign>>>((ref) {
  return VitalsNotifier(ref.watch(apiServiceProvider));
});