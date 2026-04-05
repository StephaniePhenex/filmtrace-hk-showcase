import 'package:flutter/material.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';

/// 劇情簡介區塊（MVP 占位）
class PlotSection extends StatelessWidget {
  const PlotSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '劇情簡介',
            style: AppTextStyles.movieSubtitle(context),
          ),
          const SizedBox(height: 8),
          Text(
            '本場景在電影中為重要取景地，親臨現場可感受電影氛圍。（占位）',
            style: AppTextStyles.body(context),
          ),
        ],
      ),
    );
  }
}
