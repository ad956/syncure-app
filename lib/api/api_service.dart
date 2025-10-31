import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

class ApiService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://syncure.vercel.app/api';
  static const _storage = FlutterSecureStorage();
  static const bool useMockData = false;
  
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      followRedirects: true,
      maxRedirects: 5,
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        developer.log('🚀 API Request: ${options.method} ${options.uri}');
        developer.log('📤 Request Data: ${options.data}');
        developer.log('📋 Request Headers: ${options.headers}');
        
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Cookie'] = 'better-auth.session_token=$token';
          developer.log('🔐 Using auth token: ${token.length > 20 ? token.substring(0, 20) + '...' : token}');
        } else {
          developer.log('🔓 No auth token found');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log('✅ API Response: ${response.statusCode} ${response.requestOptions.uri}');
        developer.log('📥 Response Data: ${response.data}');
        developer.log('🍪 Response Headers: ${response.headers.map}');
        
        // Log JSON structure for debugging
        if (response.data != null) {
          developer.log('🔍 JSON Structure: ${response.data.runtimeType}');
          if (response.data is Map) {
            developer.log('🗺 JSON Keys: ${(response.data as Map).keys.toList()}');
          }
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        developer.log('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.uri}');
        developer.log('💥 Error Data: ${error.response?.data}');
        developer.log('🔍 Error Headers: ${error.response?.headers.map}');
        
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'auth_token');
          developer.log('🗑️ Cleared auth token due to 401 error');
        }
        handler.next(error);
      },
    ));
  }

  // Step 1: Login (sends OTP to email)
  Future<Response> login(String usernameOrEmail, String password) {
    developer.log('🔑 Attempting login for: $usernameOrEmail');
    return _dio.post('/auth/login', data: {
      'usernameOrEmail': usernameOrEmail,
      'password': password,
      'role': 'patient',
    });
  }

  // Step 2: Verify OTP and get token
  Future<Response> verifyOtp(String email, String otp) {
    developer.log('🔐 Verifying OTP for: $email');
    return _dio.post('/auth/signin', data: {
      'email': email,
      'password': otp, // OTP is sent as password
    });
  }

  // Get demo patient credentials
  Future<Response> getDemoPatient() {
    developer.log('🎭 Getting demo patient credentials');
    developer.log('🎯 Demo API URL: $baseUrl/demo-user');
    developer.log('📦 Demo Payload: {"role": "patient"}');
    return _dio.post('/demo-user', data: {'role': 'patient'});
  }

  // Patient signup
  Future<Response> signup({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) {
    developer.log('📝 Attempting signup for: $email');
    return _dio.post('/auth/signup', data: {
      'firstname': firstName,
      'lastname': lastName,
      'username': username,
      'email': email,
      'password': password,
      'role': 'patient',
    });
  }

  Future<Response> getProfile() {
    return _dio.get('/patient');
  }

  Future<Response> getAppointments() {
    developer.log('📅 Fetching patient appointments');
    return _dio.get('/patient/appointment');
  }

  Future<Response> getMedicalHistory() {
    return _dio.get('/patient/medical-history');
  }

  Future<Response> getPaymentHistory() {
    return _dio.get('/patient/payment-history');
  }

  Future<Response> getDashboard() {
    developer.log('📊 Fetching dashboard from: $baseUrl/patient/dashboard');
    return _dio.get('/patient/dashboard');
  }

  Future<Response> recordVitals({
    required double weight,
    required int systolicBp,
    required int diastolicBp,
    required int heartRate,
    required double temperature,
    required int bloodSugar,
  }) {
    developer.log('📊 Recording vital signs');
    return _dio.post('/patient/vital-signs', data: {
      'weight': weight,
      'systolic_bp': systolicBp,
      'diastolic_bp': diastolicBp,
      'heart_rate': heartRate,
      'temperature': temperature,
      'blood_sugar': bloodSugar,
    });
  }

  Future<Response> takeMedication(String medicationId) {
    developer.log('💊 Marking medication as taken: $medicationId');
    return _dio.post('/patient/medications/$medicationId/take');
  }

  Future<Response> getMedicines() {
    developer.log('💊 Fetching medicines from: $baseUrl/patient/medicines');
    return _dio.get('/patient/medicines').catchError((error) async {
      developer.log('❌ /patient/medicines failed, trying /medicines');
      return await _dio.get('/medicines');
    });
  }

  // Booking data endpoints
  Future<Response> getStates() {
    developer.log('🏞️ Fetching states');
    return _dio.get('/states');
  }

  Future<Response> getCities(String state) {
    developer.log('🏢 Fetching cities for: $state');
    return _dio.get('/city', queryParameters: {'state': state});
  }

  Future<Response> getHospitals(String state, String city) {
    developer.log('🏥 Fetching hospitals for: $city, $state');
    return _dio.get('/get-hospitals', queryParameters: {
      'state': state,
      'city': city
    });
  }

  Future<Response> getDiseases() {
    developer.log('🩺 Fetching diseases');
    return _dio.get('/get-hospitals/disease');
  }

  Future<Response> createPaymentOrder(int amount) {
    developer.log('💳 Creating payment order');
    return _dio.post('/payment/create-order', data: {
      'amount': amount.toString(),
      'currency': 'INR'
    });
  }

  Future<Response> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) {
    developer.log('✅ Verifying payment');
    return _dio.post('/payment/verify', data: {
      'orderCreationId': orderId,
      'razorpayPaymentId': paymentId,
      'razorpaySignature': signature,
    });
  }

  Future<Response> checkPendingAppointment(String hospitalId) {
    developer.log('🔍 Checking pending appointments');
    return _dio.post('/patient/appointment/pending', data: {
      'hospital_id': hospitalId,
    });
  }

  Future<Response> bookAppointment({
    required String state,
    required String city,
    required Map<String, dynamic> hospital,
    required String disease,
    required String notes,
    required String transactionId,
  }) {
    developer.log('📅 Booking appointment');
    return _dio.post('/patient/appointment', data: {
      'state': state,
      'city': city,
      'hospital': hospital,
      'disease': disease,
      'note': notes,
      'transaction_id': transactionId,
    });
  }

  Future<Response> saveTransaction({
    required String transactionId,
    required String patientId,
    required String hospitalId,
    required String disease,
    required String description,
    required int amount,
    required String status,
  }) {
    developer.log('💾 Saving transaction');
    return _dio.post('/transactions', data: {
      'transaction_id': transactionId,
      'patient_id': patientId,
      'hospital_id': hospitalId,
      'disease': disease,
      'description': description,
      'amount': amount,
      'status': status,
    });
  }

  // Health Records APIs
  Future<Response> getVitalSigns() {
    return _dio.get('/patient/vital-signs');
  }

  Future<Response> getHealthTrends() {
    return _dio.get('/patient/health-trends');
  }

  Future<Response> getLabResults() {
    return _dio.get('/patient/lab-results');
  }

  Future<Response> addLabResult(Map<String, dynamic> data) {
    return _dio.post('/patient/lab-results', data: data);
  }

  Future<Response> getRecentLabResults() {
    return _dio.get('/patient/lab-results/recent');
  }

  // Medication APIs
  Future<Response> getMedications() {
    return _dio.get('/patient/medications');
  }

  Future<Response> addMedication(Map<String, dynamic> data) {
    return _dio.post('/patient/medications', data: data);
  }

  Future<Response> removeMedication(String medicationId) {
    return _dio.post('/patient/medications/remove', data: {'id': medicationId});
  }

  // Family Management APIs
  Future<Response> getFamilyMembers() {
    return _dio.get('/patient/family-members');
  }

  Future<Response> addFamilyMember(Map<String, dynamic> data) {
    return _dio.post('/patient/family-members', data: data);
  }

  // Payment & Billing APIs
  Future<Response> getPendingBills() {
    return _dio.get('/patient/bills/pending');
  }

  // Chat APIs
  Future<Response> getChatRooms() {
    return _dio.get('/chat/rooms');
  }

  Future<Response> createChatRoom(Map<String, dynamic> data) {
    return _dio.post('/chat/room', data: data);
  }

  Future<Response> getChatMessages(String roomId) {
    return _dio.get('/chat/messages', queryParameters: {'roomId': roomId});
  }

  Future<Response> sendMessage(Map<String, dynamic> data) {
    return _dio.post('/chat/messages', data: data);
  }

  Future<Response> markMessagesAsRead(String roomId) {
    return _dio.post('/chat/messages/read', data: {'roomId': roomId});
  }

  Future<Response> getDoctorsChatList() {
    return _dio.get('/patient/dashboard/doctors-chat-list');
  }

  // Appointment APIs
  Future<Response> getUpcomingAppointments() {
    return _dio.get('/patient/appointments/upcoming');
  }

  Future<Response> getAppointmentCharges(Map<String, dynamic> data) {
    return _dio.get('/patient/appointments/get-charge', queryParameters: data);
  }

  Future<Response> downloadReceipt(String appointmentId) {
    return _dio.get('/patient/appointments/download-receipt', queryParameters: {'id': appointmentId});
  }

  // Profile Update APIs
  Future<Response> updatePersonalInfo(Map<String, dynamic> data) {
    return _dio.post('/update-profile/personal', data: data);
  }

  Future<Response> updateAddress(Map<String, dynamic> data) {
    return _dio.post('/update-profile/address', data: data);
  }

  Future<Response> updateProfilePicture(Map<String, dynamic> data) {
    return _dio.post('/update-profile/picture', data: data);
  }

  Future<Response> resetPassword(Map<String, dynamic> data) {
    return _dio.post('/update-profile/reset-password', data: data);
  }

  // Utility APIs
  Future<Response> uploadImage(Map<String, dynamic> data) {
    return _dio.post('/cloudinary/sign-image', data: data);
  }

  Future<Response> testNotifications() {
    return _dio.get('/test-notifications');
  }

  Future<Response> subscribeToNotifications(Map<String, dynamic> data) {
    return _dio.post('/novu/subscriber', data: data);
  }

  // Log API response for debugging
  void logApiResponse(String endpoint, dynamic data) {
    developer.log('🔍 API Response from $endpoint:');
    developer.log('📋 Response JSON: ${data.toString()}');
  }
}