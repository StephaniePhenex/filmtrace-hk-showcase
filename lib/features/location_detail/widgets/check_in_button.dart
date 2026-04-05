import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/data/location_model.dart';
import 'package:filmtrace_hk/core/providers/location_distance_provider.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';
import 'package:filmtrace_hk/features/location_detail/providers/location_detail_providers.dart';

/// 底部 200m 打卡按鈕：依 canCheckInProvider 可點擊/置灰，置灰時顯示距離或「靠近後可打卡」
class CheckInButton extends ConsumerWidget {
  const CheckInButton({
    super.key,
    required this.locationId,
    required this.location,
  });

  final String locationId;
  final LocationModel location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCheckInAsync = ref.watch(canCheckInProvider(locationId));
    final distanceAsync = ref.watch(distanceToLocationProvider(location));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            canCheckInAsync.when(
              data: (canCheckIn) {
                final enabled = canCheckIn;
                String subtitle = '';
                if (!enabled) {
                  subtitle = distanceAsync.when(
                    data: (d) => d.replaceFirst('距你', '距打卡點'),
                    loading: () => '靠近後可打卡',
                    error: (_, __) => '靠近後可打卡',
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (subtitle.isNotEmpty) ...[
                      Text(subtitle, style: AppTextStyles.hint(context)),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: enabled
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('打卡成功'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                context.pop();
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: enabled
                              ? AppColors.primaryNeonRed
                              : AppColors.bodyText,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('到此打卡'),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) =>
                  Text('無法取得打卡狀態', style: AppTextStyles.hint(context)),
            ),
          ],
        ),
      ),
    );
  }
}
