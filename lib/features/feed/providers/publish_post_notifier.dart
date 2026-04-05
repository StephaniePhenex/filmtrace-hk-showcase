import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmtrace_hk/core/auth/auth_provider.dart';
import 'package:filmtrace_hk/features/feed/providers/feed_providers.dart';

final publishPostNotifierProvider =
    NotifierProvider<PublishPostNotifier, AsyncValue<void>>(
  PublishPostNotifier.new,
);

class PublishPostNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  void reset() => state = const AsyncValue.data(null);

  Future<bool> submit({
    required String localImagePath,
    required String locationId,
    required String movieName,
    String? quote,
    String? text,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(feedRepositoryProvider).publishPost(
            localImagePath: localImagePath,
            locationId: locationId,
            movieName: movieName,
            quote: quote,
            text: text,
          );
      ref.invalidate(feedListControllerProvider);
      ref.invalidate(followingFeedControllerProvider);
      final uid = ref.read(currentUserProvider).valueOrNull?.uid;
      if (uid != null) {
        ref.invalidate(userPostsProvider(uid));
      }
    });
    return !state.hasError;
  }
}
