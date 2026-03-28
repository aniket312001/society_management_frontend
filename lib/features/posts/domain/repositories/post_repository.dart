import 'package:society_management_app/features/posts/domain/entities/comment_entities.dart';
import 'package:society_management_app/features/posts/domain/entities/post_entities.dart';

abstract class PostRepository {
  Future<List<PostEntity>> getPosts({required int page, int limit = 10});

  Future<PostEntity> createPost(String content);

  Future<void> deletePost(int postId);

  Future<void> likePost(int postId);

  Future<void> unlikePost(int postId);

  Future<List<CommentEntity>> getComments({
    required int postId,
    required int page,
    int limit = 20,
  });

  Future<CommentEntity> addComment({
    required int postId,
    required String content,
  });

  Future<void> deleteComment(int commentId);
}
