import 'package:flutter/material.dart';
import '../models/app_user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  final ApiService _apiService = ApiService();

  AppUserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isStaff => _currentUser?.isStaff ?? false;
  String? get jwtToken => _currentUser?.token;

  Future<void> login(String identifier, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _apiService.login(
        identifier: identifier,
        password: password,
      );
      _currentUser = user;
      _isAuthenticated = true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _apiService.logout();
    _isAuthenticated = false;
    _currentUser = null;
    _error = null;
    notifyListeners();
  }
}
