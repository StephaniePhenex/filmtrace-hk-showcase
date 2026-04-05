import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:filmtrace_hk/features/map/data/location_model.dart';

/// 導航邏輯：優先 Google Maps App → Google 地圖網頁 → Apple 地圖。
/// 由 Provider 暴露，UI 僅調用 ref.read(openInMapsProvider)(location)。
Future<void> openInMaps(LocationModel location) async {
  final lat = location.lat;
  final lng = location.lng;
  final label = Uri.encodeComponent(location.name);

  final googleMapsAppUrl = Uri.parse(
    'comgooglemaps://?daddr=$lat,$lng&directionsmode=driving',
  );
  final googleMapsWebUrl = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
  );
  final appleMapsUrl = Uri.parse(
    'https://maps.apple.com/?q=$label&ll=$lat,$lng',
  );

  try {
    if (await canLaunchUrl(googleMapsAppUrl)) {
      await launchUrl(googleMapsAppUrl, mode: LaunchMode.externalApplication);
      return;
    }
  } catch (_) {}

  try {
    if (await canLaunchUrl(googleMapsWebUrl)) {
      await launchUrl(googleMapsWebUrl, mode: LaunchMode.externalApplication);
      return;
    }
  } catch (_) {}

  try {
    await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
  } catch (e) {
    if (kDebugMode) debugPrint('導航 打開失敗: $e');
  }
}
