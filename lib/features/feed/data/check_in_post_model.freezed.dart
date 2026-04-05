// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in_post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CheckInPost _$CheckInPostFromJson(Map<String, dynamic> json) {
  return _CheckInPost.fromJson(json);
}

/// @nodoc
mixin _$CheckInPost {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_id')
  String get locationId => throw _privateConstructorUsedError;
  @JsonKey(name: 'movie_name')
  String get movieName => throw _privateConstructorUsedError;
  String? get quote => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  @UserProfileTimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'like_count')
  int? get likeCount => throw _privateConstructorUsedError;

  /// Serializes this CheckInPost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckInPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckInPostCopyWith<CheckInPost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckInPostCopyWith<$Res> {
  factory $CheckInPostCopyWith(
          CheckInPost value, $Res Function(CheckInPost) then) =
      _$CheckInPostCopyWithImpl<$Res, CheckInPost>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'image_url') String imageUrl,
      @JsonKey(name: 'location_id') String locationId,
      @JsonKey(name: 'movie_name') String movieName,
      String? quote,
      String? text,
      @JsonKey(name: 'created_at')
      @UserProfileTimestampConverter()
      DateTime createdAt,
      @JsonKey(name: 'like_count') int? likeCount});
}

/// @nodoc
class _$CheckInPostCopyWithImpl<$Res, $Val extends CheckInPost>
    implements $CheckInPostCopyWith<$Res> {
  _$CheckInPostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckInPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? imageUrl = null,
    Object? locationId = null,
    Object? movieName = null,
    Object? quote = freezed,
    Object? text = freezed,
    Object? createdAt = null,
    Object? likeCount = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      locationId: null == locationId
          ? _value.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as String,
      movieName: null == movieName
          ? _value.movieName
          : movieName // ignore: cast_nullable_to_non_nullable
              as String,
      quote: freezed == quote
          ? _value.quote
          : quote // ignore: cast_nullable_to_non_nullable
              as String?,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      likeCount: freezed == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckInPostImplCopyWith<$Res>
    implements $CheckInPostCopyWith<$Res> {
  factory _$$CheckInPostImplCopyWith(
          _$CheckInPostImpl value, $Res Function(_$CheckInPostImpl) then) =
      __$$CheckInPostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'image_url') String imageUrl,
      @JsonKey(name: 'location_id') String locationId,
      @JsonKey(name: 'movie_name') String movieName,
      String? quote,
      String? text,
      @JsonKey(name: 'created_at')
      @UserProfileTimestampConverter()
      DateTime createdAt,
      @JsonKey(name: 'like_count') int? likeCount});
}

/// @nodoc
class __$$CheckInPostImplCopyWithImpl<$Res>
    extends _$CheckInPostCopyWithImpl<$Res, _$CheckInPostImpl>
    implements _$$CheckInPostImplCopyWith<$Res> {
  __$$CheckInPostImplCopyWithImpl(
      _$CheckInPostImpl _value, $Res Function(_$CheckInPostImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckInPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? imageUrl = null,
    Object? locationId = null,
    Object? movieName = null,
    Object? quote = freezed,
    Object? text = freezed,
    Object? createdAt = null,
    Object? likeCount = freezed,
  }) {
    return _then(_$CheckInPostImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      locationId: null == locationId
          ? _value.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as String,
      movieName: null == movieName
          ? _value.movieName
          : movieName // ignore: cast_nullable_to_non_nullable
              as String,
      quote: freezed == quote
          ? _value.quote
          : quote // ignore: cast_nullable_to_non_nullable
              as String?,
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      likeCount: freezed == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckInPostImpl extends _CheckInPost {
  const _$CheckInPostImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'image_url') required this.imageUrl,
      @JsonKey(name: 'location_id') required this.locationId,
      @JsonKey(name: 'movie_name') required this.movieName,
      this.quote,
      this.text,
      @JsonKey(name: 'created_at')
      @UserProfileTimestampConverter()
      required this.createdAt,
      @JsonKey(name: 'like_count') this.likeCount})
      : super._();

  factory _$CheckInPostImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckInPostImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @override
  @JsonKey(name: 'location_id')
  final String locationId;
  @override
  @JsonKey(name: 'movie_name')
  final String movieName;
  @override
  final String? quote;
  @override
  final String? text;
  @override
  @JsonKey(name: 'created_at')
  @UserProfileTimestampConverter()
  final DateTime createdAt;
  @override
  @JsonKey(name: 'like_count')
  final int? likeCount;

  @override
  String toString() {
    return 'CheckInPost(id: $id, userId: $userId, imageUrl: $imageUrl, locationId: $locationId, movieName: $movieName, quote: $quote, text: $text, createdAt: $createdAt, likeCount: $likeCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInPostImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.movieName, movieName) ||
                other.movieName == movieName) &&
            (identical(other.quote, quote) || other.quote == quote) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, imageUrl, locationId,
      movieName, quote, text, createdAt, likeCount);

  /// Create a copy of CheckInPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckInPostImplCopyWith<_$CheckInPostImpl> get copyWith =>
      __$$CheckInPostImplCopyWithImpl<_$CheckInPostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckInPostImplToJson(
      this,
    );
  }
}

abstract class _CheckInPost extends CheckInPost {
  const factory _CheckInPost(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'image_url') required final String imageUrl,
      @JsonKey(name: 'location_id') required final String locationId,
      @JsonKey(name: 'movie_name') required final String movieName,
      final String? quote,
      final String? text,
      @JsonKey(name: 'created_at')
      @UserProfileTimestampConverter()
      required final DateTime createdAt,
      @JsonKey(name: 'like_count') final int? likeCount}) = _$CheckInPostImpl;
  const _CheckInPost._() : super._();

  factory _CheckInPost.fromJson(Map<String, dynamic> json) =
      _$CheckInPostImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;
  @override
  @JsonKey(name: 'location_id')
  String get locationId;
  @override
  @JsonKey(name: 'movie_name')
  String get movieName;
  @override
  String? get quote;
  @override
  String? get text;
  @override
  @JsonKey(name: 'created_at')
  @UserProfileTimestampConverter()
  DateTime get createdAt;
  @override
  @JsonKey(name: 'like_count')
  int? get likeCount;

  /// Create a copy of CheckInPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckInPostImplCopyWith<_$CheckInPostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
