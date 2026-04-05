import 'package:flutter/material.dart';

/// 港片映迹 - 深色霓虹主题
/// 设计稿色值：背景 #121212、霓虹红 #FF3366、赛博蓝 #00F0FF。
/// 字體使用系統 TextTheme（不依賴 google_fonts 執行期下載，離線/ DNS 失敗時不崩潰）。
class AppTheme {
  AppTheme._();

  // 主色
  static const Color scaffoldBackground = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color primaryNeonRed = Color(0xFFFF3366);
  /// 赛博蓝辅色 #00F0FF（与设计稿一致）
  static const Color primaryNeonCyan = Color(0xFF00F0FF);
  static const Color accentGold = Color(0xFFD4AF37);

  static ThemeData get dark {
    final baseText = ThemeData.dark().textTheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: ColorScheme.dark(
        surface: scaffoldBackground,
        primary: primaryNeonRed,
        secondary: primaryNeonCyan,
        tertiary: accentGold,
        onSurface: Colors.white,
        onPrimary: Colors.white,
      ),
      textTheme: baseText.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: baseText.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryNeonRed,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

}
