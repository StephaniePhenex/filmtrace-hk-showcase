import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/core/theme/app_text_styles.dart';
import 'package:filmtrace_hk/features/discovery/data/preset_people.dart';

/// 影人 Tab 豎版列表項：小頭像（比電影海報小）+ 姓名、角色；點擊進影人詳情。
class PersonAvatarTile extends StatelessWidget {
  const PersonAvatarTile({super.key, required this.person});

  final PresetPerson person;

  /// 頭像尺寸，小於電影海報卡中的海報圖
  static const double avatarSize = 56;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/person/${person.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: avatarSize,
                    height: avatarSize,
                    child: Container(
                      color: AppColors.placeholderBackground,
                      child: const Icon(
                        Icons.person_outline,
                        size: 28,
                        color: AppColors.placeholderIcon,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        person.name,
                        style: AppTextStyles.locationTitle(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        person.role,
                        style: AppTextStyles.movieSubtitle(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.hintText,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
