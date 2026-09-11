class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String role; // "admin" | "staff"
  final String department;
  final String hospitalId;
  final bool isActive;
  final DateTime lastLogin;

  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.department,
    required this.hospitalId,
    required this.isActive,
    required this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      department: json['department'] as String,
      hospitalId: json['hospitalId'] as String,
      isActive: json['isActive'] as bool,
      lastLogin: DateTime.parse(json['lastLogin'] as String),
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
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? department,
    String? hospitalId,
    bool? isActive,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      hospitalId: hospitalId ?? this.hospitalId,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
