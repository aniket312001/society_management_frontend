import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();
  @override
  List<Object?> get props => [];
}

class FetchComments extends CommentEvent {
  final int postId;
  const FetchComments(this.postId);
  @override
  List<Object?> get props => [postId];
}

class LoadMoreComments extends CommentEvent {
  const LoadMoreComments();
}

class AddComment extends CommentEvent {
  final int postId;
  final String content;
  const AddComment({required this.postId, required this.content});
  @override
  List<Object?> get props => [postId, content];
}

class DeleteComment extends CommentEvent {
  final int commentId;
  const DeleteComment(this.commentId);
  @override
  List<Object?> get props => [commentId];
}
