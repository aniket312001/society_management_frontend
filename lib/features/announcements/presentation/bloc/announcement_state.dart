import 'package:equatable/equatable.dart';
import 'package:society_management_app/features/announcements/domain/entities/announcement_entities.dart';

abstract class AnnouncementState extends Equatable {
  const AnnouncementState();
  @override
  List<Object?> get props => [];
}

class AnnouncementInitial extends AnnouncementState {}

class AnnouncementPageLoading extends AnnouncementState {}

/// Main list state (admin management view)
class AnnouncementPageLoaded extends AnnouncementState {
  final List<AnnouncementEntity> announcements;
  final bool hasMore;
  final int page;
  final String? message;
  final bool isError;

  const AnnouncementPageLoaded({
    required this.announcements,
    required this.hasMore,
    required this.page,
    this.message,
    this.isError = false,
  });

  @override
  List<Object?> get props => [announcements, hasMore, page, message, isError];
}

class AnnouncementPageError extends AnnouncementState {
  final String message;
  const AnnouncementPageError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Active (home widget) states
class ActiveAnnouncementsLoading extends AnnouncementState {}

class ActiveAnnouncementsLoaded extends AnnouncementState {
  final List<AnnouncementEntity> announcements;
  const ActiveAnnouncementsLoaded(this.announcements);
  @override
  List<Object?> get props => [announcements];
}

class ActiveAnnouncementsError extends AnnouncementState {
  final String message;
  const ActiveAnnouncementsError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Form states
class AnnouncementFormLoading extends AnnouncementState {}

class AnnouncementFormError extends AnnouncementState {
  final String message;
  const AnnouncementFormError(this.message);
  @override
  List<Object?> get props => [message];
}
