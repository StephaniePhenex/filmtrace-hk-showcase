import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmtrace_hk/core/auth/auth_provider.dart';
import 'package:filmtrace_hk/features/feed/providers/feed_providers.dart';

/// 關注 / 取關（PLAN_8 · 8.5）。
final followInteractionProvider = Provider<FollowInteraction>((ref) {
  return FollowInteraction(ref);
});

class FollowInteraction {
  FollowInteraction(this.ref);

  final Ref ref;

  Future<String?> follow(String targetUid) async {
    final me = ref.read(currentUserProvider).valueOrNull?.uid;
    if (me == null) return '未登錄';
    try {
      await ref.read(feedRepositoryProvider).followUser(targetUid: targetUid);
      ref.invalidate(followRelationshipProvider(targetUid));
      ref.invalidate(userFollowStatsProvider(me));
      ref.invalidate(userFollowStatsProvider(targetUid));
      ref.invalidate(followingFeedControllerProvider);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> unfollow(String targetUid) async {
    final me = ref.read(currentUserProvider).valueOrNull?.uid;
    if (me == null) return '未登錄';
    try {
      await ref.read(feedRepositoryProvider).unfollowUser(targetUid: targetUid);
      ref.invalidate(followRelationshipProvider(targetUid));
      ref.invalidate(userFollowStatsProvider(me));
      ref.invalidate(userFollowStatsProvider(targetUid));
      ref.invalidate(followingFeedControllerProvider);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
