import 'package:equatable/equatable.dart';
import 'package:society_management_app/features/posts/domain/entities/comment_entities.dart';

abstract class CommentState extends Equatable {
  const CommentState();
  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentLoaded extends CommentState {
  final List<CommentEntity> comments;
  final bool hasMore;
  final int page;
  final bool isSubmitting;

  const CommentLoaded({
    required this.comments,
    required this.hasMore,
    required this.page,
    this.isSubmitting = false,
  });

  CommentLoaded copyWith({
    List<CommentEntity>? comments,
    bool? hasMore,
    int? page,
    bool? isSubmitting,
  }) => CommentLoaded(
    comments: comments ?? this.comments,
    hasMore: hasMore ?? this.hasMore,
    page: page ?? this.page,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );

  @override
  List<Object?> get props => [comments, hasMore, page, isSubmitting];
}

class CommentError extends CommentState {
  final String message;
  const CommentError(this.message);
  @override
  List<Object?> get props => [message];
}
