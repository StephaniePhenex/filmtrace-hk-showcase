import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmtrace_hk/core/constants/local_stills.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/features/map/data/location_model.dart';
import 'package:filmtrace_hk/features/map/providers/location_providers.dart';

/// 取景地卡片內容：劇照、距離、標題、電影名、台詞。供 BottomSheet 與未來收藏列表等複用。
class LocationCardContent extends ConsumerWidget {
  const LocationCardContent({
    super.key,
    required this.location,
    this.onStillTap,
    this.maxStillHeight,
  });

  final LocationModel location;
  /// 點擊劇照時回調（如跳轉詳情頁）；為 null 時劇照不可點擊。
  final VoidCallback? onStillTap;
  /// 劇照區域最大高度（如卡片內用於留出空間給下方文字）；null 則不限制。
  final double? maxStillHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LocationStillArea(
          locationId: location.id,
          stillUrl: location.stillUrl,
          onTap: onStillTap,
          maxHeight: maxStillHeight,
        ),
        const SizedBox(height: 6),
        _DistanceToLocation(location: location),
        const SizedBox(height: 4),
        Text(
          location.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryNeonCyan,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          '《${location.movieName}》',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.hintText,
              ),
        ),
        if (location.quote != null && location.quote!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            location.quote!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.bodyText,
                ),
          ),
        ],
        const SizedBox(height: 4),
      ],
    );
  }
}

/// 距你 xxx 米：僅監聽 distanceToLocationProvider，無業務邏輯
class _DistanceToLocation extends ConsumerWidget {
  const _DistanceToLocation({required this.location});

  final LocationModel location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDistance = ref.watch(distanceToLocationProvider(location));
    final smallStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.bodyText,
      fontSize: 12,
    );
    return asyncDistance.when(
      data: (text) => Text(text, style: smallStyle),
      loading: () => Text('距你 -- 米', style: smallStyle),
      error: (_, __) => Text('距你 -- 米', style: smallStyle),
    );
  }
}

/// 劇照區域：有 stillUrl 則顯示網路圖（含加載/失敗），否則顯示占位。比例 4:3，僅上圓角。可選 onTap。
/// 若 locationId 在 localStills 中則優先使用本地 asset。
class _LocationStillArea extends StatelessWidget {
  const _LocationStillArea({
    required this.locationId,
    this.stillUrl,
    this.onTap,
    this.maxHeight,
  });

  final String locationId;
  final String? stillUrl;
  final VoidCallback? onTap;
  final double? maxHeight;

  static const double _aspectRatio = 4 / 3;

  @override
  Widget build(BuildContext context) {
    Widget content = AspectRatio(
      aspectRatio: _aspectRatio,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: _buildContent(context),
      ),
    );
    if (maxHeight != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight!),
        child: content,
      );
    }
    if (onTap == null) return content;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }

  Widget _buildContent(BuildContext context) {
    if (localStills.containsKey(locationId)) {
      return Image.asset(
        localStills[locationId]!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _buildPlaceholder(context),
      );
    }
    final url = stillUrl?.trim();
    if (url == null || url.isEmpty) {
      return _buildPlaceholder(context);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppColors.placeholderBackground,
          child: const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: AppColors.placeholderBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
                Icons.movie_outlined, size: 40, color: AppColors.placeholderIcon),
            const SizedBox(height: 8),
            Text(
              '暫無劇照',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.placeholderIcon,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
