enum UserRole {
  admin,
  staff,
}

class AppUserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String role; // 'admin' | 'staff'
  final String department;
  final String hospitalId;
  final bool isActive;
  final DateTime lastLogin;
  final String? token; // Simulated JWT Token

  const AppUserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.department,
    required this.hospitalId,
    required this.isActive,
    required this.lastLogin,
    this.token,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isStaff => role.toLowerCase() == 'staff';
  String get roleString => role;
  UserRole get userRole => isAdmin ? UserRole.admin : UserRole.staff;

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      department: json['department'] as String,
      hospitalId: json['hospitalId'] as String,
      isActive: json['isActive'] as bool? ?? true,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : DateTime.now(),
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'department': department,
      'hospitalId': hospitalId,
      'isActive': isActive,
      'lastLogin': lastLogin.toIso8601String(),
      if (token != null) 'token': token,
    };
  }

  AppUserModel copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? department,
    String? hospitalId,
    bool? isActive,
    DateTime? lastLogin,
    String? token,
  }) {
    return AppUserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      hospitalId: hospitalId ?? this.hospitalId,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      token: token ?? this.token,
    );
  }
}

// Backwards compatibility alias
typedef UserModel = AppUserModel;
