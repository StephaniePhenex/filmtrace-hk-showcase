import 'dart:convert';
import 'dart:typed_data';

/// 場記板圖標：最小可用 PNG（1x1），供 Mapbox PointAnnotation 使用。
/// 可替換為 assets/icons/clapperboard.png 並用 rootBundle.load 載入。
const String _kMarkerPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

Uint8List get markerIconBytes => base64Decode(_kMarkerPngBase64);
