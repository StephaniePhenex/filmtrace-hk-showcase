import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';
import 'package:filmtrace_hk/core/widgets/error_retry_section.dart';
import 'package:filmtrace_hk/features/discovery/providers/discovery_providers.dart';
import 'package:filmtrace_hk/features/discovery/widgets/hot_spot_card.dart';
import 'package:filmtrace_hk/features/discovery/widgets/movie_poster_card.dart';
import 'package:filmtrace_hk/features/discovery/widgets/person_avatar_tile.dart';
import 'package:filmtrace_hk/features/discovery/widgets/route_list_tile.dart';
import 'package:filmtrace_hk/features/discovery/widgets/search_result_tile.dart';

/// 光影檢索 — 發現頁：頂部搜索欄（參考豆瓣）+ TabBar（推薦 / 電影 / 影人）+ TabBarView
class DiscoveryPage extends ConsumerWidget {
  const DiscoveryPage({super.key});

  static const int _tabCount = 3;
  static const List<String> _tabLabels = ['推薦', '電影', '影人'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: _tabCount,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 搜索欄置於 Tab 上方，參考豆瓣首頁排版
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  onChanged: (v) =>
                      ref.read(searchQueryProvider.notifier).state = v,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.bodyText,
                      ),
                  decoration: InputDecoration(
                    hintText: '搜尋取景地、片名',
                    hintStyle: const TextStyle(color: AppColors.hintText),
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primaryNeonCyan),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.hintText,
                      size: 22,
                    ),
                  ),
                ),
              ),
              Material(
                color: AppColors.surfaceDark,
                child: TabBar(
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: AppColors.primaryNeonCyan,
                      width: 3,
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorPadding: EdgeInsets.zero,
                  labelColor: AppColors.primaryNeonCyan,
                  unselectedLabelColor: AppColors.hintText,
                  labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
                  tabs: _tabLabels
                      .map((label) => Tab(
                            child: SizedBox(
                              width: HotSpotCard.cardWidth,
                              child: Text(label, textAlign: TextAlign.center),
                            ),
                          ))
                      .toList(),
                ),
              ),
                const Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _RecommendTabContent(),
                    _MovieTabContent(),
                    _PersonTabContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 推薦 Tab：本周熱門聖地（橫向卡片）+ 經典路線速覽占位（3.3 實現）
class _RecommendTabContent extends ConsumerWidget {
  const _RecommendTabContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider).trim();
    final results = ref.watch(searchResultsProvider);
    final asyncLocations = ref.watch(discoveryLocationsProvider);
    final routes = ref.watch(presetRoutesProvider);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (query.isEmpty) ...[
              Text(
                '本周熱門聖地',
                style: AppTextStyles.locationTitle(context),
              ),
              const SizedBox(height: 12),
              asyncLocations.when(
              data: (locations) {
                if (locations.isEmpty) {
                  return Text(
                    '暫無取景地',
                    style: AppTextStyles.hint(context),
                  );
                }
                return SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: locations.length,
                    itemBuilder: (context, index) =>
                        HotSpotCard(location: locations[index]),
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ErrorRetrySection(
                  message: '網絡不穩，無法加載熱門取景地',
                  subMessage: '請檢查網路後重試',
                  onRetry: () =>
                      ref.invalidate(discoveryLocationsProvider),
                  compact: true,
                ),
              ),
            ),
              const SizedBox(height: 24),
              Text(
                '經典路線速覽',
                style: AppTextStyles.movieSubtitle(context),
              ),
              const SizedBox(height: 12),
              if (routes.isEmpty)
                Text(
                  '暫無路線',
                  style: AppTextStyles.hint(context),
                )
              else
                ...routes.map((route) => RouteListTile(route: route)),
            ] else ...[
              Text(
                '搜索結果',
                style: AppTextStyles.movieSubtitle(context),
              ),
              const SizedBox(height: 12),
              if (results.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      '無符合「$query」的取景地或片名',
                      style: AppTextStyles.hint(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...results.map((loc) => SearchResultTile(location: loc)),
            ],
            const SizedBox(height: 24),
          ],
        ),
      );
  }
}

/// 電影 Tab：縱向兩列網格，緊湊排列，點擊進電影詳情。
class _MovieTabContent extends ConsumerWidget {
  const _MovieTabContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMovies = ref.watch(discoveryMoviesProvider);
    return asyncMovies.when(
      data: (movies) {
        if (movies.isEmpty) {
          return Center(
            child: Text(
              '暫無電影',
              style: AppTextStyles.hint(context),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.54,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) =>
              MoviePosterCard(item: movies[index]),
        );
      },
      loading: () => const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => ErrorRetrySection(
        message: '網絡不穩，無法加載電影列表',
        subMessage: '請檢查網路後重試',
        onRetry: () => ref.invalidate(discoveryMoviesProvider),
        compact: true,
      ),
    );
  }
}

/// 影人 Tab：豎版列表，頭像小於電影海報卡，點擊進影人詳情。
class _PersonTabContent extends ConsumerWidget {
  const _PersonTabContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(presetPeopleProvider);
    if (people.isEmpty) {
      return Center(
        child: Text(
          '暫無影人',
          style: AppTextStyles.hint(context),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      physics: const AlwaysScrollableScrollPhysics(),
      children: people
          .map((person) => PersonAvatarTile(person: person))
          .toList(),
    );
  }
}

/// 占位（未使用的 Tab 等）
class _ComingSoonPlaceholder extends StatelessWidget {
  const _ComingSoonPlaceholder({required this.tabName});

  final String tabName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.movie_outlined,
            size: 64,
            color: AppColors.placeholderIcon,
          ),
          const SizedBox(height: 16),
          Text(
            tabName,
            style: AppTextStyles.locationTitle(context),
          ),
          const SizedBox(height: 8),
          Text(
            '即將推出',
            style: AppTextStyles.hint(context),
          ),
        ],
      ),
    );
  }
}
