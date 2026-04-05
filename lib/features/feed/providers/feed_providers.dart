import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmtrace_hk/core/auth/auth_provider.dart';
import 'package:filmtrace_hk/core/data/user_profile_model.dart';
import 'package:filmtrace_hk/features/feed/data/check_in_post_model.dart';
import 'package:filmtrace_hk/features/feed/data/feed_repository.dart';
import 'package:filmtrace_hk/features/feed/data/post_comment_model.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

/// 單條動態展示用（列表項 / 詳情）。
class FeedPostItem {
  const FeedPostItem({
    required this.post,
    this.author,
    required this.likedByMe,
  });

  final CheckInPost post;
  final UserProfile? author;
  final bool likedByMe;
}

class FeedListState {
  const FeedListState({
    required this.items,
    this.lastDoc,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<FeedPostItem> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool hasMore;
  final bool isLoadingMore;

  FeedListState copyWith({
    List<FeedPostItem>? items,
    DocumentSnapshot<Map<String, dynamic>>? lastDoc,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return FeedListState(
      items: items ?? this.items,
      lastDoc: lastDoc ?? this.lastDoc,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final feedListControllerProvider =
    AsyncNotifierProvider<FeedListController, FeedListState>(
  FeedListController.new,
);

class FeedListController extends AsyncNotifier<FeedListState> {
  static const int _limit = 15;

  @override
  Future<FeedListState> build() async {
    final repo = ref.read(feedRepositoryProvider);
    final page = await repo.getFeedPosts(limit: _limit, startAfter: null);
    return _buildStateFromPage(page, const []);
  }

  Future<FeedListState> _buildStateFromPage(
    FeedPostsPageResult page,
    List<FeedPostItem> existingItems,
  ) async {
    final repo = ref.read(feedRepositoryProvider);
    final profiles =
        await repo.getProfilesForUids(page.posts.map((e) => e.userId));
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    var liked = <String>{};
    if (uid != null && page.posts.isNotEmpty) {
      liked = await repo.getLikedPostIdsForUser(
        uid: uid,
        postIds: page.posts.map((e) => e.id).toList(),
      );
    }
    final newItems = page.posts
        .map(
          (p) => FeedPostItem(
            post: p,
            author: profiles[p.userId],
            likedByMe: liked.contains(p.id),
          ),
        )
        .toList();
    return FeedListState(
      items: [...existingItems, ...newItems],
      lastDoc: page.lastSnapshot,
      hasMore: page.posts.length >= _limit,
      isLoadingMore: false,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(feedRepositoryProvider);
      final page = await repo.getFeedPosts(limit: _limit, startAfter: null);
      return _buildStateFromPage(page, const []);
    });
  }

  Future<void> loadMore() async {
    final cur = state.value;
    if (cur == null ||
        !cur.hasMore ||
        cur.isLoadingMore ||
        cur.lastDoc == null) {
      return;
    }
    state = AsyncValue.data(cur.copyWith(isLoadingMore: true));
    try {
      final repo = ref.read(feedRepositoryProvider);
      final page =
          await repo.getFeedPosts(limit: _limit, startAfter: cur.lastDoc);
      final next = await _buildStateFromPage(page, cur.items);
      state = AsyncValue.data(next);
    } catch (_) {
      state = AsyncValue.data(cur.copyWith(isLoadingMore: false));
    }
  }
}

/// 帖子詳情（8.3 可擴展評論等）。
final postDetailFeedItemProvider =
    FutureProvider.autoDispose.family<FeedPostItem?, String>((ref, id) async {
  final repo = ref.watch(feedRepositoryProvider);
  final post = await repo.getPostById(id);
  if (post == null) return null;
  final profiles = await repo.getProfilesForUids([post.userId]);
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  var liked = false;
  if (uid != null) {
    final set =
        await repo.getLikedPostIdsForUser(uid: uid, postIds: [post.id]);
    liked = set.contains(post.id);
  }
  return FeedPostItem(
    post: post,
    author: profiles[post.userId],
    likedByMe: liked,
  );
});

/// 評論列表 + 作者 profile（8.4）。
class PostCommentEntry {
  const PostCommentEntry({required this.comment, this.author});

  final PostComment comment;
  final UserProfile? author;
}

final postCommentsProvider =
    FutureProvider.autoDispose.family<List<PostCommentEntry>, String>(
  (ref, postId) async {
    final repo = ref.watch(feedRepositoryProvider);
    final comments = await repo.getComments(postId: postId);
    if (comments.isEmpty) return const [];
    final profiles =
        await repo.getProfilesForUids(comments.map((e) => e.userId));
    return comments
        .map(
          (c) => PostCommentEntry(
            comment: c,
            author: profiles[c.userId],
          ),
        )
        .toList();
  },
);

/// 將 [CheckInPost] 拼成列表項（作者、當前用戶是否已贊）。
Future<List<FeedPostItem>> feedItemsFromPosts(
  Ref ref,
  List<CheckInPost> posts,
) async {
  if (posts.isEmpty) return [];
  final repo = ref.read(feedRepositoryProvider);
  final profiles = await repo.getProfilesForUids(posts.map((e) => e.userId));
  final uid = ref.read(currentUserProvider).valueOrNull?.uid;
  var liked = <String>{};
  if (uid != null) {
    liked = await repo.getLikedPostIdsForUser(
      uid: uid,
      postIds: posts.map((e) => e.id).toList(),
    );
  }
  return posts
      .map(
        (p) => FeedPostItem(
          post: p,
          author: profiles[p.userId],
          likedByMe: liked.contains(p.id),
        ),
      )
      .toList();
}

/// PLAN_8 · 8.5：個人頁關注數 / 粉絲數（MVP ≤1000 精確）。
class UserFollowStats {
  const UserFollowStats({
    required this.following,
    required this.followers,
  });

  final int following;
  final int followers;
}

final userFollowStatsProvider =
    FutureProvider.autoDispose.family<UserFollowStats, String>(
  (ref, uid) async {
    final c = await ref.watch(feedRepositoryProvider).getFollowStats(uid);
    return UserFollowStats(following: c.following, followers: c.followers);
  },
);

/// 當前登錄用戶是否已關注 [targetUid]（未登錄或看自己為 false）。
final followRelationshipProvider =
    FutureProvider.autoDispose.family<bool, String>(
  (ref, targetUid) async {
    final me = ref.watch(currentUserProvider).valueOrNull?.uid;
    if (me == null) return false;
    if (me == targetUid) return false;
    return ref.watch(feedRepositoryProvider).isFollowing(
          followerUid: me,
          followingUid: targetUid,
        );
  },
);

/// 某用戶的打卡帖列表（個人頁）。
final userPostsProvider =
    FutureProvider.autoDispose.family<List<FeedPostItem>, String>(
  (ref, uid) async {
    final posts =
        await ref.watch(feedRepositoryProvider).getPostsByUser(userId: uid);
    return feedItemsFromPosts(ref, posts);
  },
);

final followingFeedControllerProvider =
    AsyncNotifierProvider<FollowingFeedController, FeedListState>(
  FollowingFeedController.new,
);

/// 「關注」Tab：合併已關注用戶的帖子（無分頁，下拉刷新）。
class FollowingFeedController extends AsyncNotifier<FeedListState> {
  static const int _followingCap = 50;
  static const int _postCap = 30;

  @override
  Future<FeedListState> build() async {
    ref.watch(currentUserProvider);
    final me = ref.read(currentUserProvider).valueOrNull?.uid;
    if (me == null) {
      return const FeedListState(items: [], hasMore: false);
    }
    final repo = ref.read(feedRepositoryProvider);
    final following =
        await repo.getFollowingUidList(followerUid: me, limit: _followingCap);
    if (following.isEmpty) {
      return const FeedListState(items: [], hasMore: false);
    }
    final posts = await repo.getMergedPostsForAuthors(
      authorIds: following,
      cap: _postCap,
    );
    final items = await feedItemsFromPosts(ref, posts);
    return FeedListState(
      items: items,
      lastDoc: null,
      hasMore: false,
      isLoadingMore: false,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final me = ref.read(currentUserProvider).valueOrNull?.uid;
      if (me == null) {
        return const FeedListState(items: [], hasMore: false);
      }
      final repo = ref.read(feedRepositoryProvider);
      final following =
          await repo.getFollowingUidList(followerUid: me, limit: _followingCap);
      if (following.isEmpty) {
        return const FeedListState(items: [], hasMore: false);
      }
      final posts = await repo.getMergedPostsForAuthors(
        authorIds: following,
        cap: _postCap,
      );
      final items = await feedItemsFromPosts(ref, posts);
      return FeedListState(
        items: items,
        lastDoc: null,
        hasMore: false,
        isLoadingMore: false,
      );
    });
  }
}
