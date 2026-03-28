import 'package:society_management_app/core/network/base_remote_data_source.dart';
import 'package:society_management_app/features/announcements/domain/entities/announcement_entities.dart';

import '../models/announcement_model.dart';

class AnnouncementRemoteDataSource extends BaseRemoteDataSource {
  AnnouncementRemoteDataSource(super.dioClient);

  // Admin: paginated list of ALL announcements
  Future<List<AnnouncementModel>> getAnnouncements({
    required int page,
    int limit = 10,
  }) async {
    final res = await get<List<AnnouncementModel>>(
      "/announcements",
      queryParameters: {"page": page, "limit": limit},
      parser: (json) => (json as List)
          .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    assertSuccess(res, "Failed to fetch announcements");
    return res.data ?? [];
  }

  // All users: only today's active announcements
  Future<List<AnnouncementModel>> getActiveAnnouncements() async {
    final res = await get<List<AnnouncementModel>>(
      "/announcements/active",
      parser: (json) => (json as List)
          .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    assertSuccess(res, "Failed to fetch active announcements");
    return res.data ?? [];
  }

  Future<AnnouncementModel> createAnnouncement(AnnouncementEntity data) async {
    final res = await post<AnnouncementModel>(
      "/announcements",
      AnnouncementModel.fromEntity(data).toJson(),
      parser: (json) =>
          AnnouncementModel.fromJson(json as Map<String, dynamic>),
    );
    assertSuccess(res, "Failed to create announcement");
    return res.data!;
  }

  Future<AnnouncementModel> updateAnnouncement({
    required int announcementId,
    required AnnouncementEntity data,
  }) async {
    final res = await put<AnnouncementModel>(
      "/announcements/$announcementId",
      AnnouncementModel.fromEntity(data).toJson(),
      parser: (json) =>
          AnnouncementModel.fromJson(json as Map<String, dynamic>),
    );
    assertSuccess(res, "Failed to update announcement");
    return res.data!;
  }

  Future<void> deleteAnnouncement(int announcementId) async {
    final res = await delete<void>("/announcements/$announcementId");
    assertSuccess(res, "Failed to delete announcement");
  }
}
