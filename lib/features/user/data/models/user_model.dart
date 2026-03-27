import 'package:society_management_app/features/user/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.password,
    required super.society_id,
    required super.role,
    required super.created_at,
    required super.status,
  });

  /// Converts this UserModel instance to a JSON-compatible Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password, // ← commented out on purpose
      'society_id': society_id,
      'role': role,
      'created_at': created_at.toIso8601String(), // standard format for dates
      'status': status,
    };
  }

  /// Creates a UserModel from a JSON Map (e.g. from API response or Firestore)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      password: json['password'] as String? ?? '', // usually empty from backend
      society_id: json['society_id'] as int? ?? 0,
      role: json['role'] as String? ?? 'resident',
      created_at: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] as String? ?? 'active',
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      password: password,
      society_id: society_id,
      role: role,
      created_at: created_at,
      status: status,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      password: entity.password,
      society_id: entity.society_id,
      role: entity.role,
      created_at: entity.created_at,
      status: entity.status,
    );
  }

  /// Optional: If you want to create a copy with updated fields
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    int? society_id,
    String? role,
    DateTime? created_at,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      society_id: society_id ?? this.society_id,
      role: role ?? this.role,
      created_at: created_at ?? this.created_at,
      status: status ?? this.status,
    );
  }
}
