import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/core/error/exceptions.dart';
import 'package:society_management_app/features/announcements/domain/usecases/create_announcement_usecase.dart';
import 'package:society_management_app/features/announcements/domain/usecases/delete_announcement_usecase.dart';
import 'package:society_management_app/features/announcements/domain/usecases/fetch_active_announcement_usecase.dart';
import 'package:society_management_app/features/announcements/domain/usecases/fetch_announcement_usecase.dart';
import 'package:society_management_app/features/announcements/domain/usecases/update_announcement_usecase.dart';

import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final FetchAnnouncementsUsecase fetchAnnouncementsUsecase;
  final FetchActiveAnnouncementsUsecase fetchActiveAnnouncementsUsecase;
  final CreateAnnouncementUsecase createAnnouncementUsecase;
  final UpdateAnnouncementUsecase updateAnnouncementUsecase;
  final DeleteAnnouncementUsecase deleteAnnouncementUsecase;

  AnnouncementBloc({
    required this.fetchAnnouncementsUsecase,
    required this.fetchActiveAnnouncementsUsecase,
    required this.createAnnouncementUsecase,
    required this.updateAnnouncementUsecase,
    required this.deleteAnnouncementUsecase,
  }) : super(AnnouncementInitial()) {
    on<FetchAnnouncements>(_onFetch);
    on<LoadMoreAnnouncements>(_onLoadMore);
    on<FetchActiveAnnouncements>(_onFetchActive);
    on<CreateAnnouncement>(_onCreate);
    on<UpdateAnnouncement>(_onUpdate);
    on<DeleteAnnouncement>(_onDelete);
  }

  String _errMsg(Object e) {
    if (e is ValidationException) return e.message;
    if (e is ServerException) return e.message;
    if (e is UnauthorizedException) return e.message;
    if (e is ConflictException) return e.message;
    if (e is NetworkException) return e.message;
    return e.toString();
  }

  AnnouncementPageLoaded? get _currentLoaded =>
      state is AnnouncementPageLoaded ? state as AnnouncementPageLoaded : null;

  // ─── Fetch all (admin) ───────────────────────────────────────────────────────
  Future<void> _onFetch(
    FetchAnnouncements e,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementPageLoading());
    try {
      final list = await fetchAnnouncementsUsecase(page: 1);
      emit(
        AnnouncementPageLoaded(
          announcements: list,
          hasMore: list.length == 10,
          page: 1,
        ),
      );
    } catch (err) {
      emit(AnnouncementPageError(_errMsg(err)));
    }
  }

  // ─── Load more ───────────────────────────────────────────────────────────────
  Future<void> _onLoadMore(
    LoadMoreAnnouncements e,
    Emitter<AnnouncementState> emit,
  ) async {
    final current = _currentLoaded;
    if (current == null || !current.hasMore) return;
    try {
      final next = current.page + 1;
      final list = await fetchAnnouncementsUsecase(page: next);
      emit(
        AnnouncementPageLoaded(
          announcements: [...current.announcements, ...list],
          hasMore: list.length == 10,
          page: next,
        ),
      );
    } catch (err) {
      emit(AnnouncementPageError(_errMsg(err)));
    }
  }

  // ─── Fetch active (home widget) ──────────────────────────────────────────────
  Future<void> _onFetchActive(
    FetchActiveAnnouncements e,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(ActiveAnnouncementsLoading());
    try {
      final list = await fetchActiveAnnouncementsUsecase();
      emit(ActiveAnnouncementsLoaded(list));
    } catch (err) {
      emit(ActiveAnnouncementsError(_errMsg(err)));
    }
  }

  // ─── Create ──────────────────────────────────────────────────────────────────
  Future<void> _onCreate(
    CreateAnnouncement e,
    Emitter<AnnouncementState> emit,
  ) async {
    final current = _currentLoaded;
    emit(AnnouncementFormLoading());
    try {
      final created = await createAnnouncementUsecase(data: e.announcement);
      emit(
        AnnouncementPageLoaded(
          announcements: [created, ...?current?.announcements],
          hasMore: current?.hasMore ?? false,
          page: current?.page ?? 1,
          message: "Announcement created successfully",
        ),
      );
    } catch (err) {
      if (current != null) {
        emit(
          AnnouncementPageLoaded(
            announcements: current.announcements,
            hasMore: current.hasMore,
            page: current.page,
            message: _errMsg(err),
            isError: true,
          ),
        );
      } else {
        emit(AnnouncementFormError(_errMsg(err)));
      }
    }
  }

  // ─── Update ──────────────────────────────────────────────────────────────────
  Future<void> _onUpdate(
    UpdateAnnouncement e,
    Emitter<AnnouncementState> emit,
  ) async {
    final current = _currentLoaded;
    emit(AnnouncementFormLoading());
    try {
      final updated = await updateAnnouncementUsecase(
        announcementId: e.announcement.id,
        data: e.announcement,
      );
      final patched =
          current?.announcements
              .map((a) => a.id == updated.id ? updated : a)
              .toList() ??
          [updated];
      emit(
        AnnouncementPageLoaded(
          announcements: patched,
          hasMore: current?.hasMore ?? false,
          page: current?.page ?? 1,
          message: "Announcement updated successfully",
        ),
      );
    } catch (err) {
      if (current != null) {
        emit(
          AnnouncementPageLoaded(
            announcements: current.announcements,
            hasMore: current.hasMore,
            page: current.page,
            message: _errMsg(err),
            isError: true,
          ),
        );
      } else {
        emit(AnnouncementFormError(_errMsg(err)));
      }
    }
  }

  // ─── Delete ──────────────────────────────────────────────────────────────────
  Future<void> _onDelete(
    DeleteAnnouncement e,
    Emitter<AnnouncementState> emit,
  ) async {
    final current = _currentLoaded;
    if (current == null) return;
    try {
      await deleteAnnouncementUsecase(e.announcementId);
      emit(
        AnnouncementPageLoaded(
          announcements: current.announcements
              .where((a) => a.id != e.announcementId)
              .toList(),
          hasMore: current.hasMore,
          page: current.page,
          message: "Announcement deleted",
        ),
      );
    } catch (err) {
      emit(
        AnnouncementPageLoaded(
          announcements: current.announcements,
          hasMore: current.hasMore,
          page: current.page,
          message: _errMsg(err),
          isError: true,
        ),
      );
    }
  }
}
