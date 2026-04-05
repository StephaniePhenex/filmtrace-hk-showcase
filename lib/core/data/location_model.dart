// ignore_for_file: invalid_annotation_target
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_model.freezed.dart';
part 'location_model.g.dart';

/// Firestore Timestamp → DateTime 的 JSON 轉換器，供 fromJson 使用。
class TimestampNullableConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampNullableConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is DateTime) return json;
    if (json is Timestamp) return json.toDate();
    return null;
  }

  @override
  Object? toJson(DateTime? object) => object;
}

/// 取景地資料模型（與 Firestore Sprint 3 對齊）。
/// 使用 Freezed 實現不可變與類型安全；支援 fromJson 以適配 Firestore。
@freezed
class LocationModel with _$LocationModel {
  const LocationModel._();

  const factory LocationModel({
    required String id,
    required String name,
    @JsonKey(name: 'latitude') required double lat,
    @JsonKey(name: 'longitude') required double lng,
    @JsonKey(name: 'movie_name') required String movieName,
    String? posterUrl,
    String? quote,
    @JsonKey(name: 'still_url') String? stillUrl,
    @JsonKey(name: 'updated_at') @TimestampNullableConverter() DateTime? updatedAt,
  }) = _LocationModel;

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  static const List<LocationModel> mockLocations = [
    LocationModel(
      id: 'central_escalator',
      name: '中環半山扶手電梯',
      lat: 22.2819,
      lng: 114.1548,
      movieName: '重慶森林',
      quote: '那個下午我做了個夢，我好像去了他家。',
      stillUrl: 'https://example.com/still_escalator.jpg',
    ),
    LocationModel(
      id: 'temple_street',
      name: '油麻地廟街',
      lat: 22.3094,
      lng: 114.1695,
      movieName: '新不了情',
      quote: '如果人生最壞只是死亡，生活中怎會有解決不了的難題。',
      stillUrl: 'https://example.com/still_temple.jpg',
    ),
    LocationModel(
      id: 'duddell_street',
      name: '都爹利街石階與煤氣燈',
      lat: 22.2810,
      lng: 114.1542,
      movieName: '喜劇之王',
      quote: '我養你啊。',
      stillUrl: 'https://example.com/still_steps.jpg',
    ),
    LocationModel(
      id: 'shek_o',
      name: '石澳健康院',
      lat: 22.2362,
      lng: 114.2554,
      movieName: '喜劇之王',
      quote: '努力！奮鬥！',
      stillUrl: 'https://example.com/still_shek_o.jpg',
    ),
    LocationModel(
      id: 'chungking_mansions',
      name: '尖沙咀重慶大廈一帶',
      lat: 22.2974,
      lng: 114.1716,
      movieName: '重慶森林',
      quote: '我們最接近的時候，我跟她之間的距離只有0.01公分。',
      stillUrl: 'https://example.com/still_mansions.jpg',
    ),
  ];

  List<double> get position => [lng, lat];
}
