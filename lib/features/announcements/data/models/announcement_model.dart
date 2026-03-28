import 'package:society_management_app/features/announcements/domain/entities/announcement_entities.dart';

class AnnouncementModel extends AnnouncementEntity {
  const AnnouncementModel({
    required super.id,
    required super.societyId,
    required super.createdBy,
    super.createdByName,
    required super.title,
    required super.body,
    required super.startDate,
    required super.endDate,
    required super.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as int? ?? 0,
      societyId: json['society_id'] as int? ?? 0,
      createdBy: json['created_by'] as int? ?? 0,
      createdByName: json['created_by_name'] as String?,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'start_date': startDate.toIso8601String().split('T').first,
    'end_date': endDate.toIso8601String().split('T').first,
  };

  factory AnnouncementModel.fromEntity(AnnouncementEntity e) =>
      AnnouncementModel(
        id: e.id,
        societyId: e.societyId,
        createdBy: e.createdBy,
        createdByName: e.createdByName,
        title: e.title,
        body: e.body,
        startDate: e.startDate,
        endDate: e.endDate,
        createdAt: e.createdAt,
      );

  AnnouncementEntity toEntity() => AnnouncementEntity(
    id: id,
    societyId: societyId,
    createdBy: createdBy,
    createdByName: createdByName,
    title: title,
    body: body,
    startDate: startDate,
    endDate: endDate,
    createdAt: createdAt,
  );
}
