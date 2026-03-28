import 'package:society_management_app/features/announcements/domain/entities/announcement_entities.dart';

abstract class AnnouncementRepository {
  Future<List<AnnouncementEntity>> getAnnouncements({
    required int page,
    int limit,
  });

  Future<List<AnnouncementEntity>> getActiveAnnouncements();

  Future<AnnouncementEntity> createAnnouncement(AnnouncementEntity data);

  Future<AnnouncementEntity> updateAnnouncement({
    required int announcementId,
    required AnnouncementEntity data,
  });

  Future<void> deleteAnnouncement(int announcementId);
}
