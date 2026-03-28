import 'package:society_management_app/features/posts/domain/entities/post_entities.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.societyId,
    required super.userId,
    super.authorName,
    required super.content,
    required super.likeCount,
    required super.commentCount,
    required super.likedByMe,
    required super.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int? ?? 0,
      societyId: json['society_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      authorName: json['author_name'] as String?,
      content: json['content'] as String? ?? '',
      likeCount: int.tryParse(json['like_count']?.toString() ?? '0') ?? 0,
      commentCount: int.tryParse(json['comment_count']?.toString() ?? '0') ?? 0,
      likedByMe: json['liked_by_me'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {'content': content};
}
