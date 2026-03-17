import 'package:equatable/equatable.dart';

class UserLoginEntity extends Equatable {
  bool exists = false;
  String status = 'pending';
  String role = "user";
  int society_id = -1;
  int id = -1;
  String email = "";
  String phone = "";

  UserLoginEntity({
    this.exists = false,
    this.role = "user",
    this.society_id = -1,
    this.status = "pending",
    this.id = -1,
    this.email = "",
    this.phone = "",
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
    exists,
    status,
    role,
    society_id,
    id,
    phone,
    email,
  ];
}
