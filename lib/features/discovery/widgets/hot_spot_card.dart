import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/constants/local_stills.dart';
import 'package:filmtrace_hk/core/data/location_model.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';

/// 本周熱門聖地橫向列表用卡片：劇照縮圖、名稱、電影名；點擊跳轉詳情頁。
class HotSpotCard extends StatelessWidget {
  const HotSpotCard({
    super.key,
    required this.location,
  });

  final LocationModel location;

  static const double cardWidth = 160;
  static const double stillAspectRatio = 4 / 3;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: SizedBox(
        width: cardWidth,
        child: Material(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/location/${location.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: stillAspectRatio,
                  child: _StillImage(locationId: location.id, stillUrl: location.stillUrl),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        location.name,
                        style: AppTextStyles.locationTitle(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '《${location.movieName}》',
                        style: AppTextStyles.movieSubtitle(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StillImage extends StatelessWidget {
  const _StillImage({required this.locationId, this.stillUrl});

  final String locationId;
  final String? stillUrl;

  static Widget _placeholder() => const ColoredBox(
        color: AppColors.placeholderBackground,
        child: Center(
          child: Icon(
            Icons.movie_outlined,
            size: 40,
            color: AppColors.placeholderIcon,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (localStills.containsKey(locationId)) {
      return Image.asset(
        localStills[locationId]!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    final url = stillUrl?.trim();
    if (url == null || url.isEmpty) return _placeholder();
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const ColoredBox(
          color: AppColors.placeholderBackground,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }
}
