import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_service.dart';
import '../models/user.dart';
import 'dart:developer' as developer;

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool otpSent;
  final String? email;

  AuthState({this.user, this.isLoading = false, this.error, this.otpSent = false, this.email});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  static const _storage = FlutterSecureStorage();

  AuthNotifier(this._apiService) : super(AuthState()) {
    loadSession();
  }

  // Step 1: Login (sends OTP to email)
  Future<void> login(String usernameOrEmail, String password) async {
    state = AuthState(isLoading: true);
    try {
      developer.log('🔑 Starting login process for: $usernameOrEmail');
      final response = await _apiService.login(usernameOrEmail, password);
      
      if (response.statusCode == 201) {
        developer.log('✅ Login successful, OTP sent to email');
        state = AuthState(otpSent: true, email: usernameOrEmail);
      } else {
        state = AuthState(error: 'Login failed');
      }
    } catch (e) {
      developer.log('❌ Login error: $e');
      state = AuthState(error: e.toString());
    }
  }

  // Step 2: Verify OTP and complete authentication
  Future<void> verifyOtp(String email, String otp) async {
    state = AuthState(isLoading: true, email: email);
    try {
      developer.log('🔐 ========== VERIFYING OTP ==========');
      developer.log('🔐 Email: $email');
      developer.log('🔐 OTP: $otp');
      
      final response = await _apiService.verifyOtp(email, otp);
      
      developer.log('🔐 OTP verification status: ${response.statusCode}');
      developer.log('🔐 OTP verification data: ${response.data}');
      
      if (response.statusCode == 200) {
        final userData = response.data['user'];
        developer.log('🔐 User data received: $userData');
        
        // Extract token from cookie header
        final cookies = response.headers['set-cookie'];
        developer.log('🍪 All cookies: $cookies');
        
        if (cookies != null && cookies.isNotEmpty) {
          final cookieString = cookies.first;
          developer.log('🍪 First cookie: $cookieString');
          
          final tokenMatch = RegExp(r'better-auth\.session_token=([^;]+)').firstMatch(cookieString);
          final token = tokenMatch?.group(1);
          
          developer.log('🔐 Extracted token: $token');
          
          if (token != null) {
            await _storage.write(key: 'auth_token', value: token);
            developer.log('🔐 Token saved successfully to storage');
            
            try {
              final user = User.fromJson(userData);
              state = AuthState(user: user);
              developer.log('✅ Authentication completed successfully');
            } catch (userParseError) {
              developer.log('❌ User parsing error: $userParseError');
              state = AuthState(error: 'Failed to parse user data');
            }
          } else {
            developer.log('❌ No token found in cookie');
            state = AuthState(error: 'No token received');
          }
        } else {
          developer.log('❌ No cookies received');
          state = AuthState(error: 'No authentication cookie received');
        }
      } else {
        developer.log('❌ Invalid OTP, status: ${response.statusCode}');
        state = AuthState(error: 'Invalid OTP');
      }
    } catch (e) {
      developer.log('❌ OTP verification error: $e');
      developer.log('❌ OTP verification error type: ${e.runtimeType}');
      state = AuthState(error: e.toString());
    }
  }

  // Demo login for testing
  Future<void> demoLogin() async {
    state = AuthState(isLoading: true);
    try {
      developer.log('🎭 ========== STARTING DEMO LOGIN ==========');
      developer.log('🎭 Step 1: Getting demo patient credentials');
      
      final response = await _apiService.getDemoPatient();
      
      developer.log('🎭 Demo response status: ${response.statusCode}');
      developer.log('🎭 Demo response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final userData = response.data['user'];
        developer.log('🎭 Demo user data: $userData');
        
        // Extract token from cookie header
        final cookies = response.headers['set-cookie'];
        developer.log('🍪 Demo cookies: $cookies');
        
        if (cookies != null && cookies.isNotEmpty) {
          final cookieString = cookies.first;
          final tokenMatch = RegExp(r'auth-token=([^;]+)').firstMatch(cookieString) ?? 
                              RegExp(r'better-auth\.session_token=([^;]+)').firstMatch(cookieString);
          final token = tokenMatch?.group(1);
          
          developer.log('🔐 Demo token extracted: ${token?.substring(0, 20)}...');
          
          if (token != null) {
            await _storage.write(key: 'auth_token', value: token);
            developer.log('🔐 Demo token saved successfully');
            
            try {
              final user = User.fromJson(userData);
              state = AuthState(user: user);
              developer.log('✅ Demo authentication completed successfully');
            } catch (userParseError) {
              developer.log('❌ Demo user parsing error: $userParseError');
              state = AuthState(error: 'Failed to parse demo user data');
            }
          } else {
            developer.log('❌ No demo token found in cookie');
            state = AuthState(error: 'No demo token received');
          }
        } else {
          developer.log('❌ No demo cookies received');
          state = AuthState(error: 'No demo authentication cookie received');
        }
      } else {
        developer.log('❌ Demo login failed with status: ${response.statusCode}');
        state = AuthState(error: 'Demo login failed: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('❌ Demo login error: $e');
      developer.log('❌ Demo login error type: ${e.runtimeType}');
      state = AuthState(error: 'Demo login failed: ${e.toString()}');
    }
  }

  // Signup
  Future<void> signup({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    state = AuthState(isLoading: true);
    try {
      developer.log('📝 Starting signup for: $email');
      final response = await _apiService.signup(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
      );
      
      if (response.statusCode == 201) {
        developer.log('✅ Signup successful');
        state = AuthState(otpSent: true, email: email);
      } else {
        state = AuthState(error: 'Signup failed');
      }
    } catch (e) {
      developer.log('❌ Signup error: $e');
      state = AuthState(error: e.toString());
    }
  }

  Future<void> logout() async {
    developer.log('🚪 Logging out user');
    await _storage.delete(key: 'auth_token');
    state = AuthState();
  }

  void handleUnauthorized() {
    developer.log('🚫 Handling unauthorized access');
    logout();
  }

  // Load saved session
  Future<void> loadSession() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        developer.log('🔐 Found saved token, attempting to load profile');
        try {
          final profileResponse = await _apiService.getProfile();
          if (profileResponse.statusCode == 200) {
            final userData = profileResponse.data['data'] ?? profileResponse.data;
            final user = User.fromJson(userData);
            state = AuthState(user: user);
            developer.log('✅ Session restored successfully');
          } else {
            await _storage.delete(key: 'auth_token');
            developer.log('🗑️ Invalid token, cleared storage');
            state = AuthState();
          }
        } catch (apiError) {
          developer.log('❌ API error during session load: $apiError');
          await _storage.delete(key: 'auth_token');
          state = AuthState();
        }
      } else {
        developer.log('🔓 No saved token found');
        state = AuthState();
      }
    } catch (e) {
      developer.log('❌ Session load error: $e');
      try {
        await _storage.delete(key: 'auth_token');
      } catch (storageError) {
        developer.log('❌ Storage clear error: $storageError');
      }
      state = AuthState();
    }
  }
}

final apiServiceProvider = Provider((ref) => ApiService());
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiServiceProvider));
});