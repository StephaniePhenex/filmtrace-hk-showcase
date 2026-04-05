import 'package:flutter/material.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';

/// 地圖底部浮層提示條（如「香港 · 5 个电影取景地 · 点红色标记查看」）。
class MapBottomHint extends StatelessWidget {
  const MapBottomHint({
    super.key,
    required this.text,
    this.left = 12,
    this.right = 12,
    this.bottom = 24,
  });

  final String text;
  final double left;
  final double right;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.overlayBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.hintText,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
