import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:filmtrace_hk/core/data/location_model.dart';
import 'package:filmtrace_hk/core/data/location_repository.dart';

/// 詳情數據：按 id 從 Repository 拉取，UI 僅 ref.watch，不直接調 Repository。
final locationDetailProvider =
    FutureProvider.autoDispose.family<LocationModel?, String>((ref, id) async {
  return LocationRepository.getLocationById(id);
});

/// 200m 打卡可用性：內部依賴 locationDetailProvider + 定位 + distanceBetween。
/// location loading / null / 權限未開 / 未開啟定位 → false；距離 ≥ 200m → false；< 200m → true。
final canCheckInProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, locationId) async {
  final locationAsync = ref.watch(locationDetailProvider(locationId));
  final location = locationAsync.value;
  if (location == null) return false;

  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
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
    return meters < 200;
  } catch (_) {
    return false;
  }
});
