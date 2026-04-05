import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmtrace_hk/core/auth/auth_service.dart';
import 'package:filmtrace_hk/core/data/user_profile_model.dart';
import 'package:filmtrace_hk/core/data/user_repository.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final userRepositoryProvider =
    Provider<UserRepository>((ref) => UserRepository());

/// 全局登錄態（PLAN_8 `currentUserProvider`）。
final currentUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// 與 [currentUserProvider] 相同；保留舊名避免外部引用斷裂。
final authStateProvider = currentUserProvider;

final userProfileProvider =
    FutureProvider.autoDispose.family<UserProfile?, String>((ref, uid) async {
  return ref.watch(userRepositoryProvider).getProfile(uid);
});

/// 當前登錄用戶的 Firestore 資料；未登錄為 `AsyncData(null)`。
final currentUserProfileProvider =
    FutureProvider.autoDispose<UserProfile?>((ref) async {
  final auth = ref.watch(currentUserProvider);
  if (auth.isLoading || auth.hasError) return null;
  final user = auth.valueOrNull;
  if (user == null) return null;
  return ref.watch(userRepositoryProvider).getProfile(user.uid);
});

final authSessionNotifierProvider =
    NotifierProvider<AuthSessionNotifier, AsyncValue<void>>(
  AuthSessionNotifier.new,
);

class AuthSessionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  void _clearErrorState() {
    state = const AsyncValue.data(null);
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref.read(authServiceProvider).signInWithEmailAndPassword(
            email: email,
            password: password,
          );
      await ref.read(userRepositoryProvider).ensureUserProfile(user);
      ref.invalidate(userProfileProvider(user.uid));
      ref.invalidate(currentUserProfileProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> registerWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user =
          await ref.read(authServiceProvider).createUserWithEmailAndPassword(
                email: email,
                password: password,
              );
      await ref.read(userRepositoryProvider).ensureUserProfile(user);
      ref.invalidate(userProfileProvider(user.uid));
      ref.invalidate(currentUserProfileProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
    _clearErrorState();
    ref.invalidate(currentUserProfileProvider);
  }

  /// 登錄頁在展示錯誤後可清掉 error，避免按鈕一直處於錯誤態。
  void clearSessionMessage() => _clearErrorState();
}

/// 啟動時可選匿名登錄（僅在未啟用郵箱登錄的開發場景使用）。
Future<void> ensureAnonymousAuth(AuthService auth) async {
  try {
    await auth.signInAnonymouslyIfNeeded();
  } catch (_) {}
}
