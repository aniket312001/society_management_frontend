import 'package:society_management_app/features/posts/domain/repositories/post_repository.dart';

class LikePostUsecase {
  final PostRepository repository;
  LikePostUsecase(this.repository);

  Future<void> call(int postId) => repository.likePost(postId);
}
