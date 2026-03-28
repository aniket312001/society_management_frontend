import 'package:society_management_app/features/posts/domain/entities/comment_entities.dart';
import 'package:society_management_app/features/posts/domain/repositories/post_repository.dart';

class FetchCommentsUsecase {
  final PostRepository repository;
  FetchCommentsUsecase(this.repository);

  Future<List<CommentEntity>> call({
    required int postId,
    required int page,
    int limit = 20,
  }) => repository.getComments(postId: postId, page: page, limit: limit);
}
