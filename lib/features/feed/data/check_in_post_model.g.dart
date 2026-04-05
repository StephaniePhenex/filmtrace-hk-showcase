// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckInPostImpl _$$CheckInPostImplFromJson(Map<String, dynamic> json) =>
    _$CheckInPostImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      locationId: json['location_id'] as String,
      movieName: json['movie_name'] as String,
      quote: json['quote'] as String?,
      text: json['text'] as String?,
      createdAt:
          const UserProfileTimestampConverter().fromJson(json['created_at']),
      likeCount: (json['like_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CheckInPostImplToJson(_$CheckInPostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'image_url': instance.imageUrl,
      'location_id': instance.locationId,
      'movie_name': instance.movieName,
      'quote': instance.quote,
      'text': instance.text,
      'created_at':
          const UserProfileTimestampConverter().toJson(instance.createdAt),
      'like_count': instance.likeCount,
    };
