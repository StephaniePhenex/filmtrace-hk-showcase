import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/auth/auth_provider.dart';
import 'package:filmtrace_hk/core/routing/app_routes.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';

/// PLAN_8 8.0.1：郵箱密碼登錄/註冊；Apple/Google 後續在 Firebase 控制台配置後再接。
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.redirectPath = AppRoutePaths.feed});

  final String redirectPath;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isRegister = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static String _authErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return '郵箱或密碼不正確';
        case 'email-already-in-use':
          return '該郵箱已註冊';
        case 'weak-password':
          return '密碼至少 6 位';
        case 'invalid-email':
          return '郵箱格式不正確';
        default:
          return error.message ?? '認證失敗';
      }
    }
    return error.toString();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notifier = ref.read(authSessionNotifierProvider.notifier);
    notifier.clearSessionMessage();
    final email = _emailController.text;
    final password = _passwordController.text;
    final ok = _isRegister
        ? await notifier.registerWithEmail(email: email, password: password)
        : await notifier.signInWithEmail(email: email, password: password);
    if (!mounted) return;
    if (ok) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(widget.redirectPath);
      }
      return;
    }
    final err = ref.read(authSessionNotifierProvider).error;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authErrorMessage(err)),
          backgroundColor: AppColors.primaryNeonRed,
        ),
      );
      notifier.clearSessionMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionNotifierProvider);
    final loading = session.isLoading;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        title: Text(_isRegister ? '註冊' : '登錄'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(widget.redirectPath);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '影迷圈與個人資料需登錄後使用',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.hintText,
                      ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: '郵箱',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '請填寫郵箱';
                    if (!v.contains('@')) return '郵箱格式不正確';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: '密碼',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return '請填寫密碼';
                    if (v.length < 6) return '至少 6 位';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryNeonCyan,
                    foregroundColor: AppColors.scaffoldBackground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isRegister ? '註冊' : '登錄'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: loading
                      ? null
                      : () {
                          setState(() => _isRegister = !_isRegister);
                        },
                  child: Text(
                    _isRegister ? '已有帳號？去登錄' : '沒有帳號？註冊',
                    style: AppTextStyles.linkCyan,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
