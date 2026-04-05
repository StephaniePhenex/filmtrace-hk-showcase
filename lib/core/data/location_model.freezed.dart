// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) {
  return _LocationModel.fromJson(json);
}

/// @nodoc
mixin _$LocationModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'latitude')
  double get lat => throw _privateConstructorUsedError;
  @JsonKey(name: 'longitude')
  double get lng => throw _privateConstructorUsedError;
  @JsonKey(name: 'movie_name')
  String get movieName => throw _privateConstructorUsedError;
  String? get posterUrl => throw _privateConstructorUsedError;
  String? get quote => throw _privateConstructorUsedError;
  @JsonKey(name: 'still_url')
  String? get stillUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  @TimestampNullableConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this LocationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationModelCopyWith<LocationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationModelCopyWith<$Res> {
  factory $LocationModelCopyWith(
          LocationModel value, $Res Function(LocationModel) then) =
      _$LocationModelCopyWithImpl<$Res, LocationModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'latitude') double lat,
      @JsonKey(name: 'longitude') double lng,
      @JsonKey(name: 'movie_name') String movieName,
      String? posterUrl,
      String? quote,
      @JsonKey(name: 'still_url') String? stillUrl,
      @JsonKey(name: 'updated_at')
      @TimestampNullableConverter()
      DateTime? updatedAt});
}

/// @nodoc
class _$LocationModelCopyWithImpl<$Res, $Val extends LocationModel>
    implements $LocationModelCopyWith<$Res> {
  _$LocationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? lat = null,
    Object? lng = null,
    Object? movieName = null,
    Object? posterUrl = freezed,
    Object? quote = freezed,
    Object? stillUrl = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      movieName: null == movieName
          ? _value.movieName
          : movieName // ignore: cast_nullable_to_non_nullable
              as String,
      posterUrl: freezed == posterUrl
          ? _value.posterUrl
          : posterUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      quote: freezed == quote
          ? _value.quote
          : quote // ignore: cast_nullable_to_non_nullable
              as String?,
      stillUrl: freezed == stillUrl
          ? _value.stillUrl
          : stillUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocationModelImplCopyWith<$Res>
    implements $LocationModelCopyWith<$Res> {
  factory _$$LocationModelImplCopyWith(
          _$LocationModelImpl value, $Res Function(_$LocationModelImpl) then) =
      __$$LocationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'latitude') double lat,
      @JsonKey(name: 'longitude') double lng,
      @JsonKey(name: 'movie_name') String movieName,
      String? posterUrl,
      String? quote,
      @JsonKey(name: 'still_url') String? stillUrl,
      @JsonKey(name: 'updated_at')
      @TimestampNullableConverter()
      DateTime? updatedAt});
}

/// @nodoc
class __$$LocationModelImplCopyWithImpl<$Res>
    extends _$LocationModelCopyWithImpl<$Res, _$LocationModelImpl>
    implements _$$LocationModelImplCopyWith<$Res> {
  __$$LocationModelImplCopyWithImpl(
      _$LocationModelImpl _value, $Res Function(_$LocationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? lat = null,
    Object? lng = null,
    Object? movieName = null,
    Object? posterUrl = freezed,
    Object? quote = freezed,
    Object? stillUrl = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$LocationModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      movieName: null == movieName
          ? _value.movieName
          : movieName // ignore: cast_nullable_to_non_nullable
              as String,
      posterUrl: freezed == posterUrl
          ? _value.posterUrl
          : posterUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      quote: freezed == quote
          ? _value.quote
          : quote // ignore: cast_nullable_to_non_nullable
              as String?,
      stillUrl: freezed == stillUrl
          ? _value.stillUrl
          : stillUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationModelImpl extends _LocationModel {
  const _$LocationModelImpl(
      {required this.id,
      required this.name,
      @JsonKey(name: 'latitude') required this.lat,
      @JsonKey(name: 'longitude') required this.lng,
      @JsonKey(name: 'movie_name') required this.movieName,
      this.posterUrl,
      this.quote,
      @JsonKey(name: 'still_url') this.stillUrl,
      @JsonKey(name: 'updated_at')
      @TimestampNullableConverter()
      this.updatedAt})
      : super._();

  factory _$LocationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'latitude')
  final double lat;
  @override
  @JsonKey(name: 'longitude')
  final double lng;
  @override
  @JsonKey(name: 'movie_name')
  final String movieName;
  @override
  final String? posterUrl;
  @override
  final String? quote;
  @override
  @JsonKey(name: 'still_url')
  final String? stillUrl;
  @override
  @JsonKey(name: 'updated_at')
  @TimestampNullableConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'LocationModel(id: $id, name: $name, lat: $lat, lng: $lng, movieName: $movieName, posterUrl: $posterUrl, quote: $quote, stillUrl: $stillUrl, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.movieName, movieName) ||
                other.movieName == movieName) &&
            (identical(other.posterUrl, posterUrl) ||
                other.posterUrl == posterUrl) &&
            (identical(other.quote, quote) || other.quote == quote) &&
            (identical(other.stillUrl, stillUrl) ||
                other.stillUrl == stillUrl) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, lat, lng, movieName,
      posterUrl, quote, stillUrl, updatedAt);

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationModelImplCopyWith<_$LocationModelImpl> get copyWith =>
      __$$LocationModelImplCopyWithImpl<_$LocationModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationModelImplToJson(
      this,
    );
  }
}

abstract class _LocationModel extends LocationModel {
  const factory _LocationModel(
      {required final String id,
      required final String name,
      @JsonKey(name: 'latitude') required final double lat,
      @JsonKey(name: 'longitude') required final double lng,
      @JsonKey(name: 'movie_name') required final String movieName,
      final String? posterUrl,
      final String? quote,
      @JsonKey(name: 'still_url') final String? stillUrl,
      @JsonKey(name: 'updated_at')
      @TimestampNullableConverter()
      final DateTime? updatedAt}) = _$LocationModelImpl;
  const _LocationModel._() : super._();

  factory _LocationModel.fromJson(Map<String, dynamic> json) =
      _$LocationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'latitude')
  double get lat;
  @override
  @JsonKey(name: 'longitude')
  double get lng;
  @override
  @JsonKey(name: 'movie_name')
  String get movieName;
  @override
  String? get posterUrl;
  @override
  String? get quote;
  @override
  @JsonKey(name: 'still_url')
  String? get stillUrl;
  @override
  @JsonKey(name: 'updated_at')
  @TimestampNullableConverter()
  DateTime? get updatedAt;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationModelImplCopyWith<_$LocationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
