import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/routing/app_routes.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/features/feed/feed_publish_payload.dart';
import 'package:filmtrace_hk/features/feed/providers/publish_post_notifier.dart';

String _formatPublishError(Object error) {
  if (error is FirebaseException) {
    final code = error.code.toLowerCase();
    if (code.contains('object-not-found')) {
      return '圖片已上傳但暫時無法取得下載連結，請數秒後再按「發布」重試。若仍失敗，請在 Firebase Console 確認已啟用 Storage，並執行 firebase deploy --only storage。';
    }
    if (code.contains('unauthorized')) {
      return '沒有權限寫入雲端儲存，請確認已登入且 Storage 規則已部署。';
    }
  }
  return error.toString();
}

/// PLAN_8 · 8.2：預覽拍立得、可選配文、提交至 Storage + Firestore。
class FeedPublishPage extends ConsumerStatefulWidget {
  const FeedPublishPage({super.key, this.payload});

  final FeedPublishPayload? payload;

  @override
  ConsumerState<FeedPublishPage> createState() => _FeedPublishPageState();
}

class _FeedPublishPageState extends ConsumerState<FeedPublishPage> {
  final _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(publishPostNotifierProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _submit(FeedPublishPayload p) async {
    final notifier = ref.read(publishPostNotifierProvider.notifier);
    final ok = await notifier.submit(
      localImagePath: p.imagePath,
      locationId: p.locationId,
      movieName: p.movieName,
      quote: p.quote,
      text: _captionController.text,
    );
    if (!mounted || !ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已發布'),
        backgroundColor: AppColors.primaryNeonCyan,
      ),
    );
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutePaths.feed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payload;
    final submitAsync = ref.watch(publishPostNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('發到影迷圈'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: p == null
          ? _MissingPayloadBody(onBack: () => context.pop())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PublishImagePreview(path: p.imagePath),
                    const SizedBox(height: 20),
                    _ReadOnlyInfoRow(
                      label: '影片',
                      value: p.movieName,
                    ),
                    const SizedBox(height: 8),
                    _ReadOnlyInfoRow(
                      label: '取景地',
                      value: p.locationLabel ??
                          (p.locationId == 'general' ? '自選打卡' : p.locationId),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _captionController,
                      maxLines: 3,
                      maxLength: 280,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.onPrimary,
                          ),
                      decoration: InputDecoration(
                        labelText: '配文（可選）',
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: AppColors.surfaceDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    if (submitAsync.hasError) ...[
                      const SizedBox(height: 12),
                      Text(
                        _formatPublishError(submitAsync.error!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryNeonRed,
                            ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: submitAsync.isLoading
                          ? null
                          : () => _submit(p),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryNeonCyan,
                        foregroundColor: AppColors.scaffoldBackground,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: submitAsync.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.scaffoldBackground,
                              ),
                            )
                          : const Text('發布'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _MissingPayloadBody extends StatelessWidget {
  const _MissingPayloadBody({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '無法打開發帖頁，請從分享頁重新進入。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.hintText,
                  ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onBack,
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublishImagePreview extends StatelessWidget {
  const _PublishImagePreview({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ReadOnlyInfoRow extends StatelessWidget {
  const _ReadOnlyInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.hintText,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onPrimary,
                ),
          ),
        ),
      ],
    );
  }
}
