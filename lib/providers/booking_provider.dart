import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';

import 'dart:developer' as developer;

class BookingState {
  final bool isLoading;
  final bool isLoadingStates;
  final bool isLoadingCities;
  final bool isLoadingHospitals;
  final bool isLoadingDiseases;
  final List<String> states;
  final List<String> cities;
  final List<Map<String, dynamic>> hospitals;
  final List<String> diseases;
  final String? error;

  BookingState({
    this.isLoading = false,
    this.isLoadingStates = false,
    this.isLoadingCities = false,
    this.isLoadingHospitals = false,
    this.isLoadingDiseases = false,
    this.states = const [],
    this.cities = const [],
    this.hospitals = const [],
    this.diseases = const [],
    this.error,
  });

  BookingState copyWith({
    bool? isLoading,
    bool? isLoadingStates,
    bool? isLoadingCities,
    bool? isLoadingHospitals,
    bool? isLoadingDiseases,
    List<String>? states,
    List<String>? cities,
    List<Map<String, dynamic>>? hospitals,
    List<String>? diseases,
    String? error,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingStates: isLoadingStates ?? this.isLoadingStates,
      isLoadingCities: isLoadingCities ?? this.isLoadingCities,
      isLoadingHospitals: isLoadingHospitals ?? this.isLoadingHospitals,
      isLoadingDiseases: isLoadingDiseases ?? this.isLoadingDiseases,
      states: states ?? this.states,
      cities: cities ?? this.cities,
      hospitals: hospitals ?? this.hospitals,
      diseases: diseases ?? this.diseases,
      error: error,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final ApiService _apiService = ApiService();

  BookingNotifier() : super(BookingState());

  Future<void> fetchStates() async {
    state = state.copyWith(isLoadingStates: true, error: null);
    try {
      final response = await _apiService.getStates();
      if (response.statusCode == 200 && response.data is List) {
        final List<String> statesData = List<String>.from(response.data);
        state = state.copyWith(isLoadingStates: false, states: statesData);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      developer.log('❌ Failed to fetch states: $e');
      final fallbackStates = [
        'Maharashtra', 'Gujarat', 'Karnataka', 'Tamil Nadu', 
        'Delhi', 'Punjab', 'Rajasthan', 'Uttar Pradesh'
      ];
      state = state.copyWith(isLoadingStates: false, states: fallbackStates);
    }
  }

  Future<void> fetchCities(String selectedState) async {
    state = state.copyWith(isLoadingCities: true, error: null);
    try {
      final response = await _apiService.getCities(selectedState);
      if (response.statusCode == 200 && response.data is List) {
        final List<String> citiesData = List<String>.from(response.data);
        state = state.copyWith(isLoadingCities: false, cities: citiesData);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      developer.log('❌ Failed to fetch cities for $selectedState: $e');
      List<String> fallbackCities;
      switch (selectedState.toLowerCase()) {
        case 'maharashtra':
          fallbackCities = ['Mumbai', 'Pune', 'Nagpur'];
          break;
        case 'gujarat':
          fallbackCities = ['Ahmedabad', 'Surat', 'Vadodara'];
          break;
        default:
          fallbackCities = ['City 1', 'City 2'];
      }
      state = state.copyWith(isLoadingCities: false, cities: fallbackCities);
    }
  }

  Future<void> fetchHospitals(String selectedState, String selectedCity) async {
    state = state.copyWith(isLoadingHospitals: true, error: null);
    try {
      final response = await _apiService.getHospitals(selectedState, selectedCity);
      if (response.statusCode == 200 && response.data is List) {
        final List<Map<String, dynamic>> hospitalsData = 
            List<Map<String, dynamic>>.from(response.data);
        state = state.copyWith(isLoadingHospitals: false, hospitals: hospitalsData);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      developer.log('❌ Failed to fetch hospitals: $e');
      final fallbackHospitals = [
        {'hospital_id': '1', 'hospital_name': 'Apollo Hospital'},
        {'hospital_id': '2', 'hospital_name': 'Fortis Hospital'},
        {'hospital_id': '3', 'hospital_name': 'Max Healthcare'},
      ];
      state = state.copyWith(isLoadingHospitals: false, hospitals: fallbackHospitals);
    }
  }

  Future<void> fetchDiseases() async {
    state = state.copyWith(isLoadingDiseases: true, error: null);
    try {
      final response = await _apiService.getDiseases();
      if (response.statusCode == 200 && response.data is List) {
        final List<String> diseasesData = List<String>.from(response.data);
        state = state.copyWith(isLoadingDiseases: false, diseases: diseasesData);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      developer.log('❌ Failed to fetch diseases: $e');
      final fallbackDiseases = [
        'General Checkup', 'Fever', 'Headache', 'Chest Pain',
        'Diabetes', 'Hypertension', 'Heart Disease'
      ];
      state = state.copyWith(isLoadingDiseases: false, diseases: fallbackDiseases);
    }
  }

  Future<bool> checkPendingAppointment(String hospitalId) async {
    try {
      final response = await _apiService.checkPendingAppointment(hospitalId);
      if (response.statusCode == 200) {
        return response.data['hasPendingAppointment'] ?? false;
      }
    } catch (e) {
      developer.log('❌ Failed to check pending appointments: $e');
    }
    return false;
  }

  Future<String?> createPaymentOrder(int amount) async {
    try {
      final response = await _apiService.createPaymentOrder(amount);
      if (response.statusCode == 200) {
        return response.data['orderId'];
      }
    } catch (e) {
      developer.log('❌ Failed to create payment order: $e');
    }
    return null;
  }

  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final response = await _apiService.verifyPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );
      if (response.statusCode == 200) {
        return response.data['isOk'] ?? false;
      }
    } catch (e) {
      developer.log('❌ Failed to verify payment: $e');
    }
    return false;
  }

  Future<bool> bookAppointment({
    required String state,
    required String city,
    required Map<String, dynamic> hospital,
    required String disease,
    required String notes,
    required String transactionId,
  }) async {
    try {
      final response = await _apiService.bookAppointment(
        state: state,
        city: city,
        hospital: hospital,
        disease: disease,
        notes: notes,
        transactionId: transactionId,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('✅ Appointment booked successfully');
        return true;
      }
    } catch (e) {
      developer.log('❌ Failed to book appointment: $e');
    }
    
    return false;
  }


}

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier();
});