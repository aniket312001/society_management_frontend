import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/core/error/exceptions.dart';
import '../../domain/usecases/create_visitor_usecase.dart';
import '../../domain/usecases/delete_visitor_usecase.dart';
import '../../domain/usecases/fetch_visitors_usecase.dart';
import '../../domain/usecases/update_visitor_status_usecase.dart';
import '../../domain/usecases/update_visitor_usecase.dart';
import 'visitor_event.dart';
import 'visitor_state.dart';

class VisitorBloc extends Bloc<VisitorEvent, VisitorState> {
  final FetchVisitorsUsecase fetchVisitorsUsecase;
  final CreateVisitorUsecase createVisitorUsecase;
  final UpdateVisitorUsecase updateVisitorUsecase;
  final UpdateVisitorStatusUsecase updateVisitorStatusUsecase;
  final DeleteVisitorUsecase deleteVisitorUsecase;

  String? _status;
  String? _date;
  String? _search;

  VisitorBloc({
    required this.fetchVisitorsUsecase,
    required this.createVisitorUsecase,
    required this.updateVisitorUsecase,
    required this.updateVisitorStatusUsecase,
    required this.deleteVisitorUsecase,
  }) : super(VisitorInitial()) {
    on<FetchVisitors>(_onFetch);
    on<LoadMoreVisitors>(_onLoadMore);
    on<CreateVisitor>(_onCreate);
    on<UpdateVisitor>(_onUpdate);
    on<UpdateVisitorStatus>(_onUpdateStatus);
    on<DeleteVisitor>(_onDelete);
  }

  String _errMsg(Object e) {
    if (e is ValidationException) return e.message;
    if (e is ServerException) return e.message;
    if (e is UnauthorizedException) return e.message;
    if (e is ConflictException) return e.message;
    if (e is NetworkException) return e.message;
    return e.toString();
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  VisitorPageLoaded? get _currentLoaded =>
      state is VisitorPageLoaded ? state as VisitorPageLoaded : null;

  // ─── Fetch ──────────────────────────────────────────────────────────────────
  Future<void> _onFetch(FetchVisitors e, Emitter<VisitorState> emit) async {
    emit(VisitorPageLoading());
    _status = e.status;
    _date = e.date;
    _search = e.search;
    try {
      final list = await fetchVisitorsUsecase(
        page: 1,
        status: _status,
        date: _date,
        search: _search,
      );
      emit(
        VisitorPageLoaded(visitors: list, hasMore: list.length == 10, page: 1),
      );
    } catch (err) {
      emit(VisitorPageError(_errMsg(err)));
    }
  }

  // ─── Load More ──────────────────────────────────────────────────────────────
  Future<void> _onLoadMore(
    LoadMoreVisitors e,
    Emitter<VisitorState> emit,
  ) async {
    final current = _currentLoaded;
    if (current == null || !current.hasMore) return;
    try {
      final next = current.page + 1;
      final list = await fetchVisitorsUsecase(
        page: next,
        status: _status,
        date: _date,
        search: _search,
      );
      emit(
        VisitorPageLoaded(
          visitors: [...current.visitors, ...list],
          hasMore: list.length == 10,
          page: next,
        ),
      );
    } catch (err) {
      emit(VisitorPageError(_errMsg(err)));
    }
  }

  // ─── Create ─────────────────────────────────────────────────────────────────
  Future<void> _onCreate(CreateVisitor e, Emitter<VisitorState> emit) async {
    final current = _currentLoaded;
    emit(VisitorFormLoading());
    try {
      final created = await createVisitorUsecase(data: e.visitor);
      emit(
        VisitorPageLoaded(
          visitors: [created, ...?current?.visitors],
          hasMore: current?.hasMore ?? false,
          page: current?.page ?? 1,
          message: "Visitor added successfully",
        ),
      );
    } catch (err) {
      if (current != null) {
        emit(
          VisitorPageLoaded(
            visitors: current.visitors,
            hasMore: current.hasMore,
            page: current.page,
            message: _errMsg(err),
            isError: true,
          ),
        );
      } else {
        emit(VisitorFormError(_errMsg(err)));
      }
    }
  }

  // ─── Update ─────────────────────────────────────────────────────────────────
  Future<void> _onUpdate(UpdateVisitor e, Emitter<VisitorState> emit) async {
    final current = _currentLoaded;
    emit(VisitorFormLoading());
    try {
      final updated = await updateVisitorUsecase(
        visitorId: e.visitor.id,
        data: e.visitor,
      );
      final patched =
          current?.visitors
              .map((v) => v.id == updated.id ? updated : v)
              .toList() ??
          [updated];

      emit(
        VisitorPageLoaded(
          visitors: patched,
          hasMore: current?.hasMore ?? false,
          page: current?.page ?? 1,
          message: "Visitor updated successfully",
        ),
      );
    } catch (err) {
      if (current != null) {
        emit(
          VisitorPageLoaded(
            visitors: current.visitors,
            hasMore: current.hasMore,
            page: current.page,
            message: _errMsg(err),
            isError: true,
          ),
        );
      } else {
        emit(VisitorFormError(_errMsg(err)));
      }
    }
  }

  // ─── Update Status ──────────────────────────────────────────────────────────
  Future<void> _onUpdateStatus(
    UpdateVisitorStatus e,
    Emitter<VisitorState> emit,
  ) async {
    final current = _currentLoaded;
    if (current == null) return;
    try {
      final updated = await updateVisitorStatusUsecase(
        visitorId: e.visitorId,
        status: e.status,
        note: e.note,
      );
      emit(
        VisitorPageLoaded(
          visitors: current.visitors
              .map((v) => v.id == updated.id ? updated : v)
              .toList(),
          hasMore: current.hasMore,
          page: current.page,
          message: "Status updated to ${e.status}",
        ),
      );
    } catch (err) {
      emit(
        VisitorPageLoaded(
          visitors: current.visitors,
          hasMore: current.hasMore,
          page: current.page,
          message: _errMsg(err),
          isError: true,
        ),
      );
    }
  }

  // ─── Delete ─────────────────────────────────────────────────────────────────
  Future<void> _onDelete(DeleteVisitor e, Emitter<VisitorState> emit) async {
    final current = _currentLoaded;
    if (current == null) return;
    try {
      await deleteVisitorUsecase(e.visitorId);
      emit(
        VisitorPageLoaded(
          visitors: current.visitors.where((v) => v.id != e.visitorId).toList(),
          hasMore: current.hasMore,
          page: current.page,
          message: "Visitor removed",
        ),
      );
    } catch (err) {
      emit(
        VisitorPageLoaded(
          visitors: current.visitors,
          hasMore: current.hasMore,
          page: current.page,
          message: _errMsg(err),
          isError: true,
        ),
      );
    }
  }
}
