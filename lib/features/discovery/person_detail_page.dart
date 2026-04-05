import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';
import 'package:filmtrace_hk/core/widgets/error_retry_section.dart';
import 'package:filmtrace_hk/features/discovery/providers/discovery_providers.dart';
import 'package:filmtrace_hk/features/discovery/widgets/search_result_tile.dart';

/// 影人詳情頁：姓名、角色；關聯取景地列表；涉及電影列表。點擊取景地進地點詳情，點擊電影進電影詳情。
class PersonDetailPage extends ConsumerWidget {
  const PersonDetailPage({super.key, required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final person = ref.watch(personDetailProvider(personId));
    final asyncLocations = ref.watch(personDetailLocationsProvider(personId));
    final movieNames = ref.watch(personDetailMoviesProvider(personId));

    if (person == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('影人'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('未找到該影人', style: AppTextStyles.body(context)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          person.name,
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
            Text(person.role, style: AppTextStyles.movieSubtitle(context)),
            const SizedBox(height: 24),
            Text(
              '涉及電影',
              style: AppTextStyles.locationTitle(context),
            ),
            const SizedBox(height: 12),
            if (movieNames.isEmpty)
              Text('暫無', style: AppTextStyles.hint(context))
            else
              ...movieNames.map((name) => _MovieTile(movieName: name)),
            const SizedBox(height: 24),
            Text(
              '關聯取景地',
              style: AppTextStyles.locationTitle(context),
            ),
            const SizedBox(height: 12),
            asyncLocations.when(
              data: (locations) {
                if (locations.isEmpty) {
                  return Text('暫無', style: AppTextStyles.hint(context));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: locations
                      .map((loc) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: SearchResultTile(location: loc),
                          ))
                      .toList(),
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
                message: '網絡不穩，無法加載關聯取景地',
                subMessage: '請檢查網路後重試',
                onRetry: () =>
                    ref.invalidate(personDetailLocationsProvider(personId)),
                compact: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieTile extends StatelessWidget {
  const _MovieTile({required this.movieName});

  final String movieName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(
            '/movie?name=${Uri.encodeQueryComponent(movieName)}',
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.movie_outlined,
                  color: AppColors.primaryNeonCyan,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '《$movieName》',
                    style: AppTextStyles.locationTitle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.hintText,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
