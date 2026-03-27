import '../entities/visitor_entity.dart';

abstract class VisitorRepository {
  Future<List<VisitorEntity>> getVisitors({
    required int page,
    String? status,
    String? date,
    String? search,
  });

  Future<VisitorEntity> createVisitor(VisitorEntity data);

  Future<VisitorEntity> updateVisitor({
    required int visitorId,
    required VisitorEntity data,
  });

  Future<VisitorEntity> updateStatus({
    required int visitorId,
    required String status,
    String? note,
  });

  Future<void> deleteVisitor(int visitorId);
}
