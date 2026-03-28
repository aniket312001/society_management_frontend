import 'package:society_management_app/features/announcements/data/datasource/announcement_remote_datasource.dart';
import 'package:society_management_app/features/announcements/domain/entities/announcement_entities.dart';
import 'package:society_management_app/features/announcements/domain/repositories/announcement_repository.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDataSource remote;
  AnnouncementRepositoryImpl(this.remote);

  @override
  Future<List<AnnouncementEntity>> getAnnouncements({
    required int page,
    int limit = 10,
  }) async {
    final result = await remote.getAnnouncements(page: page, limit: limit);
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<AnnouncementEntity>> getActiveAnnouncements() async {
    final result = await remote.getActiveAnnouncements();
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<AnnouncementEntity> createAnnouncement(AnnouncementEntity data) =>
      remote.createAnnouncement(data);

  @override
  Future<AnnouncementEntity> updateAnnouncement({
    required int announcementId,
    required AnnouncementEntity data,
  }) => remote.updateAnnouncement(announcementId: announcementId, data: data);

  @override
  Future<void> deleteAnnouncement(int announcementId) =>
      remote.deleteAnnouncement(announcementId);
}
