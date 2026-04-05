import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:filmtrace_hk/core/data/user_profile_model.dart';
import 'package:filmtrace_hk/features/feed/data/check_in_post_model.dart';
import 'package:filmtrace_hk/features/feed/data/post_comment_model.dart';

/// Firestore `check_in_posts` + batch 讀 `users`；PLAN_8 · 8.1；8.2 發帖上傳 Storage。
class FeedRepository {
  FeedRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  static const String _postsCollection = 'check_in_posts';
  static const String _usersCollection = 'users';
  static const String _likesCollection = 'post_likes';
  static const String _commentsCollection = 'post_comments';
  static const String _followsCollection = 'follows';

  String _likeDocumentId(String postId, String uid) => '${postId}_$uid';

  /// 關注關係文檔 ID：`{followerUid}_{followingUid}`（PLAN_8 · 8.5）。
  String followDocumentId(String followerUid, String followingUid) =>
      '${followerUid}_$followingUid';

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection(_postsCollection);

  /// 按 [created_at] 降序分頁；[startAfter] 為上一頁最後一條文檔快照。
  Future<FeedPostsPageResult> getFeedPosts({
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> q =
        _posts.orderBy('created_at', descending: true).limit(limit);
    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }
    final snap = await q.get();
    final posts = <CheckInPost>[];
    DocumentSnapshot<Map<String, dynamic>>? last;
    for (final doc in snap.docs) {
      last = doc;
      final map = Map<String, dynamic>.from(doc.data())..['id'] = doc.id;
      try {
        posts.add(CheckInPost.fromJson(map));
      } catch (_) {}
    }
    return FeedPostsPageResult(posts: posts, lastSnapshot: last);
  }

  Future<CheckInPost?> getPostById(String id) async {
    final doc = await _posts.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    final map = Map<String, dynamic>.from(doc.data()!)..['id'] = doc.id;
    try {
      return CheckInPost.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// `whereIn` 每批最多 10 條。
  Future<Map<String, UserProfile>> getProfilesForUids(
    Iterable<String> uids,
  ) async {
    final unique = uids.toSet().toList();
    final out = <String, UserProfile>{};
    for (var i = 0; i < unique.length; i += 10) {
      final chunk = unique.sublist(i, min(i + 10, unique.length));
      if (chunk.isEmpty) continue;
      final snap = await _firestore
          .collection(_usersCollection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        final map = Map<String, dynamic>.from(doc.data())..['uid'] = doc.id;
        try {
          out[doc.id] = UserProfile.fromJson(map);
        } catch (_) {}
      }
    }
    return out;
  }

  /// 當前用戶對這批帖子中已點讚的 postId（`post_likes`：`post_id` + `user_id`）。
  Future<Set<String>> getLikedPostIdsForUser({
    required String uid,
    required List<String> postIds,
  }) async {
    if (postIds.isEmpty) return {};
    final liked = <String>{};
    for (var i = 0; i < postIds.length; i += 10) {
      final chunk = postIds.sublist(i, min(i + 10, postIds.length));
      final snap = await _firestore
          .collection(_likesCollection)
          .where('user_id', isEqualTo: uid)
          .where('post_id', whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        final pid = doc.data()['post_id'] as String?;
        if (pid != null) liked.add(pid);
      }
    }
    return liked;
  }

  /// `getDownloadURL` 緊接在 `putFile` 之後時，iOS 端偶發 `object-not-found`（物件尚未可見），故帶退避重試。
  Future<String> _getDownloadUrlWithRetry(Reference ref) async {
    const maxAttempts = 6;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await ref.getDownloadURL();
      } on FirebaseException catch (e) {
        final code = e.code.toLowerCase();
        final isNotFound = code.contains('object-not-found');
        if (!isNotFound || attempt == maxAttempts - 1) rethrow;
        await Future<void>.delayed(
          Duration(milliseconds: 200 * (1 << attempt)),
        );
      }
    }
    throw StateError('getDownloadURL 失敗');
  }

