import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/data/location_model.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';
import 'package:filmtrace_hk/core/widgets/error_retry_section.dart';
import 'package:filmtrace_hk/features/discovery/providers/discovery_providers.dart';
import 'package:filmtrace_hk/features/discovery/widgets/person_list_tile.dart';
import 'package:filmtrace_hk/features/location_detail/providers/location_detail_providers.dart';
import 'package:filmtrace_hk/features/location_detail/widgets/check_in_button.dart';
import 'package:filmtrace_hk/features/location_detail/widgets/detail_app_bar.dart';
import 'package:filmtrace_hk/features/location_detail/widgets/plot_section.dart';
import 'package:filmtrace_hk/features/location_detail/widgets/quote_section.dart';
import 'package:filmtrace_hk/features/location_detail/widgets/tips_section.dart';

/// 地點詳情頁（階段 2.2：沉浸式頭部 + 台詞/簡介/貼士 + 200m 打卡按鈕）
class LocationDetailPage extends ConsumerWidget {
  const LocationDetailPage({super.key, required this.locationId});

  final String locationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLocation = ref.watch(locationDetailProvider(locationId));

    return Scaffold(
      body: asyncLocation.when(
        data: (location) {
          if (location == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '未找到該取景地',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('返回'),
                  ),
                ],
              ),
            );
          }
          return _DetailBody(locationId: locationId, location: location);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ErrorRetrySection(
              message: '網絡不穩或取景地資料暫時無法加載',
              subMessage: '請檢查網路後重試',
              onRetry: () =>
                  ref.invalidate(locationDetailProvider(locationId)),
            ),
            TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryNeonCyan,
              ),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 詳情主體：CustomScrollView + 頭部 / 台詞·簡介·貼士 / 底部按鈕
class _DetailBody extends ConsumerWidget {
  const _DetailBody({
    required this.locationId,
    required this.location,
  });

  final String locationId;
  final LocationModel location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        buildDetailAppBar(context, location, () => context.pop()),
        SliverToBoxAdapter(
          child: QuoteSection(quote: location.quote),
        ),
        const SliverToBoxAdapter(
          child: PlotSection(),
        ),
        const SliverToBoxAdapter(
          child: TipsSection(),
        ),
        SliverToBoxAdapter(
          child: _RelatedPeopleSection(locationId: locationId),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/camera/$locationId'),
                    icon: const Icon(Icons.camera_alt_outlined, size: 20),
                    label: const Text('名場面打卡'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryNeonCyan,
                      side: const BorderSide(color: AppColors.primaryNeonCyan),
                    ),
                  ),
                ),
              ),
              CheckInButton(
                locationId: locationId,
                location: location,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 相關影人：該打卡地關聯的影人列表，點擊進影人詳情。
class _RelatedPeopleSection extends ConsumerWidget {
  const _RelatedPeopleSection({required this.locationId});

  final String locationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleAtLocationProvider(locationId));
    if (people.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '相關影人',
            style: AppTextStyles.locationTitle(context),
          ),
          const SizedBox(height: 12),
          ...people.map((p) => PersonListTile(person: p)),
        ],
      ),
    );
  }
}
