import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/core/error/exceptions.dart';
import 'package:society_management_app/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:society_management_app/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:society_management_app/features/posts/domain/usecases/fetch_posts_usecase.dart';
import 'package:society_management_app/features/posts/domain/usecases/like_post_usecase.dart';
import 'package:society_management_app/features/posts/domain/usecases/unlike_post_usecase.dart';

import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final FetchPostsUsecase fetchPostsUsecase;
  final CreatePostUsecase createPostUsecase;
  final DeletePostUsecase deletePostUsecase;
  final LikePostUsecase likePostUsecase;
  final UnlikePostUsecase unlikePostUsecase;

  PostBloc({
    required this.fetchPostsUsecase,
    required this.createPostUsecase,
    required this.deletePostUsecase,
    required this.likePostUsecase,
    required this.unlikePostUsecase,
  }) : super(PostInitial()) {
    on<FetchPosts>(_onFetch);
    on<LoadMorePosts>(_onLoadMore);
    on<CreatePost>(_onCreate);
    on<DeletePost>(_onDelete);
    on<ToggleLike>(_onToggleLike);
  }

  String _errMsg(Object e) {
    if (e is ValidationException) return e.message;
    if (e is ServerException) return e.message;
    if (e is UnauthorizedException) return e.message;
    if (e is NetworkException) return e.message;
    return e.toString();
  }

  PostPageLoaded? get _current =>
      state is PostPageLoaded ? state as PostPageLoaded : null;

  Future<void> _onFetch(FetchPosts e, Emitter<PostState> emit) async {
    emit(PostPageLoading());
    try {
      final list = await fetchPostsUsecase(page: 1);
      emit(PostPageLoaded(posts: list, hasMore: list.length == 10, page: 1));
    } catch (err) {
      emit(PostPageError(_errMsg(err)));
    }
  }

  Future<void> _onLoadMore(LoadMorePosts e, Emitter<PostState> emit) async {
    final current = _current;
    if (current == null || !current.hasMore) return;
    try {
      final next = current.page + 1;
      final list = await fetchPostsUsecase(page: next);
      emit(
        PostPageLoaded(
          posts: [...current.posts, ...list],
          hasMore: list.length == 10,
          page: next,
        ),
      );
    } catch (err) {
      emit(PostPageError(_errMsg(err)));
    }
  }

  Future<void> _onCreate(CreatePost e, Emitter<PostState> emit) async {
    final current = _current;
    emit(PostFormLoading());
    try {
      final created = await createPostUsecase(e.content);
      emit(
        PostPageLoaded(
          posts: [created, ...?current?.posts],
          hasMore: current?.hasMore ?? false,
          page: current?.page ?? 1,
          message: "Post shared!",
        ),
      );
    } catch (err) {
      if (current != null) {
        emit(
          PostPageLoaded(
            posts: current.posts,
            hasMore: current.hasMore,
            page: current.page,
            message: _errMsg(err),
            isError: true,
          ),
        );
      } else {
        emit(PostFormError(_errMsg(err)));
      }
    }
  }

  Future<void> _onDelete(DeletePost e, Emitter<PostState> emit) async {
    final current = _current;
    if (current == null) return;
    try {
      await deletePostUsecase(e.postId);
      emit(
        PostPageLoaded(
          posts: current.posts.where((p) => p.id != e.postId).toList(),
          hasMore: current.hasMore,
          page: current.page,
          message: "Post deleted",
        ),
      );
    } catch (err) {
      emit(
        PostPageLoaded(
          posts: current.posts,
          hasMore: current.hasMore,
          page: current.page,
          message: _errMsg(err),
          isError: true,
        ),
      );
    }
  }

  // Optimistic update: flip immediately, revert on failure
  Future<void> _onToggleLike(ToggleLike e, Emitter<PostState> emit) async {
    final current = _current;
    if (current == null) return;

    // Apply optimistic update
    final optimistic = current.posts.map((p) {
      if (p.id != e.postId) return p;
      return p.copyWith(
        likedByMe: !e.currentlyLiked,
        likeCount: e.currentlyLiked ? p.likeCount - 1 : p.likeCount + 1,
      );
    }).toList();

    emit(
      PostPageLoaded(
        posts: optimistic,
        hasMore: current.hasMore,
        page: current.page,
      ),
    );

    try {
      if (e.currentlyLiked) {
        await unlikePostUsecase(e.postId);
      } else {
        await likePostUsecase(e.postId);
      }
    } catch (_) {
      // Revert on failure
      emit(
        PostPageLoaded(
          posts: current.posts,
          hasMore: current.hasMore,
          page: current.page,
          message: "Action failed. Please try again.",
          isError: true,
        ),
      );
    }
  }
}
