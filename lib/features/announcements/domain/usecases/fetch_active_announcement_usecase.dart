import 'package:society_management_app/features/announcements/domain/entities/announcement_entities.dart';
import 'package:society_management_app/features/announcements/domain/repositories/announcement_repository.dart';

class FetchActiveAnnouncementsUsecase {
  final AnnouncementRepository repository;
  FetchActiveAnnouncementsUsecase(this.repository);

  Future<List<AnnouncementEntity>> call() =>
      repository.getActiveAnnouncements();
}
