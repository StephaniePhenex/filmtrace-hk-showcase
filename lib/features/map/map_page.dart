import 'package:flutter/material.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/features/map/map_body.dart';

/// 片場地圖 - 首頁/探索，LBS 取景地圖標
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _MapPageContent(),
      ),
    );
  }
}

class _MapPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS;
    if (!isMobile) {
      return const _MapPlaceholder();
    }
    return const MapBody();
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: AppColors.primaryNeonRed),
            const SizedBox(height: 16),
            Text(
              '片場地圖',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              '請在 iOS 或 Android 裝置／模擬器上開啟以查看地圖。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '運行時請設定 Mapbox Token：\nflutter run --dart-define=MAPBOX_ACCESS_TOKEN=你的token',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
