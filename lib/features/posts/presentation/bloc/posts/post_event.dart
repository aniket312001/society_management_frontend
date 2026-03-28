import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();
  @override
  List<Object?> get props => [];
}

class FetchPosts extends PostEvent {
  const FetchPosts();
}

class LoadMorePosts extends PostEvent {
  const LoadMorePosts();
}

class CreatePost extends PostEvent {
  final String content;
  const CreatePost(this.content);
  @override
  List<Object?> get props => [content];
}

class DeletePost extends PostEvent {
  final int postId;
  const DeletePost(this.postId);
  @override
  List<Object?> get props => [postId];
}

class ToggleLike extends PostEvent {
  final int postId;
  final bool currentlyLiked;
  const ToggleLike({required this.postId, required this.currentlyLiked});
  @override
  List<Object?> get props => [postId, currentlyLiked];
}
