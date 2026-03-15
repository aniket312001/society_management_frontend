import 'package:equatable/equatable.dart';

class SocietyEntity extends Equatable {
  int id;
  String name;
  String address;
  DateTime created_at;
  String status;
  String description;
  int adminId;

  SocietyEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.created_at,
    required this.adminId,
    required this.status,
    required this.description,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
    id,
    name,
    address,
    created_at,
    adminId,
    status,
    description,
  ];
}
