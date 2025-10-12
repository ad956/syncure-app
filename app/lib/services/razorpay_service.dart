import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

class RazorpayService {
  static late Razorpay _razorpay;
  static String get keyId => dotenv.env['RAZORPAY_KEY_ID'] ?? 'rzp_test_6G3XmFmIhiJiWq';
  
  // Store callbacks for current payment
  static Function(PaymentSuccessResponse)? _currentSuccessCallback;
  static Function(PaymentFailureResponse)? _currentErrorCallback;

  static void initialize() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    developer.log('💳 Razorpay initialized with key: ${keyId.substring(0, 10)}...');
  }

  static void dispose() {
    _razorpay.clear();
  }

  static void startPayment({
    required double amount,
    required String orderId,
    required String name,
    required String email,
    required String contact,
    required String description,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
  }) {
    // Store callbacks for this payment
    _currentSuccessCallback = onSuccess;
    _currentErrorCallback = onError;
    
    var options = {
      'key': keyId,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Syncure Healthcare',
      'order_id': orderId,
      'description': description,
      'prefill': {
        'contact': contact,
        'email': email,
        'name': name,
      },
      'theme': {
        'color': '#6366F1'
      },
    };

    developer.log('💰 Starting payment: ₹$amount for $description');
    developer.log('🔧 Payment options: $options');
    
    try {
      _razorpay.open(options);
      developer.log('✅ Razorpay opened successfully');
    } catch (e) {
      developer.log('❌ Payment initialization error: $e');
      _currentErrorCallback?.call(PaymentFailureResponse(
        1, 
        'Payment initialization failed. Please try again.', 
        {'order_id': orderId, 'error': e.toString()}
      ));
      _clearCallbacks();
    }
  }

  static void _handlePaymentSuccess(PaymentSuccessResponse response) {
    developer.log('✅ Payment successful: ${response.paymentId}');
    _currentSuccessCallback?.call(response);
    _clearCallbacks();
  }

  static void _handlePaymentError(PaymentFailureResponse response) {
    developer.log('❌ Payment failed: ${response.message}');
    _currentErrorCallback?.call(response);
    _clearCallbacks();
  }

  static void _handleExternalWallet(ExternalWalletResponse response) {
    developer.log('🏦 External wallet selected: ${response.walletName}');
    // External wallet payments are handled by the wallet app
  }
  
  static void _clearCallbacks() {
    _currentSuccessCallback = null;
    _currentErrorCallback = null;
  }

  // Quick payment for appointments
  static void payForAppointment({
    required BuildContext context,
    required double amount,
    required String appointmentId,
    required String doctorName,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
  }) {
    startPayment(
      amount: amount,
      orderId: 'apt_$appointmentId',
      name: 'John Doe', // Replace with actual user name
      email: 'john@example.com', // Replace with actual user email
      contact: '9876543210', // Replace with actual user contact
      description: 'Appointment with Dr. $doctorName',
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  // Quick payment for medicines
  static void payForMedicine({
    required BuildContext context,
    required double amount,
    required String medicineId,
    required String medicineName,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
  }) {
    startPayment(
      amount: amount,
      orderId: 'med_$medicineId',
      name: 'John Doe', // Replace with actual user name
      email: 'john@example.com', // Replace with actual user email
      contact: '9876543210', // Replace with actual user contact
      description: 'Medicine: $medicineName',
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}