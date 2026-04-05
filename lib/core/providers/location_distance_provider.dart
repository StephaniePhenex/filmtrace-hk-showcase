import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:filmtrace_hk/core/data/location_model.dart';

/// 跨 feature 共享：計算與指定取景地的距離文案（距你 xxx m / km）。
/// map 與 location_detail 均從此處 import，不互相依賴。
final distanceToLocationProvider =
    FutureProvider.autoDispose.family<String, LocationModel>((ref, location) async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return '距你 -- 米';

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return '距你 -- 米';
    }

    Position? pos = await Geolocator.getLastKnownPosition();
    if (pos == null) {
      pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
    }

    final meters = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      location.lat,
      location.lng,
    );

    if (meters < 1000) return '距你 ${meters.round()} m';
    return '距你 ${(meters / 1000).toStringAsFixed(1)} km';
  } catch (e) {
    if (kDebugMode) debugPrint('距離計算失敗: $e');
    return '距你 -- 米';
  }
});
