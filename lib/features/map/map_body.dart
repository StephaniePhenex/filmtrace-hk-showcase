import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/features/map/data/location_model.dart';
import 'package:filmtrace_hk/features/map/widgets/map_bottom_hint.dart';
import 'package:filmtrace_hk/features/map/widgets/zoom_controls.dart';
import 'package:filmtrace_hk/features/map/location_bottom_sheet.dart';
import 'package:filmtrace_hk/features/map/providers/location_providers.dart';

/// 香港中心（中環一帶），用於初始鏡頭；zoom 11 可一次看到五個取景地（含石澳）
const double _hkCenterLng = 114.17;
const double _hkCenterLat = 22.28;
const double _hkZoom = 11.0;

/// 地圖 zoom 邊界（與 setBounds 一致）
const double _minZoom = 8.0;
const double _maxZoom = 20.0;
const double _zoomStep = 1.0;

/// 1.1 地圖樣式：目前為內建 Dark。在 Mapbox Studio 建立自定義 style 後，改為你的 Style URL（見 MAPBOX_STYLE.md）。
const String _kMapboxStyleUri = MapboxStyles.DARK;

/// Mapbox 地圖本體：暗黑風格、場記板 Marker、點擊彈出資訊卡。
/// 數據來自 locationsInViewportProvider；視野由 onMapCreated/onMapIdle 更新 mapViewportNotifierProvider。
class MapBody extends ConsumerStatefulWidget {
  const MapBody({super.key});

  @override
  ConsumerState<MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends ConsumerState<MapBody> {
  /// 與 AppShell 的相機權限請求錯開，避免 `permission_handler` 同時進行兩次 request。
  static Future<PermissionStatus>? _locationPermissionRequestInFlight;

  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  final Map<String, LocationModel> _annotationIdToLocation = {};
  /// 當前已顯示的取景地 id 列表（排序後），用於與新列表比較，一致則不重畫
  List<String>? _lastDisplayedLocationIds;

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    if (kDebugMode) debugPrint('Mapbox onMapCreated: 地图已创建');
    mapboxMap.setBounds(CameraBoundsOptions(minZoom: 8.0, maxZoom: 20.0));
    mapboxMap.gestures.updateSettings(GesturesSettings(
      pinchToZoomEnabled: true,
      scrollEnabled: true,
      doubleTapToZoomInEnabled: true,
      doubleTouchToZoomOutEnabled: true,
    ));
    mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    _updateViewportFromMap();
    unawaited(_enableUserLocationIfGranted());
  }

  /// 從當前地圖取得視野並更新 Provider，觸發 locationsInViewportProvider 拉取
  Future<void> _updateViewportFromMap() async {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;
    final state = await mapboxMap.getCameraState();
    final bounds = await mapboxMap.coordinateBoundsForCamera(state.toCameraOptions());
    if (bounds.infiniteBounds) return; // 保持 viewport null，Provider 返回 Mock
    ref.read(mapViewportNotifierProvider.notifier).setBounds(
          bounds.southwest.coordinates.lat.toDouble(),
          bounds.southwest.coordinates.lng.toDouble(),
          bounds.northeast.coordinates.lat.toDouble(),
          bounds.northeast.coordinates.lng.toDouble(),
        );
  }

  Future<void> _enableUserLocationIfGranted([int attempt = 0]) async {
    final map = _mapboxMap;
    if (map == null) return;
    try {
      var status = await Permission.locationWhenInUse.status;
      if (!status.isGranted) {
        _locationPermissionRequestInFlight ??=
            Permission.locationWhenInUse.request().whenComplete(() {
          _locationPermissionRequestInFlight = null;
        });
        status = await _locationPermissionRequestInFlight!;
      }
      if (!mounted || !status.isGranted) return;
      await map.location.updateSettings(
        LocationComponentSettings(enabled: true),
      );
    } on PlatformException catch (e) {
      if (e.code == 'ERROR_ALREADY_REQUESTING_PERMISSIONS' &&
          attempt < 5 &&
          mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await _enableUserLocationIfGranted(attempt + 1);
      }
    }
  }

  Future<Uint8List> _createMarkerIconBytes() async {
    const double size = 32;
    const double radius = 14;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      radius,
      Paint()..color = AppColors.primaryNeonRed,
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _addLocationMarkers(List<LocationModel> locations) async {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    PointAnnotationManager manager;
    if (_pointAnnotationManager != null) {
      manager = _pointAnnotationManager!;
      await manager.deleteAll();
      _annotationIdToLocation.clear();
    } else {
      manager = await mapboxMap.annotations.createPointAnnotationManager();
      _pointAnnotationManager = manager;
      manager.tapEvents(onTap: (annotation) {
        if (!mounted) return;
        final location = _annotationIdToLocation[annotation.id];
        if (location != null) showLocationBottomSheet(context, location);
      });
    }

    final Uint8List iconBytes = await _createMarkerIconBytes();
    final options = locations
        .map(
          (loc) => PointAnnotationOptions(
            geometry: Point(coordinates: Position(loc.lng, loc.lat)),
            image: iconBytes,
            iconSize: 1.5,
          ),
        )
        .toList();

    final created = await manager.createMulti(options);
    if (kDebugMode) debugPrint('1.4 视野内取景地: ${created.length} 个');

    if (!mounted) return;
    for (var i = 0; i < created.length && i < locations.length; i++) {
      final annotation = created[i];
      if (annotation != null) {
        _annotationIdToLocation[annotation.id] = locations[i];
      }
    }
    final ids = locations.map((e) => e.id).toList()..sort();
    _lastDisplayedLocationIds = ids;
  }

  Future<void> _zoomIn() async {
    final map = _mapboxMap;
    if (map == null) return;
    final state = await map.getCameraState();
    final newZoom = (state.zoom + _zoomStep).clamp(_minZoom, _maxZoom);
    await map.setCamera(CameraOptions(center: state.center, zoom: newZoom));
  }

  Future<void> _zoomOut() async {
    final map = _mapboxMap;
    if (map == null) return;
    final state = await map.getCameraState();
    final newZoom = (state.zoom - _zoomStep).clamp(_minZoom, _maxZoom);
    await map.setCamera(CameraOptions(center: state.center, zoom: newZoom));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(locationsInViewportProvider, (prev, next) {
      next.whenData((locations) {
        if (_mapboxMap == null) return;
        final newIds = locations.map((e) => e.id).toList()..sort();
        if (listEquals(newIds, _lastDisplayedLocationIds)) return;
        _addLocationMarkers(locations);
      });
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: MapWidget(
            key: const ValueKey('filmtrace_map'),
            styleUri: _kMapboxStyleUri,
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(_hkCenterLng, _hkCenterLat)),
              zoom: _hkZoom,
            ),
            onMapCreated: _onMapCreated,
            onMapIdleListener: (_) => _updateViewportFromMap(),
            onMapLoadErrorListener: (eventData) {
              debugPrint('Mapbox load error: type=${eventData.type} message=${eventData.message}');
            },
          ),
        ),
        const MapBottomHint(text: '香港 · 5 个电影取景地 · 点红色标记查看'),
        Positioned(
          right: 12,
          top: 0,
          bottom: 0,
          child: Center(
            child: ZoomControls(
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
            ),
          ),
        ),
      ],
    );
  }
}
