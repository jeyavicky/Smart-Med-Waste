import '../models/user_model.dart';

class MockDatabaseService {
  static final MockDatabaseService _instance = MockDatabaseService._internal();
  factory MockDatabaseService() => _instance;
  MockDatabaseService._internal();

  // Mock Users Database
  final List<UserModel> _mockUsers = [
    UserModel(
      uid: 'usr_admin_01',
      name: 'Dr. Ramanujam MD',
      phone: '+919876543210',
      email: 'admin@hospital.org',
      role: 'admin',
      department: 'Infection Control Officer',
      hospitalId: 'HOSP_CH_01',
      isActive: true,
      lastLogin: DateTime.now(),
    ),
    UserModel(
      uid: 'usr_staff_01',
      name: 'Nurse Sunita Kapoor',
      phone: '+919876543211',
      email: 'staff@hospital.org',
      role: 'staff',
      department: 'ICU - Floor 2',
      hospitalId: 'HOSP_CH_01',
      isActive: true,
      lastLogin: DateTime.now(),
    ),
    UserModel(
      uid: 'usr_staff_02',
      name: 'Rajesh Kumar (Hazard Tech)',
      phone: '+919876543212',
      email: 'rajesh.kumar@hospital.org',
      role: 'staff',
      department: 'Surgery OT - Floor 3',
      hospitalId: 'HOSP_CH_01',
      isActive: true,
      lastLogin: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    UserModel(
      uid: 'usr_staff_03',
      name: 'Dr. Ananya Iyer',
      phone: '+919876543213',
      email: 'ananya.iyer@hospital.org',
      role: 'staff',
      department: 'Pathology & Bio-Lab',
      hospitalId: 'HOSP_CH_01',
      isActive: true,
      lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  List<UserModel> getAllUsers() {
    return List.unmodifiable(_mockUsers);
  }

  void updateUserStatus(String uid, bool isActive) {
    final idx = _mockUsers.indexWhere((u) => u.uid == uid);
    if (idx != -1) {
      _mockUsers[idx] = _mockUsers[idx].copyWith(isActive: isActive);
    }
  }

  void updateUserDepartment(String uid, String newDepartment) {
    final idx = _mockUsers.indexWhere((u) => u.uid == uid);
    if (idx != -1) {
      _mockUsers[idx] = _mockUsers[idx].copyWith(department: newDepartment);
    }
  }

  /// Simulates Firebase Authentication & Firestore User Document Fetching
  Future<UserModel?> loginWithEmailPassword(String email, String password) async {
    // Simulate slight network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Basic mock auth check (any password works for these emails in the mock)
    try {
      final user = _mockUsers.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase().trim(),
      );
      
      if (!user.isActive) {
        throw Exception('User account is disabled.');
      }
      return user;
    } catch (e) {
      throw Exception('Invalid email or password.');
    }
  }
}
