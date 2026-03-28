import 'package:society_management_app/features/posts/domain/repositories/post_repository.dart';

class UnlikePostUsecase {
  final PostRepository repository;
  UnlikePostUsecase(this.repository);

  Future<void> call(int postId) => repository.unlikePost(postId);
}
