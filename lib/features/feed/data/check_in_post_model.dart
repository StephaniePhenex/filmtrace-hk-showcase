// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:filmtrace_hk/core/data/user_profile_model.dart';

part 'check_in_post_model.freezed.dart';
part 'check_in_post_model.g.dart';

@freezed
class CheckInPost with _$CheckInPost {
  const CheckInPost._();

  const factory CheckInPost({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'location_id') required String locationId,
    @JsonKey(name: 'movie_name') required String movieName,
    String? quote,
    String? text,
    @JsonKey(name: 'created_at')
    @UserProfileTimestampConverter()
    required DateTime createdAt,
    @JsonKey(name: 'like_count') int? likeCount,
  }) = _CheckInPost;

  factory CheckInPost.fromJson(Map<String, dynamic> json) =>
      _$CheckInPostFromJson(json);

  int get effectiveLikeCount => likeCount ?? 0;
}
