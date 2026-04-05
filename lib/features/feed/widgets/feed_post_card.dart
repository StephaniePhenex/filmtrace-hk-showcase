import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/auth/auth_provider.dart';
import 'package:filmtrace_hk/core/routing/app_routes.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/features/feed/providers/feed_providers.dart';
import 'package:filmtrace_hk/features/feed/providers/post_interaction_provider.dart';

/// 是否可跳轉至 `/location/:id`（MVP：`general` 為自選打卡占位）。
bool feedPostLocationIsNavigable(String locationId) {
  return locationId.isNotEmpty && locationId != 'general';
}

/// 列表/詳情共用卡片（PLAN_8 · 8.1 / 8.3 / 8.4）。
class FeedPostCard extends ConsumerWidget {
  const FeedPostCard({
    super.key,
    required this.item,
    this.onTap,
    this.detailLayout = false,
    this.loginRedirectPath,
  });

  final FeedPostItem item;
  final VoidCallback? onTap;
  final bool detailLayout;
  /// 未登錄點贊時 `redirect`；默認 `/feed`。
  final String? loginRedirectPath;

  Future<void> _onLikePressed(BuildContext context, WidgetRef ref) async {
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) {
      final r = loginRedirectPath ?? AppRoutePaths.feed;
      await context.push(AppLocations.loginRedirect(r));
      return;
    }
    final err = await ref.read(postInteractionProvider).toggleLike(
          postId: item.post.id,
          currentlyLiked: item.likedByMe,
        );
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.primaryNeonRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = item.post;
    final authorName = item.author?.displayName ?? '影迷';
    final d = post.createdAt;
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final locationLine = feedPostLocationIsNavigable(post.locationId)
        ? post.locationId
        : '自選打卡';

    final image = _PostImageSection(
      imageUrl: post.imageUrl,
      aspectRatio: detailLayout ? 3 / 4 : 1,
      onTap: onTap,
    );

    return Card(
      color: AppColors.surfaceDark,
      margin: detailLayout
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          image,
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.movieName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryNeonCyan,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  locationLine,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.hintText,
                      ),
                ),
                if (post.quote != null && post.quote!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '「${post.quote!.trim()}」',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.bodyText,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
                if (post.text != null && post.text!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    post.text!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onPrimary,
                        ),
                  ),
                ],
                const SizedBox(height: 12),
                _AuthorMetaRow(
                  authorName: authorName,
                  avatarUrl: item.author?.avatarUrl,
                  userId: post.userId,
                  likedByMe: item.likedByMe,
                  likeCount: post.effectiveLikeCount,
                  dateStr: dateStr,
                  onLikeTap: () => _onLikePressed(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostImageSection extends StatelessWidget {
  const _PostImageSection({
    required this.imageUrl,
    required this.aspectRatio,
    this.onTap,
  });

  final String imageUrl;
  final double aspectRatio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = AspectRatio(
      aspectRatio: aspectRatio,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.placeholderIcon,
            size: 48,
          ),
        ),
      ),
    );
    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      child: child,
    );
  }
}

class _AuthorMetaRow extends StatelessWidget {
  const _AuthorMetaRow({
    required this.authorName,
    required this.avatarUrl,
    required this.userId,
    required this.likedByMe,
    required this.likeCount,
    required this.dateStr,
    required this.onLikeTap,
  });

  final String authorName;
  final String? avatarUrl;
  final String userId;
  final bool likedByMe;
  final int likeCount;
  final String dateStr;
  final VoidCallback onLikeTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => context.push('/profile/$userId'),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AuthorAvatar(
                  authorName: authorName,
                  avatarUrl: avatarUrl,
                ),
                const SizedBox(width: 8),
                Text(
                  authorName,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.bodyText,
                      ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: onLikeTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    likedByMe ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: likedByMe
                        ? AppColors.primaryNeonRed
                        : AppColors.hintText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$likeCount',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.hintText,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          dateStr,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.hintText,
              ),
        ),
      ],
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({
    required this.authorName,
    required this.avatarUrl,
  });

  final String authorName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final initial = authorName.isNotEmpty
        ? authorName.substring(0, 1).toUpperCase()
        : '?';
    final url = avatarUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _letterCircle(initial),
        ),
      );
    }
    return _letterCircle(initial);
  }

  Widget _letterCircle(String initial) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.placeholderBackground,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.primaryNeonCyan,
        ),
      ),
    );
  }
}
