import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  int id;
  String name;
  String email;
  String phone;
  String password;
  int society_id;
  String role;
  DateTime created_at;
  String status;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.society_id,
    required this.role,
    required this.created_at,
    required this.status,
  });

  UserEntity copyWith({
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
    return UserEntity(
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

  @override
  // TODO: implement props
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    password,
    society_id,
    role,
    created_at,
    status,
  ];
}
