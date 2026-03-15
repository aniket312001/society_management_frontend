import 'package:society_management_app/features/auth/domain/entities/society_entity.dart';

class SocietyModel extends SocietyEntity {
  SocietyModel({
    required super.id,
    required super.name,
    required super.address,
    required super.created_at,
    required super.adminId,
    required super.status,
    required super.description,
  });

  /// Converts this SocietyModel to a JSON-compatible Map
  /// (used when sending data to backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'created_at': created_at.toIso8601String(),
      'status': status,
      'description': description,
      'admin_id':
          adminId, // note: using snake_case to match common backend convention
    };
  }

  /// Creates a SocietyModel from JSON (API response, Firestore, etc.)
  factory SocietyModel.fromJson(Map<String, dynamic> json) {
    return SocietyModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      created_at: _parseDateTime(json['created_at']),
      status: json['status'] as String? ?? 'pending',
      description: json['description'] as String? ?? '',
      adminId:
          (json['admin_id'] as num?)?.toInt() ??
          (json['adminId'] as num?)?.toInt() ??
          0,
    );
  }

  /// Safe DateTime parsing (handles different formats backend might send)
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is int) {
      // possible unix timestamp (seconds or milliseconds)
      final ms = value > 1e10 ? value : value * 1000;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return DateTime.now();
  }

  /// Convert domain entity → data layer model
  factory SocietyModel.fromEntity(SocietyEntity entity) {
    return SocietyModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      created_at: entity.created_at,
      adminId: entity.adminId,
      status: entity.status,
      description: entity.description,
    );
  }

  /// Convert this model back to pure domain entity
  SocietyEntity toEntity() {
    return SocietyEntity(
      id: id,
      name: name,
      address: address,
      created_at: created_at,
      adminId: adminId,
      status: status,
      description: description,
    );
  }

  /// Convenient immutable copyWith method
  SocietyModel copyWith({
    int? id,
    String? name,
    String? address,
    DateTime? created_at,
    int? adminId,
    String? status,
    String? description,
  }) {
    return SocietyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      created_at: created_at ?? this.created_at,
      adminId: adminId ?? this.adminId,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }

  @override
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
