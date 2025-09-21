import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://api.syncure.com';
  static const _storage = FlutterSecureStorage();
  static const bool useMockData = true;
  
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'auth_token');
        }
        handler.next(error);
      },
    ));
  }

  Future<Response> login(String email, String password) {
    if (useMockData) {
      return Future.value(Response(
        requestOptions: RequestOptions(path: '/auth/login'),
        data: {'token': 'mock_token_123'},
        statusCode: 200,
      ));
    }
    return _dio.post('/auth/login', data: {'email': email, 'password': password});
  }

  Future<Response> getProfile() {
    if (useMockData) {
      return Future.value(Response(
        requestOptions: RequestOptions(path: '/api/patient'),
        data: {
          'id': '1',
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john.doe@example.com',
          'phone': '+919876543210',
          'profileImage': 'https://via.placeholder.com/100',
          'age': 21,
          'bloodGroup': 'O+',
          'height': 5.6,
          'weight': 60.0
        },
        statusCode: 200,
      ));
    }
    return _dio.get('/api/patient');
  }

  Future<Response> getAppointments() {
    if (useMockData) {
      return Future.value(Response(
        requestOptions: RequestOptions(path: '/api/patient/appointment'),
        data: [
          {
            'id': '1',
            'hospitalName': 'Arihant Hospital',
            'doctorName': 'Dr. Sarah Wilson',
            'date': '2024-11-26T10:00:00Z',
            'status': 'Confirmed',
            'disease': 'Cardiology Checkup'
          },
          {
            'id': '2',
            'hospitalName': 'Zenith Hospital',
            'doctorName': 'Dr. Michael Brown',
            'date': '2024-11-28T14:30:00Z',
            'status': 'Pending',
            'disease': 'Asthma Treatment'
          }
        ],
        statusCode: 200,
      ));
    }
    return _dio.get('/api/patient/appointment');
  }

  Future<Response> getMedicalHistory() {
    if (useMockData) {
      return Future.value(Response(
        requestOptions: RequestOptions(path: '/api/patient/medical-history'),
        data: [
          {
            'id': '1',
            'hospitalName': 'Arihant Hospital',
            'doctorName': 'Dr. Sarah Wilson',
            'startDate': '2024-10-16T00:00:00Z',
            'endDate': '2024-10-20T00:00:00Z',
            'disease': 'COVID-19',
            'treatmentStatus': 'Recovered'
          },
          {
            'id': '2',
            'hospitalName': 'Zenith Hospital',
            'doctorName': 'Dr. Michael Brown',
            'startDate': '2024-10-03T00:00:00Z',
            'endDate': null,
            'disease': 'Asthma',
            'treatmentStatus': 'Ongoing'
          }
        ],
        statusCode: 200,
      ));
    }
    return _dio.get('/api/patient/medical-history');
  }

  Future<Response> getPaymentHistory() {
    if (useMockData) {
      return Future.value(Response(
        requestOptions: RequestOptions(path: '/api/patient/payment-history'),
        data: [
          {
            'id': '670f9a9ac7328f0c88b11dd1',
            'hospitalName': 'Arihant Hospital',
            'date': '2024-10-16T00:00:00Z',
            'amount': 150.0,
            'disease': 'COVID-19',
            'description': 'This is a note right',
            'status': 'Pending'
          }
        ],
        statusCode: 200,
      ));
    }
    return _dio.get('/api/patient/payment-history');
  }

  Future<Response> getDashboard() {
    if (useMockData) {
      return Future.value(Response(
        requestOptions: RequestOptions(path: '/api/patient/dashboard'),
        data: {
          'upcomingAppointments': 2,
          'pendingPayments': 1,
          'healthScore': 85,
          'waterBalance': 78,
          'currentTreatment': 10,
          'totalSpent': 1200.0,
          'lastVisit': '2024-10-16T00:00:00Z'
        },
        statusCode: 200,
      ));
    }
    return _dio.get('/api/patient/dashboard');
  }
}