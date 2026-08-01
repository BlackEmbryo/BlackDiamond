import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();
    _user = await SessionService.getUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkMobile(String mobile) async {
    // Only used to check if exists, handled in UI typically, but can be cached here if needed
  }

  Future<void> login(String mobile, String pin) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.verifyPin(mobile, pin);
      if (res['success'] == true) {
        final token = res['token'];
        _user = AppUser.fromJson(res['user']);
        await SessionService.saveToken(token);
        await SessionService.saveUser(_user!);
      } else {
        throw Exception(res['message'] ?? 'Login failed');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> otpLogin(String mobile, String otp) async {
    _isLoading = true;
    notifyListeners();
    try {
      final dynamic res = await ApiService.verifyOtp(mobile, otp, 'login');
      if (res is Map && res['success'] == true) {
        final token = res['token'];
        _user = AppUser.fromJson(res['user']);
        await SessionService.saveToken(token);
        await SessionService.saveUser(_user!);
      } else {
        throw Exception(res['message'] ?? 'Login failed');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String mobile, String pin, String otpToken, {String? upiId, String? referredBy}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.register(
        name: name,
        mobile: mobile,
        pin: pin,
        otpToken: otpToken,
        upiId: upiId,
        referredBy: referredBy,
      );
      if (res['success'] == true) {
        final token = res['token'];
        _user = AppUser.fromJson(res['user']);
        await SessionService.saveToken(token);
        await SessionService.saveUser(_user!);
      } else {
        throw Exception(res['message'] ?? 'Registration failed');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await SessionService.clearSession();
    _user = null;
    notifyListeners();
  }
}
