import '../../domain/entities/visitor_entity.dart';

class VisitorModel extends VisitorEntity {
  const VisitorModel({
    required super.id,
    required super.societyId,
    required super.addedBy,
    required super.name,
    super.phone,
    super.purpose,
    required super.visitDate,
    required super.status,
    super.note,
    required super.createdAt,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['id'] as int? ?? 0,
      societyId: json['society_id'] as int? ?? 0,
      addedBy: json['added_by'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      purpose: json['purpose'] as String?,
      visitDate: json['visit_date'] != null
          ? DateTime.tryParse(json['visit_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] as String? ?? 'pending',
      note: json['note'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'purpose': purpose,
    'visit_date': visitDate.toIso8601String().split('T').first, // DATE only
  };

  factory VisitorModel.fromEntity(VisitorEntity e) => VisitorModel(
    id: e.id,
    societyId: e.societyId,
    addedBy: e.addedBy,
    name: e.name,
    phone: e.phone,
    purpose: e.purpose,
    visitDate: e.visitDate,
    status: e.status,
    note: e.note,
    createdAt: e.createdAt,
  );

  VisitorEntity toEntity() => VisitorEntity(
    id: id,
    societyId: societyId,
    addedBy: addedBy,
    name: name,
    phone: phone,
    purpose: purpose,
    visitDate: visitDate,
    status: status,
    note: note,
    createdAt: createdAt,
  );
}
