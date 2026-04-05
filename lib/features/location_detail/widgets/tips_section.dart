import 'package:flutter/material.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';

/// 打卡貼士區塊（MVP 占位）
class TipsSection extends StatelessWidget {
  const TipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '打卡貼士',
            style: AppTextStyles.movieSubtitle(context),
          ),
          const SizedBox(height: 8),
          Text(
            '請在取景地 200 米內點擊下方「到此打卡」按鈕完成打卡。',
            style: AppTextStyles.body(context),
          ),
        ],
      ),
    );
  }
}
