import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/auth/auth_provider.dart';
import 'package:filmtrace_hk/core/routing/app_routes.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';
import 'package:filmtrace_hk/core/widgets/error_retry_section.dart';
import 'package:filmtrace_hk/features/feed/providers/feed_providers.dart';
import 'package:filmtrace_hk/features/feed/widgets/feed_post_card.dart';

/// PLAN_8 · 8.1：影迷圈首頁，`/feed`；「關注」流見 8.5。
class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 240) {
      ref.read(feedListControllerProvider.notifier).loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('影迷圈'),
        actions: [
          userAsync.when(
            data: (u) {
              if (u == null) {
                return IconButton(
                  tooltip: '登錄',
                  icon: const Icon(Icons.login),
                  onPressed: () => context.push(
                    AppLocations.loginRedirect(AppRoutePaths.feed),
                  ),
                );
              }
              return IconButton(
                tooltip: '我的',
                icon: const Icon(Icons.person_outline),
                onPressed: () => context.push(AppLocations.profile(u.uid)),
              );
            },
            loading: () => const SizedBox(width: 48),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryNeonCyan,
          labelColor: AppColors.primaryNeonCyan,
          unselectedLabelColor: AppColors.hintText,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '關注'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllFeed(context),
          _buildFollowingFeed(context),
        ],
      ),
    );
  }

  Widget _buildAllFeed(BuildContext context) {
    final asyncFeed = ref.watch(feedListControllerProvider);

    return asyncFeed.when(
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (e, _) => Center(
        child: ErrorRetrySection(
          message: '動態加載失敗',
          onRetry: () =>
              ref.read(feedListControllerProvider.notifier).refresh(),
        ),
      ),
      data: (state) {
        if (state.items.isEmpty) {
          return RefreshIndicator(
            color: AppColors.primaryNeonCyan,
            onRefresh: () =>
                ref.read(feedListControllerProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      '暫無動態\n打卡發帖後將顯示在這裡（見分享頁「發到影迷圈」）',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.hintText,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryNeonCyan,
          onRefresh: () =>
              ref.read(feedListControllerProvider.notifier).refresh(),
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final item = state.items[index];
                return FeedPostCard(
                  item: item,
                  onTap: () => context.push(AppLocations.feedPost(item.post.id)),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFollowingFeed(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 56,
                color: AppColors.hintText.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                '登錄後查看你關注的人的動態',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.hintText,
                    ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => context.push(
                  AppLocations.loginRedirect(AppRoutePaths.feed),
                ),
                child: const Text(
                  '去登錄',
                  style: AppTextStyles.linkCyan,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final asyncFollowing = ref.watch(followingFeedControllerProvider);

    return asyncFollowing.when(
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (e, _) => Center(
        child: ErrorRetrySection(
          message: '關注流加載失敗',
          onRetry: () =>
              ref.read(followingFeedControllerProvider.notifier).refresh(),
        ),
      ),
      data: (state) {
        if (state.items.isEmpty) {
          return RefreshIndicator(
            color: AppColors.primaryNeonCyan,
            onRefresh: () =>
                ref.read(followingFeedControllerProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      '暫無動態\n在「影迷資料」頁關注其他用戶後，對方新帖會出現在這裡',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.hintText,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryNeonCyan,
          onRefresh: () =>
              ref.read(followingFeedControllerProvider.notifier).refresh(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24, top: 8),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return FeedPostCard(
                item: item,
                loginRedirectPath: AppLocations.feedPost(item.post.id),
                onTap: () => context.push(AppLocations.feedPost(item.post.id)),
              );
            },
          ),
        );
      },
    );
  }
}
