// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_comment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PostComment _$PostCommentFromJson(Map<String, dynamic> json) {
  return _PostComment.fromJson(json);
}

/// @nodoc
mixin _$PostComment {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'post_id')
  String get postId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  @UserProfileTimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PostComment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PostComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostCommentCopyWith<PostComment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostCommentCopyWith<$Res> {
  factory $PostCommentCopyWith(
          PostComment value, $Res Function(PostComment) then) =
      _$PostCommentCopyWithImpl<$Res, PostComment>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'post_id') String postId,
      @JsonKey(name: 'user_id') String userId,
      String text,
      @JsonKey(name: 'created_at')
      @UserProfileTimestampConverter()
      DateTime createdAt});
}

/// @nodoc
class _$PostCommentCopyWithImpl<$Res, $Val extends PostComment>
    implements $PostCommentCopyWith<$Res> {
  _$PostCommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PostComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? postId = null,
    Object? userId = null,
    Object? text = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostCommentImplCopyWith<$Res>
    implements $PostCommentCopyWith<$Res> {
  factory _$$PostCommentImplCopyWith(
          _$PostCommentImpl value, $Res Function(_$PostCommentImpl) then) =
      __$$PostCommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'post_id') String postId,
      @JsonKey(name: 'user_id') String userId,
      String text,
      @JsonKey(name: 'created_at')
      @UserProfileTimestampConverter()
      DateTime createdAt});
}

/// @nodoc
class __$$PostCommentImplCopyWithImpl<$Res>
    extends _$PostCommentCopyWithImpl<$Res, _$PostCommentImpl>
    implements _$$PostCommentImplCopyWith<$Res> {
  __$$PostCommentImplCopyWithImpl(
      _$PostCommentImpl _value, $Res Function(_$PostCommentImpl) _then)
      : super(_value, _then);

  /// Create a copy of PostComment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? postId = null,
    Object? userId = null,
    Object? text = null,
    Object? createdAt = null,
  }) {
    return _then(_$PostCommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostCommentImpl implements _PostComment {
  const _$PostCommentImpl(
      {required this.id,
      @JsonKey(name: 'post_id') required this.postId,
      @JsonKey(name: 'user_id') required this.userId,
      required this.text,
      @JsonKey(name: 'created_at')
      @UserProfileTimestampConverter()
      required this.createdAt});

  factory _$PostCommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostCommentImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'post_id')
  final String postId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String text;
  @override
  @JsonKey(name: 'created_at')
  @UserProfileTimestampConverter()
  final DateTime createdAt;

  @override
  String toString() {
    return 'PostComment(id: $id, postId: $postId, userId: $userId, text: $text, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostCommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, postId, userId, text, createdAt);

  /// Create a copy of PostComment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostCommentImplCopyWith<_$PostCommentImpl> get copyWith =>
      __$$PostCommentImplCopyWithImpl<_$PostCommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostCommentImplToJson(
      this,
    );
  }
}

abstract class _PostComment implements PostComment {
  const factory _PostComment(
      {required final String id,
      @JsonKey(name: 'post_id') required final String postId,
      @JsonKey(name: 'user_id') required final String userId,
      required final String text,
      @JsonKey(name: 'created_at')
      @UserProfileTimestampConverter()
      required final DateTime createdAt}) = _$PostCommentImpl;

  factory _PostComment.fromJson(Map<String, dynamic> json) =
      _$PostCommentImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'post_id')
  String get postId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get text;
  @override
  @JsonKey(name: 'created_at')
  @UserProfileTimestampConverter()
  DateTime get createdAt;

  /// Create a copy of PostComment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostCommentImplCopyWith<_$PostCommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
