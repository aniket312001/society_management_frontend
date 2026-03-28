import 'package:society_management_app/features/posts/domain/entities/post_entities.dart';
import 'package:society_management_app/features/posts/domain/repositories/post_repository.dart';

class CreatePostUsecase {
  final PostRepository repository;
  CreatePostUsecase(this.repository);

  Future<PostEntity> call(String content) => repository.createPost(content);
}
