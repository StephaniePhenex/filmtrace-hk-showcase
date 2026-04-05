import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:filmtrace_hk/features/camera/camera_page.dart';

/// 应用骨架：底部导航 + 四个主页面（由 GoRouter StatefulShellRoute 驱动）
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static bool _cameraPermissionRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // PLAN_8 8.0：不再自動匿名登錄，未登錄時 `currentUserProvider` 為 null。
      // 延遲請求相機權限，避免與地圖頁 `locationWhenInUse` 同時觸發 permission_handler 的並發錯誤。
      if (!_cameraPermissionRequested) {
        _cameraPermissionRequested = true;
        Future<void>.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          unawaited(Permission.camera.request());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;
    return Scaffold(
      body: shell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: shell.currentIndex,
        onTap: (index) {
          if (shell.currentIndex == 2 && index != 2) {
            SystemChrome.setPreferredOrientations(DeviceOrientation.values);
          }
          shell.goBranch(index);
          if (index == 2) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              CameraPage.onTabResumeCallback?.call();
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: '片場地圖',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: '光影檢索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: '打卡',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '影迷圈',
          ),
        ],
      ),
    );
  }
}
