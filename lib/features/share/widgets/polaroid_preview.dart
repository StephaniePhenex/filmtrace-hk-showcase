import 'dart:io';

import 'package:flutter/material.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';

/// 拍立得預覽：35mm 膠片風格，含齒孔、KODAK E100 字樣 + 居中相片 + 底部文字。
/// 固定尺寸便於 RepaintBoundary.toImage 輸出一致解析度。
class PolaroidPreview extends StatelessWidget {
  const PolaroidPreview({
    super.key,
    required this.imagePath,
    required this.movieName,
    required this.locationName,
    required this.dateStr,
    this.quote,
  });

  final String imagePath;
  final String movieName;
  final String locationName;
  final String dateStr;
  final String? quote;

  static const double width = 360;
  static const double filmEdgeHeight = 36;
  static const double sprocketHoleWidth = 10;
  static const double sprocketHoleHeight = 8;
  static const int sprocketCount = 8;
  static const double imageAspectRatio = 4 / 3;
  static const Color filmBeige = Color(0xFFE8E0D0);
  static const Color sprocketBlack = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    const imageAreaWidth = width - 24;
    const imageAreaHeight = imageAreaWidth / imageAspectRatio;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: filmBeige,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FilmStripTop(
            width: width,
            edgeHeight: filmEdgeHeight,
            sprocketWidth: sprocketHoleWidth,
            sprocketHeight: sprocketHoleHeight,
            sprocketCount: sprocketCount,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                width: imageAreaWidth,
                height: imageAreaHeight,
                child: File(imagePath).existsSync()
                    ? Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.placeholderBackground,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.placeholderIcon,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          _FilmStripBottom(
            width: width,
            edgeHeight: filmEdgeHeight,
            sprocketWidth: sprocketHoleWidth,
            sprocketHeight: sprocketHoleHeight,
            sprocketCount: sprocketCount,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Text(
                  '《$movieName》',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A2A2A),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  locationName,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF555555),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(child: SizedBox.shrink()),
                    Expanded(
                      flex: 2,
                      child: quote != null && quote!.isNotEmpty
                          ? Text(
                              '"$quote"',
                              style: const TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF555555),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : const SizedBox.shrink(),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 膠片頂部：齒孔（靠上緣）+ "15" 左 + "KODAK E100" 中
class _FilmStripTop extends StatelessWidget {
  const _FilmStripTop({
    required this.width,
    required this.edgeHeight,
    required this.sprocketWidth,
    required this.sprocketHeight,
    required this.sprocketCount,
  });

  final double width;
  final double edgeHeight;
  final double sprocketWidth;
  final double sprocketHeight;
  final int sprocketCount;

  @override
  Widget build(BuildContext context) {
    final totalHolesWidth = sprocketCount * sprocketWidth;
    final gap = (width - totalHolesWidth) / (sprocketCount + 1);

    return SizedBox(
      height: edgeHeight,
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 4,
            left: gap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                sprocketCount,
                (_) => Padding(
                  padding: EdgeInsets.only(
                    right: _ < sprocketCount - 1 ? gap : 0,
                  ),
                  child: Container(
                    width: sprocketWidth,
                    height: sprocketHeight,
                    decoration: BoxDecoration(
                      color: PolaroidPreview.sprocketBlack,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                '15',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: PolaroidPreview.sprocketBlack,
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              'KODAK E100',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: PolaroidPreview.sprocketBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 膠片底部：齒孔（靠下緣）+ "15" 左 + "15A" 右
class _FilmStripBottom extends StatelessWidget {
  const _FilmStripBottom({
    required this.width,
    required this.edgeHeight,
    required this.sprocketWidth,
    required this.sprocketHeight,
    required this.sprocketCount,
  });

  final double width;
  final double edgeHeight;
  final double sprocketWidth;
  final double sprocketHeight;
  final int sprocketCount;

  @override
  Widget build(BuildContext context) {
    final totalHolesWidth = sprocketCount * sprocketWidth;
    final gap = (width - totalHolesWidth) / (sprocketCount + 1);

    return SizedBox(
      height: edgeHeight,
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 4,
            left: gap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                sprocketCount,
                (_) => Padding(
                  padding: EdgeInsets.only(
                    right: _ < sprocketCount - 1 ? gap : 0,
                  ),
                  child: Container(
                    width: sprocketWidth,
                    height: sprocketHeight,
                    decoration: BoxDecoration(
                      color: PolaroidPreview.sprocketBlack,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                '15',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: PolaroidPreview.sprocketBlack,
                ),
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                '15A',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: PolaroidPreview.sprocketBlack,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