  /// Storage `feed/{uid}/{postId}.jpg` + Firestore `check_in_posts`（PLAN_8 · 8.2）。
  Future<void> publishPost({
    required String localImagePath,
    required String locationId,
    required String movieName,
    String? quote,
    String? text,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('未登錄，無法發帖');
    }
    final file = File(localImagePath);
    if (!await file.exists()) {
      throw StateError('圖片文件不存在，請返回分享頁重新生成拍立得');
    }
    final byteLength = await file.length();
    if (byteLength == 0) {
      throw StateError('圖片文件為空，請重新保存拍立得後再試');
    }
    final docRef = _posts.doc();
    final postId = docRef.id;
    final storageRef = _storage.ref().child('feed/$uid/$postId.jpg');
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    // 使用記憶體上傳，避免真機上 `putFile` 與臨時路徑/句柄競態導致後端未實際落檔。
    final bytes = await file.readAsBytes();
    final uploadTask = storageRef.putData(bytes, metadata);
    final snapshot = await uploadTask;
    if (snapshot.state != TaskState.success) {
      throw StateError('圖片上傳未完成（${snapshot.state}），請檢查網絡後重試');
    }
    final imageUrl = await _getDownloadUrlWithRetry(snapshot.ref);
    final trimmed = text?.trim();
    final q = quote?.trim();
    await docRef.set({
      'user_id': uid,
      'image_url': imageUrl,
      'location_id': locationId,
      'movie_name': movieName,
      if (q != null && q.isNotEmpty) 'quote': q,
      if (trimmed != null && trimmed.isNotEmpty) 'text': trimmed,
      'created_at': FieldValue.serverTimestamp(),
      'like_count': 0,
    });
  }

  /// 點贊：`post_likes` 文檔 ID `{postId}_{uid}` + `check_in_posts.like_count` 事務 +1（PLAN_8 · 8.4）。
  Future<void> addLike({required String postId}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('未登錄');
    final likeRef =
        _firestore.collection(_likesCollection).doc(_likeDocumentId(postId, uid));
    final postRef = _posts.doc(postId);
    await _firestore.runTransaction((tx) async {
      final likeSnap = await tx.get(likeRef);
      if (likeSnap.exists) return;
      final postSnap = await tx.get(postRef);
      if (!postSnap.exists) throw StateError('帖子不存在');
      final count = (postSnap.data()?['like_count'] as num?)?.toInt() ?? 0;
      tx.set(likeRef, {
        'post_id': postId,
        'user_id': uid,
        'created_at': FieldValue.serverTimestamp(),
      });
      tx.update(postRef, {'like_count': count + 1});
    });
  }

  /// 取消點贊：刪除 `post_likes` + `like_count` 事務 -1。
  Future<void> removeLike({required String postId}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('未登錄');
    final likeRef =
        _firestore.collection(_likesCollection).doc(_likeDocumentId(postId, uid));
    final postRef = _posts.doc(postId);
    await _firestore.runTransaction((tx) async {
      final likeSnap = await tx.get(likeRef);
      if (!likeSnap.exists) return;
      final postSnap = await tx.get(postRef);
      if (!postSnap.exists) {
        tx.delete(likeRef);
        return;
      }
      final count = (postSnap.data()?['like_count'] as num?)?.toInt() ?? 0;
      tx.delete(likeRef);
      tx.update(postRef, {'like_count': max(0, count - 1)});
    });
  }

