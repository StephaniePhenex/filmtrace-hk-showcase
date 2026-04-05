import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:filmtrace_hk/core/theme/app_theme.dart';
import 'package:filmtrace_hk/core/routing/app_router.dart';
import 'firebase_options.dart';

const MethodChannel _mapboxChannel = MethodChannel('filmtrace_hk/mapbox');

/// 先取 dart-define，若空则从原生（iOS Info.plist / Android manifest）读取，供真机/从 Xcode 运行时不报 401。
Future<String> _resolveMapboxToken() async {
  const String fromEnv = String.fromEnvironment('MAPBOX_ACCESS_TOKEN', defaultValue: '');
  if (fromEnv.isNotEmpty) return fromEnv;
  for (int attempt = 0; attempt < 3; attempt++) {
    try {
      if (attempt > 0) await Future<void>.delayed(const Duration(milliseconds: 150));
      final dynamic fromPlatform = await _mapboxChannel.invokeMethod('getAccessToken');
      final String token = (fromPlatform is String ? fromPlatform.trim() : null) ?? '';
      if (token.isNotEmpty) return token;
    } catch (_) {}
  }
  return '';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final String mapboxToken = await _resolveMapboxToken();
  if (mapboxToken.isNotEmpty) {
    MapboxOptions.setAccessToken(mapboxToken);
  }
  if (kDebugMode) {
    if (mapboxToken.isEmpty) {
      debugPrint('Mapbox token: 未设置 → 地图瓦片会报 401。请设置 iOS Info.plist MGLMapboxAccessToken / Android manifest meta-data，或运行: flutter run --dart-define=MAPBOX_ACCESS_TOKEN=pk.xxx');
    } else {
      debugPrint('Mapbox token: 已设置, 长度=${mapboxToken.length}');
    }
  }

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } on UnsupportedError catch (_) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase: 未配置。在项目根目录执行: flutterfire configure');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase init skipped: $e');
    }
  }
  runApp(
    const ProviderScope(
      child: FilmTraceHKApp(),
    ),
  );
}

class FilmTraceHKApp extends StatelessWidget {
  const FilmTraceHKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '港片映迹 FilmTrace HK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: createAppRouter(),
    );
  }
}
