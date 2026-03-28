import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/core/error/exceptions.dart';
import 'package:society_management_app/features/posts/domain/usecases/add_comment_usecase.dart';
import 'package:society_management_app/features/posts/domain/usecases/delete_comment_usecase.dart';
import 'package:society_management_app/features/posts/domain/usecases/fetch_post_comments.dart';
import 'package:society_management_app/features/posts/presentation/bloc/comments/comment_event.dart';
import 'package:society_management_app/features/posts/presentation/bloc/comments/comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final FetchCommentsUsecase fetchCommentsUsecase;
  final AddCommentUsecase addCommentUsecase;
  final DeleteCommentUsecase deleteCommentUsecase;

  int? _postId;

  CommentBloc({
    required this.fetchCommentsUsecase,
    required this.addCommentUsecase,
    required this.deleteCommentUsecase,
  }) : super(CommentInitial()) {
    on<FetchComments>(_onFetch);
    on<LoadMoreComments>(_onLoadMore);
    on<AddComment>(_onAdd);
    on<DeleteComment>(_onDelete);
  }

  String _errMsg(Object e) {
    if (e is ValidationException) return e.message;
    if (e is ServerException) return e.message;
    if (e is NetworkException) return e.message;
    return e.toString();
  }

  CommentLoaded? get _current =>
      state is CommentLoaded ? state as CommentLoaded : null;

  Future<void> _onFetch(FetchComments e, Emitter<CommentState> emit) async {
    _postId = e.postId;
    emit(CommentLoading());
    try {
      final list = await fetchCommentsUsecase(postId: e.postId, page: 1);
      emit(CommentLoaded(comments: list, hasMore: list.length == 20, page: 1));
    } catch (err) {
      emit(CommentError(_errMsg(err)));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreComments e,
    Emitter<CommentState> emit,
  ) async {
    final current = _current;
    if (current == null || !current.hasMore || _postId == null) return;
    try {
      final next = current.page + 1;
      final list = await fetchCommentsUsecase(postId: _postId!, page: next);
      emit(
        current.copyWith(
          comments: [...current.comments, ...list],
          hasMore: list.length == 20,
          page: next,
        ),
      );
    } catch (_) {}
  }

  Future<void> _onAdd(AddComment e, Emitter<CommentState> emit) async {
    final current = _current;
    if (current == null) return;
    emit(current.copyWith(isSubmitting: true));
    try {
      final comment = await addCommentUsecase(
        postId: e.postId,
        content: e.content,
      );
      emit(
        current.copyWith(
          comments: [...current.comments, comment],
          isSubmitting: false,
        ),
      );
    } catch (err) {
      emit(current.copyWith(isSubmitting: false));
      // rethrow so the UI can show a snackbar
      rethrow;
    }
  }

  Future<void> _onDelete(DeleteComment e, Emitter<CommentState> emit) async {
    final current = _current;
    if (current == null) return;
    try {
      await deleteCommentUsecase(e.commentId);
      emit(
        current.copyWith(
          comments: current.comments.where((c) => c.id != e.commentId).toList(),
        ),
      );
    } catch (err) {
      // silently ignore or show snackbar in UI
    }
  }
}
