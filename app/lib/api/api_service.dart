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
    // Try different endpoints if main one fails
    return _dio.get('/patient/dashboard').catchError((error) async {
      developer.log('❌ /patient/dashboard failed, trying /dashboard');
      try {
        return await _dio.get('/dashboard');
      } catch (e) {
        developer.log('❌ /dashboard failed, trying /patient');
        return await _dio.get('/patient');
      }
    });
  }

  Future<Response> getMedicines() {
    developer.log('💊 Fetching medicines from: $baseUrl/patient/medicines');
    return _dio.get('/patient/medicines').catchError((error) async {
      developer.log('❌ /patient/medicines failed, trying /medicines');
      return await _dio.get('/medicines');
    });
  }

  // Log API response for debugging
  void logApiResponse(String endpoint, dynamic data) {
    developer.log('🔍 API Response from $endpoint:');
    developer.log('📋 Response JSON: ${data.toString()}');
  }
}