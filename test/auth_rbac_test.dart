import 'package:flutter_test/flutter_test.dart';
import 'package:smart_med_waste/services/mock_database_service.dart';
import 'package:smart_med_waste/providers/auth_provider.dart';

void main() {
  group('Authentication & MockDatabaseService Tests', () {
    late MockDatabaseService dbService;
    late AuthProvider authProvider;

    setUp(() {
      dbService = MockDatabaseService();
      authProvider = AuthProvider();
    });

    test('Admin login succeeds and returns admin role', () async {
      final user = await dbService.loginWithEmailPassword('admin@hospital.org', 'password123');
      expect(user, isNotNull);
      expect(user!.role, 'admin');
      expect(user.email, 'admin@hospital.org');
      expect(user.isActive, isTrue);
    });

    test('Staff login succeeds and returns staff role', () async {
      final user = await dbService.loginWithEmailPassword('staff@hospital.org', 'password123');
      expect(user, isNotNull);
      expect(user!.role, 'staff');
      expect(user.department, contains('ICU'));
      expect(user.isActive, isTrue);
    });

    test('Invalid credentials throw exception', () async {
      expect(
        () => dbService.loginWithEmailPassword('nonexistent@hospital.org', 'wrongpass'),
        throwsA(isA<Exception>()),
      );
    });

    test('AuthProvider login sets authenticated user and role dynamically', () async {
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);

      await authProvider.login('admin@hospital.org', 'password123');

      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.role, 'admin');
      expect(authProvider.error, isNull);

      authProvider.logout();
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
    });

    test('Staff management operations update user status and department', () {
      final initialUsers = dbService.getAllUsers();
      expect(initialUsers.length, greaterThanOrEqualTo(2));

      final staffUser = initialUsers.firstWhere((u) => u.uid == 'usr_staff_01');
      expect(staffUser.isActive, isTrue);

      // Toggle status
      dbService.updateUserStatus('usr_staff_01', false);
      final updatedUser = dbService.getAllUsers().firstWhere((u) => u.uid == 'usr_staff_01');
      expect(updatedUser.isActive, isFalse);

      // Reset status
      dbService.updateUserStatus('usr_staff_01', true);
      expect(dbService.getAllUsers().firstWhere((u) => u.uid == 'usr_staff_01').isActive, isTrue);

      // Reassign department
      dbService.updateUserDepartment('usr_staff_01', 'Emergency Care OT');
      final reassigned = dbService.getAllUsers().firstWhere((u) => u.uid == 'usr_staff_01');
      expect(reassigned.department, 'Emergency Care OT');
    });
  });
}
