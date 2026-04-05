import 'package:flutter/material.dart';

/// 統一顏色常量，禁止在 UI 中硬編碼色值；與設計稿一致。
class AppColors {
  AppColors._();

  // 背景
  static const Color scaffoldBackground = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1A1A1A);

  // 主色
  static const Color primaryNeonRed = Color(0xFFFF3366);
  /// 賽博藍輔色 #00F0FF（與設計稿一致）
  static const Color primaryNeonCyan = Color(0xFF00F0FF);
  static const Color accentGold = Color(0xFFD4AF37);
  /// 主色/深色背景上的文字與圖標（如 AppBar 標題、按鈕文字）
  static const Color onPrimary = Color(0xFFFFFFFF);

  // 地圖與疊層
  static const Color overlayBackground = Color(0x8A000000); // black54
  static const Color zoomBarBackground = Color(0x40000000); // black26
  static const Color zoomInCyan = Color(0xD900F0FF);        // primaryNeonCyan .85
  static const Color zoomOutRed = Color(0xD9FF3366);       // primaryNeonRed .85

  // 文字與分隔
  static const Color hintText = Color(0xB3FFFFFF);          // white70
  static const Color bodyText = Color(0x8AFFFFFF);          // white54
  static const Color divider = Color(0x3DFFFFFF);           // white24

  // 占位（劇照、圖標）
  static const Color placeholderBackground = Color(0x1FFFFFFF); // white12
  static const Color placeholderIcon = Color(0x61FFFFFF);      // white38

  /// [Material] 等需透明底時使用，避免 `Colors.transparent` 散落。
  static const Color transparent = Color(0x00000000);
}
