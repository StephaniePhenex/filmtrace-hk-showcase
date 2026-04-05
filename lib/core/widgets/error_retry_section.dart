import 'package:flutter/material.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';

/// 網絡/Firestore 加載失敗時的統一展示：圖標 + 提示文案 + 重試按鈕（階段 6.3）
class ErrorRetrySection extends StatelessWidget {
  const ErrorRetrySection({
    super.key,
    required this.message,
    required this.onRetry,
    this.subMessage,
    this.icon,
    this.compact = false,
  });

  final String message;
  final VoidCallback onRetry;
  final String? subMessage;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = icon ?? Icons.cloud_off_outlined;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              effectiveIcon,
              size: compact ? 40 : 56,
              color: AppColors.placeholderIcon,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.bodyText,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                subMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.hintText,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('重試'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryNeonCyan,
                foregroundColor: AppColors.scaffoldBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
