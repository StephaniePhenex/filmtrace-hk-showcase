// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostCommentImpl _$$PostCommentImplFromJson(Map<String, dynamic> json) =>
    _$PostCommentImpl(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      text: json['text'] as String,
      createdAt:
          const UserProfileTimestampConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$$PostCommentImplToJson(_$PostCommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'user_id': instance.userId,
      'text': instance.text,
      'created_at':
          const UserProfileTimestampConverter().toJson(instance.createdAt),
    };
