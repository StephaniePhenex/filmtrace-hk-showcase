// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:filmtrace_hk/core/data/user_profile_model.dart';

part 'post_comment_model.freezed.dart';
part 'post_comment_model.g.dart';

/// Firestore `post_comments`（PLAN_8 · 8.4）。
@freezed
class PostComment with _$PostComment {
  const factory PostComment({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'user_id') required String userId,
    required String text,
    @JsonKey(name: 'created_at')
    @UserProfileTimestampConverter()
    required DateTime createdAt,
  }) = _PostComment;

  factory PostComment.fromJson(Map<String, dynamic> json) =>
      _$PostCommentFromJson(json);
}
