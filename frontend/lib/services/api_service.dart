import 'package:dio/dio.dart';
import 'session_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3001/api';
}

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    validateStatus: (status) => status != null && status < 500,
    headers: {
      'Content-Type': 'application/json',
    },
  ))..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SessionService.getToken();
          if (token != null && !options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await SessionService.clearSession();
          }
          // Convert network errors to friendly messages
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            return handler.reject(DioException(
              requestOptions: e.requestOptions,
              error: 'Connection timed out. Please check if the server is running.',
              type: e.type,
            ));
          }
          if (e.type == DioExceptionType.connectionError) {
            return handler.reject(DioException(
              requestOptions: e.requestOptions,
              error: 'Cannot connect to server. Make sure your phone and computer are on the same Wi-Fi network.',
              type: e.type,
            ));
          }
          return handler.next(e);
        },
      ),
    );

  static Dio get dio => _dio;
  
  // Auth Endpoints
  static Future<bool> checkMobile(String mobile) async {
    final res = await _dio.post('/auth/check-mobile', data: {'mobile': mobile});
    return res.data['registered'] ?? false;
  }

  static Future<void> sendOtp(String mobile, String context) async {
    final res = await _dio.post('/auth/send-otp', data: {'mobile': mobile, 'context': context});
    if (res.data['success'] != true) {
      throw Exception(res.data['message'] ?? 'Failed to send OTP');
    }
  }

  static Future<dynamic> verifyOtp(String mobile, String otp, String context) async {
    final res = await _dio.post('/auth/verify-otp', data: {'mobile': mobile, 'otp': otp, 'context': context});
    if (res.data['success'] == true) {
      if (context == 'login') {
        return res.data; // Return full payload containing user and token
      }
      return res.data['token'] as String;
    }
    throw Exception(res.data['message'] ?? 'Verification failed');
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String mobile,
    required String pin,
    String? upiId,
    String? referredBy,
    required String otpToken,
  }) async {
    // Override header with OTP token just for this request
    final res = await _dio.post(
      '/auth/register',
      data: {
        'name': name,
        'mobile': mobile,
        'pin': pin,
        'upiId': upiId,
        'referredBy': referredBy,
      },
      options: Options(headers: {'Authorization': 'Bearer $otpToken'}),
    );
    if (res.data['success'] == true) return res.data;
    throw Exception(res.data['message'] ?? 'Registration failed');
  }

  static Future<Map<String, dynamic>> verifyPin(String mobile, String pin) async {
    final res = await _dio.post('/auth/verify-pin', data: {'mobile': mobile, 'pin': pin});
    if (res.data['success'] == true) return res.data;
    throw Exception(res.data['message'] ?? 'PIN verification failed');
  }

  static Future<void> setPin(String pin) async {
    final res = await _dio.post('/auth/set-pin', data: {'pin': pin});
    if (res.data['success'] != true) throw Exception(res.data['message'] ?? 'Failed to set PIN');
  }

  // User Endpoints
  static Future<Map<String, dynamic>> getProfile() async {
    final res = await _dio.get('/user/profile');
    if (res.data['success'] == true) return res.data['user'];
    throw Exception(res.data['message'] ?? 'Failed to get profile');
  }

  static Future<List<dynamic>> getTransactions() async {
    final res = await _dio.get('/user/transactions');
    if (res.data['success'] == true) return res.data['transactions'];
    throw Exception(res.data['message'] ?? 'Failed to get transactions');
  }

  static Future<List<dynamic>> getStocks() async {
    final res = await _dio.get('/user/stocks');
    if (res.data['success'] == true) return res.data['stocks'];
    throw Exception(res.data['message'] ?? 'Failed to get stocks');
  }

  static Future<Map<String, dynamic>> buyProduct(String productId, double quantity) async {
    final res = await _dio.post('/user/buy', data: {'productId': productId, 'quantity': quantity});
    if (res.data['success'] == true) return res.data;
    throw Exception(res.data['message'] ?? 'Purchase failed');
  }

  static Future<Map<String, dynamic>> sellProduct(String stockId, double quantity) async {
    final res = await _dio.post('/user/sell', data: {'stockId': stockId, 'quantity': quantity});
    if (res.data['success'] == true) return res.data;
    throw Exception(res.data['message'] ?? 'Sale failed');
  }

  // Products
  static Future<List<dynamic>> getProducts() async {
    final res = await _dio.get('/products');
    return res.data['products'];
  }

  // Razorpay
  static Future<Map<String, dynamic>> createOrder(double amount) async {
    // amount in INR, backend expects paise
    final res = await _dio.post('/razorpay/create-order', data: {'amount': (amount * 100).round()});
    if (res.data['success'] == true) return res.data;
    throw Exception(res.data['message'] ?? 'Failed to create order');
  }

  static Future<Map<String, dynamic>> verifyPayment(String orderId, String paymentId, String signature, double amount) async {
    final res = await _dio.post('/razorpay/verify-payment', data: {
      'razorpay_order_id': orderId,
      'razorpay_payment_id': paymentId,
      'razorpay_signature': signature,
      'amount': (amount * 100).round()
    });
    if (res.data['success'] == true) return res.data;
    throw Exception(res.data['message'] ?? 'Payment verification failed');
  }

  static Future<Map<String, dynamic>> payout(double amount, String upiId) async {
    final res = await _dio.post('/razorpay/payout', data: {'amount': amount, 'upiId': upiId});
    if (res.data['success'] == true) return res.data;
    throw Exception(res.data['message'] ?? 'Payout failed');
  }
}
