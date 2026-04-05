import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';
import 'package:filmtrace_hk/features/discovery/data/preset_routes.dart';

/// 經典路線速覽列表項：路線名稱、描述/地點數；點擊進入路線詳情頁。
class RouteListTile extends StatelessWidget {
  const RouteListTile({
    super.key,
    required this.route,
  });

  final PresetRoute route;

  @override
  Widget build(BuildContext context) {
    final locationCount = route.locationIds.length;
    final subtitle = '${route.description} · $locationCount個取景地';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/route/${route.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.route,
                  color: AppColors.primaryNeonCyan,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        route.name,
                        style: AppTextStyles.locationTitle(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.hint(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.hintText,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
