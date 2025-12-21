import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.register(
        fullName: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      _user = result['user'];
      await _saveUser(_user!, result['accessToken'] as String?, result['refreshToken'] as String?);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.login(
        email: email,
        password: password,
      );
      _user = result['user'];
      await _saveUser(_user!, result['accessToken'] as String?, result['refreshToken'] as String?);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    _error = null;
    _apiService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    notifyListeners();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    if (userJson != null && accessToken != null && refreshToken != null) {
      _user = User.fromJson(jsonDecode(userJson));
      _apiService.setTokens(accessToken, refreshToken);
      notifyListeners();
    }
  }

  Future<void> _saveUser(User user, String? accessToken, String? refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    if (accessToken != null) {
      await prefs.setString('accessToken', accessToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString('refreshToken', refreshToken);
    } else {
      // Nếu không có refreshToken, tạo một giá trị mặc định hoặc để trống
      await prefs.setString('refreshToken', '');
    }
    _apiService.setTokens(accessToken, refreshToken ?? '');
  }

  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    if (_user == null) {
      throw Exception('Chưa đăng nhập');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _apiService.updateUser(
        id: _user!.id,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );
      _user = updatedUser;
      // Lưu lại user đã cập nhật, giữ nguyên tokens
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';
      final refreshToken = prefs.getString('refreshToken') ?? '';
      await _saveUser(_user!, accessToken, refreshToken);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null) {
      throw Exception('Chưa đăng nhập');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.changePassword(
        id: _user!.id,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
