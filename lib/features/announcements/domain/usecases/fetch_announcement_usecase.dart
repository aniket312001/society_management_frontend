import 'package:society_management_app/features/announcements/domain/entities/announcement_entities.dart';

import '../repositories/announcement_repository.dart';

class FetchAnnouncementsUsecase {
  final AnnouncementRepository repository;
  FetchAnnouncementsUsecase(this.repository);

  Future<List<AnnouncementEntity>> call({required int page, int limit = 10}) =>
      repository.getAnnouncements(page: page, limit: limit);
}
