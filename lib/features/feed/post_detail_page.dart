import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/routing/app_routes.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/features/feed/providers/feed_providers.dart';
import 'package:filmtrace_hk/features/feed/widgets/feed_post_card.dart';
import 'package:filmtrace_hk/features/feed/widgets/post_comments_section.dart';

/// PLAN_8 · 8.3：大圖詳情、取景地 `/location/:id`、作者區 `/profile/:uid`（卡片內）。
class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItem = ref.watch(postDetailFeedItemProvider(postId));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('帖子'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: asyncItem.when(
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (_, __) => Center(
          child: Text(
            '加載失敗',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.hintText,
                ),
          ),
        ),
        data: (item) {
          if (item == null) {
            return Center(
              child: Text(
                '帖子不存在或已刪除',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.hintText,
                    ),
              ),
            );
          }
          final canOpenLocation =
              feedPostLocationIsNavigable(item.post.locationId);
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              FeedPostCard(
                item: item,
                detailLayout: true,
                loginRedirectPath: AppLocations.feedPost(postId),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: canOpenLocation
                          ? () => context.push(
                                AppLocations.location(item.post.locationId),
                              )
                          : null,
                      icon: const Icon(Icons.place_outlined, size: 20),
                      label: const Text('查看取景地'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryNeonCyan,
                        foregroundColor: AppColors.scaffoldBackground,
                        disabledBackgroundColor: AppColors.surfaceDark,
                        disabledForegroundColor: AppColors.hintText,
                      ),
                    ),
                    if (!canOpenLocation) ...[
                      const SizedBox(height: 8),
                      Text(
                        '此帖為自選打卡，未關聯取景地地圖條目。',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.hintText,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              PostCommentsSection(postId: postId),
            ],
          );
        },
      ),
    );
  }
}
