import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmtrace_hk/core/data/location_model.dart';
import 'package:filmtrace_hk/core/data/location_repository.dart';
import 'package:filmtrace_hk/features/map/services/navigation_service.dart';

export 'package:filmtrace_hk/core/providers/location_distance_provider.dart';

// =============================================================================
// 1. 視野狀態（地圖 onMapIdle / onMapCreated 時由 UI 調用 setBounds 更新）
// =============================================================================

/// 當前地圖可見範圍的矩形邊界（用於按視野拉取取景地）
class MapViewport {
  const MapViewport({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  final double south;
  final double west;
  final double north;
  final double east;
}

/// 持有當前視野；地圖創建/空閒時由 MapBody 調用 notifier.setBounds(...)
final mapViewportNotifierProvider =
    NotifierProvider<MapViewportNotifier, MapViewport?>(MapViewportNotifier.new);

class MapViewportNotifier extends Notifier<MapViewport?> {
  @override
  MapViewport? build() => null;

  void setBounds(double south, double west, double north, double east) {
    state = MapViewport(
      south: south,
      west: west,
      north: north,
      east: east,
    );
  }
}

// =============================================================================
// 2. 視野內取景地列表（依賴 mapViewportNotifierProvider，失敗/空則回退 Mock）
// =============================================================================

/// 當前視野內的取景地；視野為 null 時返回 Mock，便於首幀有數據
final locationsInViewportProvider =
    FutureProvider.autoDispose<List<LocationModel>>((ref) async {
  final viewport = ref.watch(mapViewportNotifierProvider);
  if (viewport == null) return LocationModel.mockLocations;

  try {
    final list = await LocationRepository.getLocationsInBounds(
      viewport.south,
      viewport.west,
      viewport.north,
      viewport.east,
    );
    return list.isEmpty ? LocationModel.mockLocations : list;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firestore/視野拉取失敗，使用 Mock: $e');
    }
    return LocationModel.mockLocations;
  }
});

// =============================================================================
// 3. 距你 xxx 米（core 共享，見上 export；BottomSheet 使用 ref.watch(distanceToLocationProvider(location))）
// =============================================================================

// =============================================================================
// 4. 導航（UI 調用 ref.read(openInMapsProvider)(location)）
// =============================================================================

/// 打開地圖 App 導航到取景地；返回函數供 ref.read 調用
final openInMapsProvider = Provider<void Function(LocationModel)>((ref) {
  return (LocationModel location) => openInMaps(location);
});
