import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:filmtrace_hk/core/data/location_model.dart';

/// Firestore `locations` 集合 schema（MVP，1.4.1 固定）：
///
/// - **文档 ID**：取景地 id（如 central_escalator），必填。
/// - **name** (string)：取景地名称，必填。
/// - **movie_name** (string)：电影名，必填。
/// - **latitude** (number)：纬度，必填。
/// - **longitude** (number)：经度，必填。
/// - **still_url** (string?)：剧照 URL，可选。
/// - **quote** (string?)：台词/说明，可选。
class LocationRepository {
  LocationRepository._();

  static const String _collectionId = 'locations';

  static CollectionReference<Map<String, dynamic>> get _coll =>
      FirebaseFirestore.instance.collection(_collectionId);

  /// 全量拉取 `locations`（含 Debug 下耗时 / 条数 / payload 粗估，不改查询形态）。
  static Future<QuerySnapshot<Map<String, dynamic>>> _fetchAllLocationDocs() async {
    final t0 = DateTime.now();
    final snapshot = await _coll.get();
    if (kDebugMode) {
      final ms = DateTime.now().difference(t0).inMilliseconds;
      final docs = snapshot.docs;
      final roughBytes = _roughPayloadBytesForDocs(docs);
      debugPrint(
        '[FilmTrace][Perf][locations] collection.get '
        'durationMs=$ms docCount=${docs.length} roughPayloadBytes=$roughBytes',
      );
    }
    return snapshot;
  }

  /// 各 doc 字段 key + 值的粗估 UTF-8 体量（非严格等于 Firestore 计费字节）。
  static int _roughPayloadBytesForDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    var total = 0;
    for (final doc in docs) {
      for (final e in doc.data().entries) {
        total += utf8.encode(e.key).length;
        total += _roughValueUtf8Bytes(e.value);
      }
    }
    return total;
  }

  static int _roughValueUtf8Bytes(dynamic v) {
    if (v == null) return 0;
    if (v is String) return utf8.encode(v).length;
    if (v is num) return 8;
    if (v is bool) return 1;
    return utf8.encode(v.toString()).length;
  }

  static Future<List<LocationModel>> getLocations() async {
    final snapshot = await _fetchAllLocationDocs();
    final list = <LocationModel>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final model = _docToLocation(doc.id, data);
      if (model != null) list.add(model);
    }
    return list;
  }

  static Future<LocationModel?> getLocationById(String id) async {
    final doc = await _coll.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return _docToLocation(doc.id, doc.data()!);
  }

  static Future<List<LocationModel>> getLocationsInBounds(
    double south,
    double west,
    double north,
    double east,
  ) async {
    final all = await getLocations();
    return all.where((loc) {
      final lat = loc.lat;
      final lng = loc.lng;
      return lat >= south && lat <= north && lng >= west && lng <= east;
    }).toList();
  }

  static LocationModel? _docToLocation(String id, Map<String, dynamic> data) {
    final name = data['name'] as String?;
    final movieName = data['movie_name'] as String?;
    final lat = _toDouble(data['latitude']);
    final lng = _toDouble(data['longitude']);
    if (name == null || movieName == null || lat == null || lng == null) {
      return null;
    }
    final map = Map<String, dynamic>.from(data)..['id'] = id;
    try {
      return LocationModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return null;
  }
}
