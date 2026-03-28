import 'package:society_management_app/features/announcements/domain/entities/announcement_entities.dart';
import 'package:society_management_app/features/announcements/domain/repositories/announcement_repository.dart';

class UpdateAnnouncementUsecase {
  final AnnouncementRepository repository;
  UpdateAnnouncementUsecase(this.repository);

  Future<AnnouncementEntity> call({
    required int announcementId,
    required AnnouncementEntity data,
  }) =>
      repository.updateAnnouncement(announcementId: announcementId, data: data);
}
