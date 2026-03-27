import '../entities/visitor_entity.dart';
import '../repositories/visitor_repository.dart';

class UpdateVisitorStatusUsecase {
  final VisitorRepository repository;
  UpdateVisitorStatusUsecase(this.repository);

  Future<VisitorEntity> call({
    required int visitorId,
    required String status,
    String? note,
  }) =>
      repository.updateStatus(visitorId: visitorId, status: status, note: note);
}
