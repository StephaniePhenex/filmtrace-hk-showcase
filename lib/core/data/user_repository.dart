import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:filmtrace_hk/core/data/user_profile_model.dart';

/// Firestore `users`：與 PLAN_8 8.0.3 對齊。
class UserRepository {
  UserRepository();

  static const String _collectionId = 'users';

  CollectionReference<Map<String, dynamic>> get _coll =>
      FirebaseFirestore.instance.collection(_collectionId);

  String _defaultDisplayName(User user) {
    final email = user.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    final uid = user.uid;
    final tail = uid.length >= 4 ? uid.substring(0, 4) : uid;
    return '影迷$tail';
  }

  /// 首次登錄寫入 `users/{uid}`；已存在則不覆蓋 `created_at`。
  Future<void> ensureUserProfile(User user) async {
    final doc = _coll.doc(user.uid);
    final snap = await doc.get();
    if (!snap.exists) {
      await doc.set({
        'display_name': user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : _defaultDisplayName(user),
        'avatar_url': user.photoURL,
        'created_at': FieldValue.serverTimestamp(),
      });
      return;
    }
    final data = snap.data();
    final name = data?['display_name'] as String?;
    if (name == null || name.isEmpty) {
      await doc.set(
        {
          'display_name': _defaultDisplayName(user),
        },
        SetOptions(merge: true),
      );
    }
  }

  Future<UserProfile?> getProfile(String uid) async {
    final snap = await _coll.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    final map = Map<String, dynamic>.from(snap.data()!)..['uid'] = uid;
    try {
      return UserProfile.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateDisplayName({
    required String uid,
    required String displayName,
  }) async {
    await _coll.doc(uid).set(
      {'display_name': displayName.trim()},
      SetOptions(merge: true),
    );
  }
}
