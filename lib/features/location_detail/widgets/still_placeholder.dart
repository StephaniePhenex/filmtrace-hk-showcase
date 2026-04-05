import 'package:flutter/material.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';

/// 劇照載入失敗或無圖時的占位
Widget stillPlaceholder() => Container(
      color: AppColors.placeholderBackground,
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          size: 64,
          color: AppColors.placeholderIcon,
        ),
      ),
    );
