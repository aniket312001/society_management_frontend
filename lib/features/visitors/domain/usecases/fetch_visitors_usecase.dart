import '../entities/visitor_entity.dart';
import '../repositories/visitor_repository.dart';

class FetchVisitorsUsecase {
  final VisitorRepository repository;
  FetchVisitorsUsecase(this.repository);

  Future<List<VisitorEntity>> call({
    required int page,
    String? status,
    String? date,
    String? search,
  }) => repository.getVisitors(
    page: page,
    status: status,
    date: date,
    search: search,
  );
}
