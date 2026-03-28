import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final int id;
  final int postId;
  final int userId;
  final String? authorName;
  final String content;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    this.authorName,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    postId,
    userId,
    authorName,
    content,
    createdAt,
  ];
}
