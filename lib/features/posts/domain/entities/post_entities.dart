import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final int id;
  final int societyId;
  final int userId;
  final String? authorName;
  final String content;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;
  final DateTime createdAt;

  const PostEntity({
    required this.id,
    required this.societyId,
    required this.userId,
    this.authorName,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    required this.likedByMe,
    required this.createdAt,
  });

  PostEntity copyWith({
    int? likeCount,
    int? commentCount,
    bool? likedByMe,
    String? content,
  }) => PostEntity(
    id: id,
    societyId: societyId,
    userId: userId,
    authorName: authorName,
    content: content ?? this.content,
    likeCount: likeCount ?? this.likeCount,
    commentCount: commentCount ?? this.commentCount,
    likedByMe: likedByMe ?? this.likedByMe,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [
    id,
    societyId,
    userId,
    authorName,
    content,
    likeCount,
    commentCount,
    likedByMe,
    createdAt,
  ];
}
