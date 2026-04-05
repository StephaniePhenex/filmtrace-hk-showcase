import 'package:flutter/material.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';

/// 經典台詞區塊（使用 quote，大號字體）
class QuoteSection extends StatelessWidget {
  const QuoteSection({super.key, this.quote});

  final String? quote;

  @override
  Widget build(BuildContext context) {
    if (quote == null || quote!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          '暫無台詞',
          style: AppTextStyles.hint(context),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Text(
        '"$quote"',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primaryNeonCyan,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
      ),
    );
  }
}
