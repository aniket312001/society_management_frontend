import 'package:equatable/equatable.dart';
import 'package:society_management_app/features/posts/domain/entities/post_entities.dart';

abstract class PostState extends Equatable {
  const PostState();
  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {}

class PostPageLoading extends PostState {}

class PostPageLoaded extends PostState {
  final List<PostEntity> posts;
  final bool hasMore;
  final int page;
  final String? message;
  final bool isError;

  const PostPageLoaded({
    required this.posts,
    required this.hasMore,
    required this.page,
    this.message,
    this.isError = false,
  });

  @override
  List<Object?> get props => [posts, hasMore, page, message, isError];
}

class PostPageError extends PostState {
  final String message;
  const PostPageError(this.message);
  @override
  List<Object?> get props => [message];
}

class PostFormLoading extends PostState {}

class PostFormError extends PostState {
  final String message;
  const PostFormError(this.message);
  @override
  List<Object?> get props => [message];
}
