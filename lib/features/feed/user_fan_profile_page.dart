import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/auth/auth_provider.dart';
import 'package:filmtrace_hk/core/routing/app_routes.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';
import 'package:filmtrace_hk/features/feed/providers/feed_providers.dart';
import 'package:filmtrace_hk/features/feed/providers/follow_interaction_provider.dart';
import 'package:filmtrace_hk/features/feed/widgets/feed_post_card.dart';

/// PLAN_8 · 8.5：`/profile/:uid` 頭像、關注/粉絲、帖子列表、關注按鈕。
class UserFanProfilePage extends ConsumerWidget {
  const UserFanProfilePage({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(uid));
    final statsAsync = ref.watch(userFollowStatsProvider(uid));
    final postsAsync = ref.watch(userPostsProvider(uid));
    final selfAsync = ref.watch(currentUserProvider);
    final isSelf = selfAsync.valueOrNull?.uid == uid;
    final loggedIn = selfAsync.valueOrNull != null;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('影迷資料'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: profileAsync.when(
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
        data: (profile) {
          final name = profile?.displayName ?? uid;
          final avatarUrl = profile?.avatarUrl?.trim();
          return RefreshIndicator(
            color: AppColors.primaryNeonCyan,
            onRefresh: () async {
              ref.invalidate(userProfileProvider(uid));
              ref.invalidate(userFollowStatsProvider(uid));
              ref.invalidate(userPostsProvider(uid));
              if (!isSelf && loggedIn) {
                ref.invalidate(followRelationshipProvider(uid));
              }
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                _ProfileAvatar(name: name, avatarUrl: avatarUrl),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.onPrimary,
                      ),
                ),
                const SizedBox(height: 12),
                statsAsync.when(
                  loading: () => const SizedBox(
                    height: 20,
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (s) => Text(
                    '關注 ${s.following}　·　粉絲 ${s.followers}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.hintText,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                if (isSelf) ...[
                  Text(
                    '我的影迷圈',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primaryNeonCyan,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '在「影迷圈」發帖、瀏覽關注動態；點 AppBar 人像可回到此頁。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.bodyText,
                        ),
                  ),
                ] else
                  _FollowActionRow(
                    targetUid: uid,
                    redirectPath: '/profile/$uid',
                  ),
                const SizedBox(height: 20),
                Text(
                  '打卡動態',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryNeonCyan,
                      ),
                ),
                const SizedBox(height: 8),
                postsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (_, __) => Text(
                    '帖子加載失敗',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.hintText,
                        ),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return Text(
                        '暫無打卡帖',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.hintText,
                            ),
                      );
                    }
                    return Column(
                      children: items
                          .map(
                            (item) => FeedPostCard(
                              item: item,
                              loginRedirectPath:
                                  AppLocations.feedPost(item.post.id),
                              onTap: () => context.push(
                                AppLocations.feedPost(item.post.id),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name, required this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final initial =
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 44,
        backgroundColor: AppColors.surfaceDark,
        child: ClipOval(
          child: Image.network(
            avatarUrl!,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _letterFallback(initial),
          ),
        ),
      );
    }
    return _letterFallback(initial);
  }

  Widget _letterFallback(String initial) {
    return CircleAvatar(
      radius: 44,
      backgroundColor: AppColors.surfaceDark,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 32,
          color: AppColors.primaryNeonCyan,
        ),
      ),
    );
  }
}

class _FollowActionRow extends ConsumerWidget {
  const _FollowActionRow({
    required this.targetUid,
    required this.redirectPath,
  });

  final String targetUid;
  final String redirectPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserProvider).valueOrNull;
    if (me == null) {
      return OutlinedButton.icon(
        onPressed: () => context.push(
          AppLocations.loginRedirect(redirectPath),
        ),
        icon: const Icon(Icons.person_add_outlined, size: 20),
        label: const Text('登錄後關注'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryNeonCyan,
          side: const BorderSide(color: AppColors.primaryNeonCyan),
        ),
      );
    }

    final followingAsync = ref.watch(followRelationshipProvider(targetUid));

    return followingAsync.when(
      loading: () => const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (following) {
        if (following) {
          return OutlinedButton(
            onPressed: () => _confirmUnfollow(context, ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.hintText,
              side: const BorderSide(color: AppColors.divider),
            ),
            child: const Text('已關注 · 點擊取關'),
          );
        }
        return FilledButton.icon(
          onPressed: () => _doFollow(context, ref),
          icon: const Icon(Icons.person_add_outlined, size: 20),
          label: const Text('關注'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accentGold,
            foregroundColor: AppColors.scaffoldBackground,
          ),
        );
      },
    );
  }

  Future<void> _doFollow(BuildContext context, WidgetRef ref) async {
    final err = await ref.read(followInteractionProvider).follow(targetUid);
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

  Future<void> _confirmUnfollow(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          '取消關注？',
          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                color: AppColors.onPrimary,
              ),
        ),
        content: Text(
          '不再在「關注」流中看到對方的動態。',
          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                color: AppColors.bodyText,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('保留'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '取關',
              style: AppTextStyles.destructive,
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final err = await ref.read(followInteractionProvider).unfollow(targetUid);
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
}
