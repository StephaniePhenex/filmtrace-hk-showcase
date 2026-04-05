import 'package:flutter/material.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';

/// 統一字體與字號，避免在 Widget 中硬編碼 fontSize / fontWeight。
/// 可與 Theme.of(context).textTheme 搭配使用，或直接引用。
class AppTextStyles {
  AppTextStyles._();

  /// 地圖縮放按鈕 + / −
  static TextStyle zoomButton(Color color) => TextStyle(
        color: color,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.0,
      );

  /// 底部提示、次要說明
  static TextStyle hint(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.hintText);

  /// 正文
  static TextStyle body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.bodyText);

  /// 標題（取景地名）
  static TextStyle locationTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(color: AppColors.primaryNeonCyan);

  /// 副標題（電影名）
  static TextStyle movieSubtitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(color: AppColors.hintText);

  /// 鏈接色文字（`TextButton` 等，影迷圈與登錄頁復用）。
  static const TextStyle linkCyan = TextStyle(color: AppColors.primaryNeonCyan);

  /// 警告/破壞性操作標籤（如取關確認）。
  static const TextStyle destructive = TextStyle(color: AppColors.primaryNeonRed);

  /// 空狀態與次要說明正文。
  static TextStyle emptyStateBody(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.hintText);
}
