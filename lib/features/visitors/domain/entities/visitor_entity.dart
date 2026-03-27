import 'package:equatable/equatable.dart';

class VisitorEntity extends Equatable {
  final int id;
  final int societyId;
  final int addedBy;
  final String name;
  final String? phone;
  final String? purpose;
  final DateTime visitDate;
  final String status; // pending / approved / rejected
  final String? note;
  final DateTime createdAt;

  const VisitorEntity({
    required this.id,
    required this.societyId,
    required this.addedBy,
    required this.name,
    this.phone,
    this.purpose,
    required this.visitDate,
    required this.status,
    this.note,
    required this.createdAt,
  });

  VisitorEntity copyWith({
    int? id,
    int? societyId,
    int? addedBy,
    String? name,
    String? phone,
    String? purpose,
    DateTime? visitDate,
    String? status,
    String? note,
    DateTime? createdAt,
  }) {
    return VisitorEntity(
      id: id ?? this.id,
      societyId: societyId ?? this.societyId,
      addedBy: addedBy ?? this.addedBy,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      purpose: purpose ?? this.purpose,
      visitDate: visitDate ?? this.visitDate,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    societyId,
    addedBy,
    name,
    phone,
    purpose,
    visitDate,
    status,
    note,
    createdAt,
  ];
}
