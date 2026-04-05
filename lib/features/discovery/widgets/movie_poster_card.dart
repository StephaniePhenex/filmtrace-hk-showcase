import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/constants/local_stills.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/features/discovery/providers/discovery_providers.dart';

/// 電影 Tab 海報卡：海報圖、可收藏愛心、片名、豆瓣評分星級；點擊進入電影詳情。
class MoviePosterCard extends ConsumerWidget {
  const MoviePosterCard({super.key, required this.item});

  final DiscoveryMovieItem item;

  static const double posterAspectRatio = 2 / 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteMovieNamesProvider);
    final isFav = favorites.contains(item.movieName);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(
          '/movie?name=${Uri.encodeQueryComponent(item.movieName)}',
        ),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topLeft,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: posterAspectRatio,
                    child: _PosterImage(
                      locationId: item.posterLocationId,
                      stillUrl: item.posterStillUrl,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav
                          ? AppColors.primaryNeonRed
                          : AppColors.onPrimary,
                      size: 20,
                    ),
                    onPressed: () {
                      ref.read(favoriteMovieNamesProvider.notifier).update(
                            (set) {
                              final next = Set<String>.from(set);
                              if (next.contains(item.movieName)) {
                                next.remove(item.movieName);
                              } else {
                                next.add(item.movieName);
                              }
                              return next;
                            },
                          );
                    },
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(4),
                      minimumSize: const Size(32, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.movieName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primaryNeonCyan,
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                ...List.generate(5, (i) {
                  // 豆瓣 10 分制：5 星 = 10 分，星數 = 分數 / 2
                  final stars = item.rating / 2;
                  final fullCount = stars.floor().clamp(0, 5);
                  final remainder = stars - fullCount;
                  final hasHalf = remainder >= 0.25 && fullCount < 5;
                  final filled = i < fullCount;
                  final half = i == fullCount && hasHalf;
                  return Icon(
                    half
                        ? Icons.star_half
                        : (filled ? Icons.star : Icons.star_border),
                    size: 14,
                    color: const Color(0xFFFFD54F),
                  );
                }),
                const SizedBox(width: 6),
                Text(
                  '${item.rating.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.hintText,
                      ),
                ),
                Text(
                  ' 豆瓣',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.hintText,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterImage extends StatelessWidget {
  const _PosterImage({this.locationId, this.stillUrl});

  final String? locationId;
  final String? stillUrl;

  static Widget _placeholder() => ColoredBox(
        color: AppColors.placeholderBackground,
        child: Center(
          child: Icon(
            Icons.movie_outlined,
            size: 40,
            color: AppColors.placeholderIcon,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (locationId != null && localStills.containsKey(locationId)) {
      return Image.asset(
        localStills[locationId!]!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    final url = stillUrl?.trim();
    if (url == null || url.isEmpty) return _placeholder();
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const ColoredBox(
          color: AppColors.placeholderBackground,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }
}
