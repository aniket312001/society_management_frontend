import 'package:equatable/equatable.dart';
import '../../domain/entities/visitor_entity.dart';

abstract class VisitorState extends Equatable {
  const VisitorState();
  @override
  List<Object?> get props => [];
}

class VisitorInitial extends VisitorState {}

class VisitorPageLoading extends VisitorState {}

class VisitorPageLoaded extends VisitorState {
  final List<VisitorEntity> visitors;
  final bool hasMore;
  final int page;
  final String? message;
  final bool isError;

  const VisitorPageLoaded({
    required this.visitors,
    required this.hasMore,
    required this.page,
    this.message,
    this.isError = false,
  });

  @override
  List<Object?> get props => [visitors, hasMore, page, message, isError];
}

class VisitorPageError extends VisitorState {
  final String message;
  const VisitorPageError(this.message);
  @override
  List<Object?> get props => [message];
}

class VisitorFormLoading extends VisitorState {}

class VisitorFormError extends VisitorState {
  final String message;
  const VisitorFormError(this.message);
  @override
  List<Object?> get props => [message];
}
