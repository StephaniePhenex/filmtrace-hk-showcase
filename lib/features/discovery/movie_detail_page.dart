import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/constants/local_stills.dart';
import 'package:filmtrace_hk/core/data/location_model.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';
import 'package:filmtrace_hk/core/widgets/error_retry_section.dart';
import 'package:filmtrace_hk/features/discovery/providers/discovery_providers.dart';
import 'package:filmtrace_hk/features/discovery/widgets/search_result_tile.dart';

/// 電影詳情頁：電影名 + 該電影取景地列表；點擊取景地進地點詳情。
class MovieDetailPage extends ConsumerWidget {
  const MovieDetailPage({super.key, required this.movieName});

  /// 電影名（由路由 query name 傳入，已解碼）。
  final String movieName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLocations = ref.watch(movieDetailLocationsProvider(movieName));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '《$movieName》',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryNeonCyan,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MovieStillArea(asyncLocations: asyncLocations),
            const SizedBox(height: 20),
            _MovieInfoSection(
              quote: _quotePlaceholder(movieName),
            ),
            const SizedBox(height: 24),
            asyncLocations.when(
              data: (locations) {
                if (locations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '暫無取景地資料',
                        style: AppTextStyles.hint(context),
                      ),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '取景地',
                      style: AppTextStyles.locationTitle(context),
                    ),
                    const SizedBox(height: 12),
                    ...locations.map(
                      (loc) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SearchResultTile(location: loc),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => ErrorRetrySection(
                message: '網絡不穩，無法加載取景地',
                subMessage: '請檢查網路後重試',
                onRetry: () =>
                    ref.invalidate(movieDetailLocationsProvider(movieName)),
                compact: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _quotePlaceholder(String movieName) {
    if (movieName.contains('喜劇之王')) return '我養你啊。';
    return '本場景為電影重要取景地。';
  }
}

/// 劇照區域：與打卡地信息卡一致，4:3 比例、僅上圓角 12。取該電影第一個取景地的劇照。
class _MovieStillArea extends StatelessWidget {
  const _MovieStillArea({required this.asyncLocations});

  final AsyncValue<List<LocationModel>> asyncLocations;

  static const double _aspectRatio = 4 / 3;

  @override
  Widget build(BuildContext context) {
    final location = asyncLocations.valueOrNull?.isNotEmpty == true
        ? asyncLocations.value!.first
        : null;
    final locationId = location?.id;
    final stillUrl = location?.stillUrl;

    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: _buildContent(context, locationId, stillUrl),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, String? locationId, String? stillUrl) {
    if (locationId != null && localStills.containsKey(locationId)) {
      return Image.asset(
        localStills[locationId]!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }
    final url = stillUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.placeholderBackground,
            child: const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: AppColors.placeholderBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.movie_outlined,
              size: 40,
              color: AppColors.placeholderIcon,
            ),
            const SizedBox(height: 8),
            Text(
              '暫無劇照',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.placeholderIcon,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 電影資訊區：經典台詞 + 劇情簡介（占位）。
class _MovieInfoSection extends StatelessWidget {
  const _MovieInfoSection({required this.quote});

  final String quote;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '"$quote"',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryNeonCyan,
                height: 1.35,
              ),
        ),
        const SizedBox(height: 20),
        Text(
          '劇情簡介',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '本場景在電影中為重要取景地，親臨現場可感受電影氛圍。（占位）',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.bodyText,
                height: 1.5,
              ),
        ),
      ],
    );
  }
}
