import 'package:flutter/material.dart';

class StaffUser {
  final String staffId;
  final String fullName;
  final String role;
  final String assignedWard;
  final String hospitalName;

  const StaffUser({
    required this.staffId,
    required this.fullName,
    required this.role,
    required this.assignedWard,
    required this.hospitalName,
  });
}

class AuthProvider extends ChangeNotifier {
  StaffUser? _currentUser;
  bool _isAuthenticated = true; // Auto-authenticated in demo mode for instant judging

  AuthProvider() {
    _currentUser = const StaffUser(
      staffId: 'STF-4428',
      fullName: 'Nurse Sunita Kapoor',
      role: 'ICU Ward Staff Incharge',
      assignedWard: 'ICU - Floor 2',
      hospitalName: 'Apollo Apex Multispecialty Hospital',
    );
  }

  StaffUser? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  void loginAsRole({
    required String staffId,
    required String name,
    required String role,
    required String ward,
  }) {
    _currentUser = StaffUser(
      staffId: staffId,
      fullName: name,
      role: role,
      assignedWard: ward,
      hospitalName: 'Apollo Apex Multispecialty Hospital',
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }
}
