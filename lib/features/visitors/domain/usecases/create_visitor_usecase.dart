import '../entities/visitor_entity.dart';
import '../repositories/visitor_repository.dart';

class CreateVisitorUsecase {
  final VisitorRepository repository;
  CreateVisitorUsecase(this.repository);

  Future<VisitorEntity> call({required VisitorEntity data}) =>
      repository.createVisitor(data);
}
