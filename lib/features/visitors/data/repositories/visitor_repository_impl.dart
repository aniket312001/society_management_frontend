import 'package:society_management_app/features/visitors/data/datasource/visitor_remote_data_source.dart';

import '../../domain/entities/visitor_entity.dart';
import '../../domain/repositories/visitor_repository.dart';

class VisitorRepositoryImpl implements VisitorRepository {
  final VisitorRemoteDataSource remote;
  VisitorRepositoryImpl(this.remote);

  @override
  Future<List<VisitorEntity>> getVisitors({
    required int page,
    String? status,
    String? date,
    String? search,
  }) async {
    final result = await remote.getVisitors(
      page: page,
      status: status,
      date: date,
      search: search,
    );
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<VisitorEntity> createVisitor(VisitorEntity data) =>
      remote.createVisitor(data);

  @override
  Future<VisitorEntity> updateVisitor({
    required int visitorId,
    required VisitorEntity data,
  }) => remote.updateVisitor(visitorId: visitorId, data: data);

  @override
  Future<VisitorEntity> updateStatus({
    required int visitorId,
    required String status,
    String? note,
  }) => remote.updateStatus(visitorId: visitorId, status: status, note: note);

  @override
  Future<void> deleteVisitor(int visitorId) => remote.deleteVisitor(visitorId);
}
