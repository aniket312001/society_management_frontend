import 'package:society_management_app/features/posts/domain/entities/comment_entities.dart';
import 'package:society_management_app/features/posts/domain/repositories/post_repository.dart';

class AddCommentUsecase {
  final PostRepository repository;
  AddCommentUsecase(this.repository);

  Future<CommentEntity> call({required int postId, required String content}) =>
      repository.addComment(postId: postId, content: content);
}
