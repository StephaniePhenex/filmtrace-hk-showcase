import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// 將 RepaintBoundary 渲染結果轉為 JPG 並寫入臨時文件。
/// 用於拍立得成圖的導出。
Future<String?> captureWidgetToJpg(GlobalKey key, {double pixelRatio = 2.0}) async {
  final ro = key.currentContext?.findRenderObject();
  final boundary = ro is RenderRepaintBoundary ? ro : null;
  if (boundary == null) {
    debugPrint('polaroid_builder: RepaintBoundary 未找到');
    return null;
  }

  try {
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      debugPrint('polaroid_builder: toByteData 失敗');
      return null;
    }

    final Uint8List pngBytes = byteData.buffer.asUint8List();
    final img.Image? decoded = img.decodeImage(pngBytes);
    if (decoded == null) {
      debugPrint('polaroid_builder: decodeImage 失敗');
      return null;
    }

    final Uint8List jpgBytes = img.encodeJpg(decoded, quality: 92);
    if (jpgBytes.isEmpty) {
      debugPrint('polaroid_builder: encodeJpg 失敗');
      return null;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/filmtrace_polaroid_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(path);
    await file.writeAsBytes(jpgBytes);
    return path;
  } catch (e, st) {
    debugPrint('polaroid_builder: $e');
    debugPrint('polaroid_builder: $st');
    return null;
  }
}
