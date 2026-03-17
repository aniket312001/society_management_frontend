import 'package:society_management_app/features/auth/domain/entities/user_login_entity.dart';

class UserLoginModel extends UserLoginEntity {
  UserLoginModel({
    super.exists,
    super.role,
    super.society_id,
    super.status,
    super.id,
    super.email,
    super.phone,
  });

  /// Converts this UserModel instance to a JSON-compatible Map
  Map<String, dynamic> toJson() {
    return {
      'exists': exists,
      'role': role,
      'society_id': society_id,
      'status': status,
      'id': id,
      'email': email,
      'phone': phone,
    };
  }

  /// Creates a UserModel from a JSON Map (e.g. from API response or Firestore)
  factory UserLoginModel.fromJson(Map<String, dynamic> json) {
    return UserLoginModel(
      society_id: json['society_id'] as int? ?? 0,
      role: json['role'] as String? ?? 'user',
      exists: json['exists'] as bool? ?? false,
      id: json['id'] ?? -1,
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",

      status: json['status'] as String? ?? 'pending',
    );
  }

  UserLoginEntity toEntity() {
    return UserLoginEntity(
      society_id: society_id,
      role: role,
      status: status,
      exists: exists,
      id: id,
      email: email,
      phone: phone,
    );
  }

  factory UserLoginModel.fromEntity(UserLoginEntity entity) {
    return UserLoginModel(
      exists: entity.exists,
      society_id: entity.society_id,
      role: entity.role,
      status: entity.status,
      id: entity.id,
      email: entity.email,
      phone: entity.phone,
    );
  }

  /// Optional: If you want to create a copy with updated fields
  UserLoginModel copyWith({
    bool? exists,
    int? society_id,
    String? role,
    String? status,
    int? id,
    String? email,
    String? phone,
  }) {
    return UserLoginModel(
      exists: exists ?? this.exists,
      society_id: society_id ?? this.society_id,
      role: role ?? this.role,
      status: status ?? this.status,
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
