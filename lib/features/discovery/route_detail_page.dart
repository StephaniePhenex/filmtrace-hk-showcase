import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/data/location_model.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';
import 'package:filmtrace_hk/core/widgets/error_retry_section.dart';
import 'package:filmtrace_hk/features/discovery/providers/discovery_providers.dart';

/// 路線詳情頁：展示路線名稱、描述與各站點列表，點擊站點進入該站詳情。
class RouteDetailPage extends ConsumerWidget {
  const RouteDetailPage({super.key, required this.routeId});

  final String routeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routeDetailProvider(routeId));
    final asyncStops = ref.watch(routeStopsProvider(routeId));

    if (route == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('路線'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('未找到該路線', style: AppTextStyles.body(context)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          route.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryNeonCyan,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: asyncStops.when(
        data: (stops) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.description,
                  style: AppTextStyles.body(context),
                ),
                const SizedBox(height: 24),
                Text(
                  '路線站點',
                  style: AppTextStyles.locationTitle(context),
                ),
                const SizedBox(height: 12),
                if (stops.isEmpty)
                  Text(
                    '暫無站點資料',
                    style: AppTextStyles.hint(context),
                  )
                else
                  ...stops.asMap().entries.map((e) => _StopTile(
                        index: e.key + 1,
                        location: e.value,
                      )),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ErrorRetrySection(
                message: '網絡不穩，無法加載路線站點',
                subMessage: '請檢查網路後重試',
                onRetry: () => ref.invalidate(routeStopsProvider(routeId)),
                compact: true,
              ),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StopTile extends StatelessWidget {
  const _StopTile({
    required this.index,
    required this.location,
  });

  final int index;
  final LocationModel location;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/location/${location.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryNeonCyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$index',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primaryNeonCyan,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        location.name,
                        style: AppTextStyles.locationTitle(context),
                        maxLines: 1,
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
