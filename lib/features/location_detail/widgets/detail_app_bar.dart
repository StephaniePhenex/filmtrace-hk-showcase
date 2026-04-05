import 'package:flutter/material.dart';
import 'package:filmtrace_hk/core/constants/local_stills.dart';
import 'package:filmtrace_hk/core/data/location_model.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/features/location_detail/widgets/still_placeholder.dart';

/// 可摺疊詳情頭部：劇照背景，地標名在圖片右下角；expandHeight 約 200–280
SliverAppBar buildDetailAppBar(
  BuildContext context,
  LocationModel location,
  VoidCallback onBack,
) {
  return SliverAppBar(
    expandedHeight: 260,
    pinned: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: onBack,
    ),
    backgroundColor: AppColors.surfaceDark,
    flexibleSpace: FlexibleSpaceBar(
      background: Stack(
        fit: StackFit.expand,
        children: [
          localStills.containsKey(location.id)
              ? Image.asset(
                  localStills[location.id]!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => stillPlaceholder(),
                )
              : (location.stillUrl != null && location.stillUrl!.isNotEmpty
                  ? Image.network(
                      location.stillUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => stillPlaceholder(),
                    )
                  : stillPlaceholder()),
          Positioned(
            right: 16,
            bottom: 16,
            child: Text(
              location.name,
              style: TextStyle(
                color: AppColors.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 1),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      stretchModes: const [
        StretchMode.zoomBackground,
        StretchMode.blurBackground,
      ],
      collapseMode: CollapseMode.parallax,
    ),
  );
}
