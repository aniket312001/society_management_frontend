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
  final String? fileUrl;
  final String? fileType;

  const CreatePost(this.content, {this.fileUrl, this.fileType});

  @override
  List<Object?> get props => [content, fileUrl, fileType];
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
