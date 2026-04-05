import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmtrace_hk/core/auth/auth_provider.dart';
import 'package:filmtrace_hk/features/feed/providers/feed_providers.dart';

/// 點贊 / 發評論；成功後 invalidate 動態流與詳情（PLAN_8 · 8.4）。
final postInteractionProvider = Provider<PostInteraction>((ref) {
  return PostInteraction(ref);
});

class PostInteraction {
  PostInteraction(this.ref);

  final Ref ref;

  /// `null` 表示成功；否則為錯誤文案。
  Future<String?> toggleLike({
    required String postId,
    required bool currentlyLiked,
  }) async {
    if (ref.read(currentUserProvider).valueOrNull == null) {
      return '未登錄';
    }
    try {
      final repo = ref.read(feedRepositoryProvider);
      if (currentlyLiked) {
        await repo.removeLike(postId: postId);
      } else {
        await repo.addLike(postId: postId);
      }
      ref.invalidate(feedListControllerProvider);
      ref.invalidate(followingFeedControllerProvider);
      ref.invalidate(postDetailFeedItemProvider(postId));
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> submitComment({
    required String postId,
    required String text,
  }) async {
    if (ref.read(currentUserProvider).valueOrNull == null) {
      return '未登錄';
    }
    try {
      await ref.read(feedRepositoryProvider).addComment(
            postId: postId,
            text: text,
          );
      ref.invalidate(postCommentsProvider(postId));
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
