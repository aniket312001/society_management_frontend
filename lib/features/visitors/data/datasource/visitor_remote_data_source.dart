import 'package:society_management_app/core/error/exceptions.dart';
import 'package:society_management_app/core/network/base_remote_data_source.dart';
import 'package:society_management_app/core/network/dio_client.dart';
import '../../domain/entities/visitor_entity.dart';
import '../models/visitor_model.dart';

class VisitorRemoteDataSource extends BaseRemoteDataSource {
  VisitorRemoteDataSource(super.dioClient);

  Future<List<VisitorModel>> getVisitors({
    required int page,
    String? status,
    String? date,
    String? search,
  }) async {
    print("getting data of visitor - ${page}");
    final res = await get<List<VisitorModel>>(
      "/visitors",
      queryParameters: {
        "page": page,
        "limit": 10,
        if (status != null) "status": status,
        if (date != null) "date": date,
        if (search != null) "search": search,
      },
      parser: (json) => (json as List)
          .map((e) => VisitorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    assertSuccess(res, "Failed to fetch visitors");
    return res.data ?? [];
  }

  Future<VisitorModel> createVisitor(VisitorEntity data) async {
    final res = await post<VisitorModel>(
      "/visitors",
      VisitorModel.fromEntity(data).toJson(),
      parser: (json) => VisitorModel.fromJson(json as Map<String, dynamic>),
    );
    assertSuccess(res, "Failed to create visitor");
    return res.data!;
  }

  Future<VisitorModel> updateVisitor({
    required int visitorId,
    required VisitorEntity data,
  }) async {
    final res = await patch<VisitorModel>(
      "/visitors/$visitorId",
      VisitorModel.fromEntity(data).toJson(),
      parser: (json) => VisitorModel.fromJson(json as Map<String, dynamic>),
    );
    assertSuccess(res, "Failed to update visitor");
    return res.data!;
  }

  Future<VisitorModel> updateStatus({
    required int visitorId,
    required String status,
    String? note,
  }) async {
    final res = await patch<VisitorModel>(
      "/visitors/$visitorId/status",
      {"status": status, if (note != null) "note": note},
      parser: (json) => VisitorModel.fromJson(json as Map<String, dynamic>),
    );
    assertSuccess(res, "Failed to update visitor status");
    return res.data!;
  }

  Future<void> deleteVisitor(int visitorId) async {
    final res = await delete<void>("/visitors/$visitorId");
    assertSuccess(res, "Failed to delete visitor");
  }
}
