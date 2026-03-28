import 'package:society_management_app/features/posts/data/datasource/post_remote_datasource.dart';
import 'package:society_management_app/features/posts/domain/entities/comment_entities.dart';
import 'package:society_management_app/features/posts/domain/entities/post_entities.dart';
import 'package:society_management_app/features/posts/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remote;
  PostRepositoryImpl(this.remote);

  @override
  Future<List<PostEntity>> getPosts({required int page, int limit = 10}) =>
      remote.getPosts(page: page, limit: limit);

  @override
  Future<PostEntity> createPost(String content) => remote.createPost(content);

  @override
  Future<void> deletePost(int postId) => remote.deletePost(postId);

  @override
  Future<void> likePost(int postId) => remote.likePost(postId);

  @override
  Future<void> unlikePost(int postId) => remote.unlikePost(postId);

  @override
  Future<List<CommentEntity>> getComments({
    required int postId,
    required int page,
    int limit = 20,
  }) => remote.getComments(postId: postId, page: page, limit: limit);

  @override
  Future<CommentEntity> addComment({
    required int postId,
    required String content,
  }) => remote.addComment(postId: postId, content: content);

  @override
  Future<void> deleteComment(int commentId) => remote.deleteComment(commentId);
}
