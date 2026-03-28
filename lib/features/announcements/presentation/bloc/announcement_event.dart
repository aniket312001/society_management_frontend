import 'package:equatable/equatable.dart';
import 'package:society_management_app/features/announcements/domain/entities/announcement_entities.dart';

abstract class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();
  @override
  List<Object?> get props => [];
}

/// Admin: fetch paginated list of all announcements
class FetchAnnouncements extends AnnouncementEvent {
  const FetchAnnouncements();
}

/// Admin: load next page
class LoadMoreAnnouncements extends AnnouncementEvent {
  const LoadMoreAnnouncements();
}

/// Home widget: fetch only today's active announcements
class FetchActiveAnnouncements extends AnnouncementEvent {
  const FetchActiveAnnouncements();
}

class CreateAnnouncement extends AnnouncementEvent {
  final AnnouncementEntity announcement;
  const CreateAnnouncement(this.announcement);
  @override
  List<Object?> get props => [announcement];
}

class UpdateAnnouncement extends AnnouncementEvent {
  final AnnouncementEntity announcement;
  const UpdateAnnouncement(this.announcement);
  @override
  List<Object?> get props => [announcement];
}

class DeleteAnnouncement extends AnnouncementEvent {
  final int announcementId;
  const DeleteAnnouncement(this.announcementId);
  @override
  List<Object?> get props => [announcementId];
}
