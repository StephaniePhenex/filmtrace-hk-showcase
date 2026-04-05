/// 阶段 5.0：相机 → 分享页传参。截图路径 + 可选 locationId（用于拍立得底部文字）。
class SharePayload {
  const SharePayload({
    required this.imagePath,
    this.locationId,
  });

  /// 相机写入的临时 PNG 路径。
  final String imagePath;

  /// 若从「名場面打卡」进入相机则有值；从底部「打卡」进入可为 null。
  final String? locationId;
}
