// 1.5.2 種子入口：先寫入 5 個取景地到 Firestore，再啟動 App。
// 運行（需先完成 1.5.1）：flutter run -t lib/main_seed.dart --dart-define=MAPBOX_ACCESS_TOKEN=pk.xxx

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:filmtrace_hk/core/theme/app_theme.dart';
import 'package:filmtrace_hk/core/routing/app_router.dart';
import 'firebase_options.dart';

const String _collectionId = 'locations';

final _locations = [
  {'name': '中環半山扶手電梯', 'movie_name': '重慶森林', 'latitude': 22.2819, 'longitude': 114.1548, 'quote': '那個下午我做了個夢，我好像去了他家。'},
  {'name': '油麻地廟街', 'movie_name': '新不了情', 'latitude': 22.3094, 'longitude': 114.1695, 'quote': '如果人生最壞只是死亡，生活中怎會有解決不了的難題。'},
  {'name': '都爹利街石階與煤氣燈', 'movie_name': '喜劇之王', 'latitude': 22.2810, 'longitude': 114.1542, 'quote': '我養你啊。'},
  {'name': '石澳健康院', 'movie_name': '喜劇之王', 'latitude': 22.2362, 'longitude': 114.2554, 'quote': '努力！奮鬥！'},
  {'name': '尖沙咀重慶大廈一帶', 'movie_name': '重慶森林', 'latitude': 22.2974, 'longitude': 114.1716, 'quote': '我們最接近的時候，我跟她之間的距離只有0.01公分。'},
];

const _docIds = ['central_escalator', 'temple_street', 'duddell_street', 'shek_o', 'chungking_mansions'];

Future<void> _seedFirestore() async {
  final firestore = FirebaseFirestore.instance;
  for (var i = 0; i < _docIds.length; i++) {
    await firestore.collection(_collectionId).doc(_docIds[i]).set(_locations[i]);
  }
  if (kDebugMode) debugPrint('Firestore: 已寫入 5 個取景地到 $_collectionId');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const String mapboxToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN', defaultValue: '');
  if (mapboxToken.isNotEmpty) MapboxOptions.setAccessToken(mapboxToken);

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await _seedFirestore();
  } on UnsupportedError catch (_) {
    if (kDebugMode) debugPrint('Firebase 未配置，跳過種子。請執行: flutterfire configure');
    try {
      await Firebase.initializeApp();
    } catch (_) {}
  } catch (e) {
    if (kDebugMode) debugPrint('Firebase/種子 失敗: $e');
    try {
      await Firebase.initializeApp();
    } catch (_) {}
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
