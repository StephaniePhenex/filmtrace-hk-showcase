import 'package:flutter/material.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';

/// 地圖右側縮放按鈕列（+ / −），用於 MapBody 浮層。
class ZoomControls extends StatelessWidget {
  const ZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.zoomBarBackground,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomButton(
            symbol: '+',
            color: AppColors.zoomInCyan,
            onTap: onZoomIn,
          ),
          Container(
            height: 1,
            width: 32,
            color: AppColors.divider,
          ),
          _ZoomButton(
            symbol: '−',
            color: AppColors.zoomOutRed,
            onTap: onZoomOut,
          ),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.symbol,
    required this.color,
    required this.onTap,
  });

  final String symbol;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Text(
          symbol,
          style: AppTextStyles.zoomButton(color),
        ),
      ),
    );
  }
}
