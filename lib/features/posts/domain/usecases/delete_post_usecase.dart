import 'package:society_management_app/features/posts/domain/repositories/post_repository.dart';

class DeletePostUsecase {
  final PostRepository repository;
  DeletePostUsecase(this.repository);

  Future<void> call(int postId) => repository.deletePost(postId);
}
