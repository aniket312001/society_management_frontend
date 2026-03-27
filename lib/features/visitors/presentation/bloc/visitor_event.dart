import '../../domain/entities/visitor_entity.dart';

abstract class VisitorEvent {}

class FetchVisitors extends VisitorEvent {
  final String? status;
  final String? date;
  final String? search;
  FetchVisitors({this.status, this.date, this.search});
}

class LoadMoreVisitors extends VisitorEvent {}

class CreateVisitor extends VisitorEvent {
  final VisitorEntity visitor;
  CreateVisitor(this.visitor);
}

class UpdateVisitor extends VisitorEvent {
  final VisitorEntity visitor;
  UpdateVisitor(this.visitor);
}

class UpdateVisitorStatus extends VisitorEvent {
  final int visitorId;
  final String status;
  final String? note;
  UpdateVisitorStatus({
    required this.visitorId,
    required this.status,
    this.note,
  });
}

class DeleteVisitor extends VisitorEvent {
  final int visitorId;
  DeleteVisitor(this.visitorId);
}