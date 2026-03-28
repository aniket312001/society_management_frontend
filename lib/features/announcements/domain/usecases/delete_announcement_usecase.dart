import 'package:society_management_app/features/announcements/domain/repositories/announcement_repository.dart';

class DeleteAnnouncementUsecase {
  final AnnouncementRepository repository;
  DeleteAnnouncementUsecase(this.repository);

  Future<void> call(int announcementId) =>
      repository.deleteAnnouncement(announcementId);
}