  /// 某帖評論，按時間正序（詳情頁由上往下讀；首版 limit 20）。
  Future<List<PostComment>> getComments({
    required String postId,
    int limit = 20,
  }) async {
    final snap = await _firestore
        .collection(_commentsCollection)
        .where('post_id', isEqualTo: postId)
        .orderBy('created_at', descending: false)
        .limit(limit)
        .get();
    final out = <PostComment>[];
    for (final doc in snap.docs) {
      final map = Map<String, dynamic>.from(doc.data())..['id'] = doc.id;
      try {
        out.add(PostComment.fromJson(map));
      } catch (_) {}
    }
    return out;
  }

  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('未登錄');
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw StateError('評論為空');
    }
    if (trimmed.length > 500) {
      throw StateError('評論請少於 500 字');
    }
    await _firestore.collection(_commentsCollection).add({
      'post_id': postId,
      'user_id': uid,
      'text': trimmed,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// 某用戶發布的帖子（時間降序，首版單頁 limit）。
  Future<List<CheckInPost>> getPostsByUser({
    required String userId,
    int limit = 30,
  }) async {
    final snap = await _posts
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .get();
    final out = <CheckInPost>[];
    for (final doc in snap.docs) {
      final map = Map<String, dynamic>.from(doc.data())..['id'] = doc.id;
      try {
        out.add(CheckInPost.fromJson(map));
      } catch (_) {}
    }
    return out;
  }

  /// `follower_id == [followerUid]`，最多 [limit] 條（單字段查詢，無 order）。
  Future<List<String>> getFollowingUidList({
    required String followerUid,
    int limit = 100,
  }) async {
    final snap = await _firestore
        .collection(_followsCollection)
        .where('follower_id', isEqualTo: followerUid)
        .limit(limit)
        .get();
    final out = <String>[];
    for (final doc in snap.docs) {
      final id = doc.data()['following_id'] as String?;
      if (id != null) out.add(id);
    }
    return out;
  }

  Future<bool> isFollowing({
    required String followerUid,
    required String followingUid,
  }) async {
    final doc = await _firestore
        .collection(_followsCollection)
        .doc(followDocumentId(followerUid, followingUid))
        .get();
    return doc.exists;
  }

  Future<void> followUser({required String targetUid}) async {
    final me = _auth.currentUser?.uid;
    if (me == null) throw StateError('未登錄');
    if (me == targetUid) throw StateError('不能關注自己');
    await _firestore
        .collection(_followsCollection)
        .doc(followDocumentId(me, targetUid))
        .set({
      'follower_id': me,
      'following_id': targetUid,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unfollowUser({required String targetUid}) async {
    final me = _auth.currentUser?.uid;
    if (me == null) throw StateError('未登錄');
    await _firestore
        .collection(_followsCollection)
        .doc(followDocumentId(me, targetUid))
        .delete();
  }

  /// 關注數 / 粉絲數（MVP：`limit(1000)` 內精確計數）。
  Future<({int following, int followers})> getFollowStats(String uid) async {
    final followingSnap = await _firestore
        .collection(_followsCollection)
        .where('follower_id', isEqualTo: uid)
        .limit(1000)
        .get();
    final followersSnap = await _firestore
        .collection(_followsCollection)
        .where('following_id', isEqualTo: uid)
        .limit(1000)
        .get();
    return (
      following: followingSnap.docs.length,
      followers: followersSnap.docs.length,
    );
  }

  /// 多個作者的帖子合併按時間排序（`whereIn` 每批 ≤10）；用於關注流。
  Future<List<CheckInPost>> getMergedPostsForAuthors({
    required List<String> authorIds,
    int cap = 30,
  }) async {
    if (authorIds.isEmpty) return [];
    final unique = authorIds.toSet().toList();
    final all = <CheckInPost>[];
    for (var i = 0; i < unique.length; i += 10) {
      final chunk = unique.sublist(i, min(i + 10, unique.length));
      final snap = await _posts
          .where('user_id', whereIn: chunk)
          .orderBy('created_at', descending: true)
          .limit(20)
          .get();
      for (final doc in snap.docs) {
        final map = Map<String, dynamic>.from(doc.data())..['id'] = doc.id;
        try {
          all.add(CheckInPost.fromJson(map));
        } catch (_) {}
      }
    }
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final seen = <String>{};
    final deduped = <CheckInPost>[];
    for (final p in all) {
      if (seen.add(p.id)) deduped.add(p);
    }
    if (deduped.length <= cap) return deduped;
    return deduped.sublist(0, cap);
  }
}

class FeedPostsPageResult {
  FeedPostsPageResult({
    required this.posts,
    required this.lastSnapshot,
  });

  final List<CheckInPost> posts;
  final DocumentSnapshot<Map<String, dynamic>>? lastSnapshot;
}
