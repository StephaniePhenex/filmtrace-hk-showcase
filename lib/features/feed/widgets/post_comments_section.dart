import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/auth/auth_provider.dart';
import 'package:filmtrace_hk/core/routing/app_routes.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/features/feed/providers/feed_providers.dart';
import 'package:filmtrace_hk/features/feed/providers/post_interaction_provider.dart';

/// 帖子詳情底部：評論列表 + 輸入（PLAN_8 · 8.4）。
class PostCommentsSection extends ConsumerStatefulWidget {
  const PostCommentsSection({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  ConsumerState<PostCommentsSection> createState() =>
      _PostCommentsSectionState();
}

class _PostCommentsSectionState extends ConsumerState<PostCommentsSection> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text;
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) {
      if (!mounted) return;
      await context.push(
        AppLocations.loginRedirect(AppLocations.feedPost(widget.postId)),
      );
      return;
    }
    setState(() => _submitting = true);
    final err = await ref.read(postInteractionProvider).submitComment(
          postId: widget.postId,
          text: text,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.primaryNeonRed,
        ),
      );
      return;
    }
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final asyncComments = ref.watch(postCommentsProvider(widget.postId));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '評論',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primaryNeonCyan,
                ),
          ),
          const SizedBox(height: 12),
          asyncComments.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => Text(
              '評論加載失敗',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.hintText,
                  ),
            ),
            data: (entries) {
              if (entries.isEmpty) {
                return Text(
                  '暫無評論，來發第一條吧',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.hintText,
                      ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: AppColors.divider,
                ),
                itemBuilder: (context, i) {
                  final e = entries[i];
                  final name = e.author?.displayName ?? '影迷';
                  final t = e.comment.createdAt;
                  final time =
                      '${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} '
                      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: AppColors.bodyText),
                              ),
                            ),
                            Text(
                              time,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppColors.hintText),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e.comment.text,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.onPrimary),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 2,
            maxLength: 500,
            enabled: !_submitting,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onPrimary,
                ),
            decoration: InputDecoration(
              hintText: '寫下評論…',
              hintStyle: const TextStyle(color: AppColors.hintText),
              filled: true,
              fillColor: AppColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryNeonCyan,
                foregroundColor: AppColors.scaffoldBackground,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.scaffoldBackground,
                      ),
                    )
                  : const Text('發送'),
            ),
          ),
        ],
      ),
    );
  }
}
