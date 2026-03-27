import '../entities/visitor_entity.dart';
import '../repositories/visitor_repository.dart';

class UpdateVisitorUsecase {
  final VisitorRepository repository;
  UpdateVisitorUsecase(this.repository);

  Future<VisitorEntity> call({
    required int visitorId,
    required VisitorEntity data,
  }) => repository.updateVisitor(visitorId: visitorId, data: data);
}
