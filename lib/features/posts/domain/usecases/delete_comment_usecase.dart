import 'package:society_management_app/features/posts/domain/repositories/post_repository.dart';

class DeleteCommentUsecase {
  final PostRepository repository;
  DeleteCommentUsecase(this.repository);

  Future<void> call(int commentId) => repository.deleteComment(commentId);
}
