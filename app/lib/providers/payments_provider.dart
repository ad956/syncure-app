import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../models/payment.dart';
import 'auth_provider.dart';

class PaymentsNotifier extends StateNotifier<List<Payment>> {
  final ApiService _apiService;

  PaymentsNotifier(this._apiService) : super([]);

  Future<void> fetchPayments() async {
    try {
      final response = await _apiService.getPaymentHistory();
      final payments = (response.data as List)
          .map((json) => Payment.fromJson(json))
          .toList();
      state = payments;
    } catch (e) {
      // Handle error
    }
  }
}

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, List<Payment>>((ref) {
  return PaymentsNotifier(ref.watch(apiServiceProvider));
});