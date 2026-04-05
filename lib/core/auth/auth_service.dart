import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Auth：郵箱密碼（8.0）+ 可選匿名（僅開發/遷移用）。
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: '登錄失敗',
      );
    }
    return user;
  }

  Future<User> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: '註冊失敗',
      );
    }
    return user;
  }

  Future<void> signOut() => _auth.signOut();

  /// 匿名登錄（若尚未登錄）— 8.0 起默認不在啟動時調用，避免與「未登錄」狀態衝突。
  Future<User?> signInAnonymouslyIfNeeded() async {
    if (_auth.currentUser != null) return _auth.currentUser;
    try {
      final cred = await _auth.signInAnonymously();
      return cred.user;
    } catch (e) {
      rethrow;
    }
  }
}
