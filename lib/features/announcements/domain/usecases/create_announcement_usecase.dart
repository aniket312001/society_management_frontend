import 'package:society_management_app/features/announcements/domain/entities/announcement_entities.dart';
import 'package:society_management_app/features/announcements/domain/repositories/announcement_repository.dart';

class CreateAnnouncementUsecase {
  final AnnouncementRepository repository;
  CreateAnnouncementUsecase(this.repository);

  Future<AnnouncementEntity> call({required AnnouncementEntity data}) =>
      repository.createAnnouncement(data);
}
