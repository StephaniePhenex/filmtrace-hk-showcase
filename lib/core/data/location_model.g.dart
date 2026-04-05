// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocationModelImpl _$$LocationModelImplFromJson(Map<String, dynamic> json) =>
    _$LocationModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: (json['latitude'] as num).toDouble(),
      lng: (json['longitude'] as num).toDouble(),
      movieName: json['movie_name'] as String,
      posterUrl: json['posterUrl'] as String?,
      quote: json['quote'] as String?,
      stillUrl: json['still_url'] as String?,
      updatedAt:
          const TimestampNullableConverter().fromJson(json['updated_at']),
    );

Map<String, dynamic> _$$LocationModelImplToJson(_$LocationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.lat,
      'longitude': instance.lng,
      'movie_name': instance.movieName,
      'posterUrl': instance.posterUrl,
      'quote': instance.quote,
      'still_url': instance.stillUrl,
      'updated_at':
          const TimestampNullableConverter().toJson(instance.updatedAt),
    };
