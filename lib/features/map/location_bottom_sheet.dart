import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/features/map/data/location_model.dart';
import 'package:filmtrace_hk/features/map/providers/location_providers.dart';
import 'package:filmtrace_hk/features/map/widgets/location_card_content.dart';

/// 點擊地圖 Marker 後彈出的取景地簡略資訊卡。
/// 卡片內容由 LocationCardContent 提供，距離與導航由 Provider 提供。
/// 階段 2.3：跳轉詳情使用外層 context（navigatorContext）做 push，以使用根 Navigator，與 app_router 的 parentNavigatorKey 一致。
void showLocationBottomSheet(BuildContext context, LocationModel location) {
  final navigatorContext = context;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
      builder: (sheetContext) {
        final sheetHeight = MediaQuery.of(sheetContext).size.height * 0.62;
        return Consumer(
          builder: (_, ref, __) {
            return SafeArea(
              child: SizedBox(
                height: sheetHeight,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.divider,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(sheetContext),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.overlayBackground.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.hintText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: LocationCardContent(
                            location: location,
                            onStillTap: () {
                              Navigator.pop(sheetContext);
                              navigatorContext.push('/location/${location.id}');
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            navigatorContext.push('/camera/${location.id}');
                          },
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: const Text('名場面打卡'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryNeonCyan,
                            side: const BorderSide(color: AppColors.primaryNeonCyan),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            minimumSize: const Size(0, 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.pop(sheetContext);
                                ref.read(openInMapsProvider)(location);
                              },
                              icon: const Icon(Icons.directions, size: 18),
                              label: const Text('導航'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primaryNeonRed,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                minimumSize: const Size(0, 40),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(sheetContext);
                                navigatorContext.push('/location/${location.id}');
                              },
                              icon: const Icon(Icons.info_outline, size: 18),
                              label: const Text('查看詳情'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryNeonCyan,
                                side: const BorderSide(color: AppColors.primaryNeonCyan),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                minimumSize: const Size(0, 40),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
