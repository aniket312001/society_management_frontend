import 'package:society_management_app/core/network/base_remote_data_source.dart';
import 'package:society_management_app/features/posts/data/model/comment_model.dart';
import 'package:society_management_app/features/posts/data/model/post_model.dart';

class PostRemoteDataSource extends BaseRemoteDataSource {
  PostRemoteDataSource(super.dioClient);

  Future<List<PostModel>> getPosts({required int page, int limit = 10}) async {
    final res = await get<List<PostModel>>(
      "/posts",
      queryParameters: {"page": page, "limit": limit},
      parser: (json) => (json as List)
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    assertSuccess(res, "Failed to fetch posts");
    return res.data ?? [];
  }

  Future<PostModel> createPost(String content) async {
    final res = await post<PostModel>("/posts", {
      "content": content,
    }, parser: (json) => PostModel.fromJson(json as Map<String, dynamic>));
    assertSuccess(res, "Failed to create post");
    return res.data!;
  }

  Future<void> deletePost(int postId) async {
    final res = await delete<void>("/posts/$postId");
    assertSuccess(res, "Failed to delete post");
  }

  Future<void> likePost(int postId) async {
    final res = await post<void>("/posts/$postId/like", {});
    assertSuccess(res, "Failed to like post");
  }

  Future<void> unlikePost(int postId) async {
    final res = await delete<void>("/posts/$postId/like");
    assertSuccess(res, "Failed to unlike post");
  }

  Future<List<CommentModel>> getComments({
    required int postId,
    required int page,
    int limit = 20,
  }) async {
    final res = await get<List<CommentModel>>(
      "/posts/$postId/comments",
      queryParameters: {"page": page, "limit": limit},
      parser: (json) => (json as List)
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    assertSuccess(res, "Failed to fetch comments");
    return res.data ?? [];
  }

  Future<CommentModel> addComment({
    required int postId,
    required String content,
  }) async {
    final res = await post<CommentModel>(
      "/posts/$postId/comments",
      {"content": content},
      parser: (json) => CommentModel.fromJson(json as Map<String, dynamic>),
    );
    assertSuccess(res, "Failed to add comment");
    return res.data!;
  }

  Future<void> deleteComment(int commentId) async {
    final res = await delete<void>("/comments/$commentId");
    assertSuccess(res, "Failed to delete comment");
  }
}
