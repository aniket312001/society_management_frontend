import '../repositories/visitor_repository.dart';

class DeleteVisitorUsecase {
  final VisitorRepository repository;
  DeleteVisitorUsecase(this.repository);

  Future<void> call(int visitorId) => repository.deleteVisitor(visitorId);
}
