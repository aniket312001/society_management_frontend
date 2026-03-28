import 'package:society_management_app/features/posts/domain/entities/post_entities.dart';

import '../repositories/post_repository.dart';

class FetchPostsUsecase {
  final PostRepository repository;
  FetchPostsUsecase(this.repository);

  Future<List<PostEntity>> call({required int page, int limit = 10}) =>
      repository.getPosts(page: page, limit: limit);
}
