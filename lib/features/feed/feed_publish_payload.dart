/// 分享頁 → 發帖頁路由 [extra]（PLAN_8 · 8.2）。
class FeedPublishPayload {
  const FeedPublishPayload({
    required this.imagePath,
    required this.locationId,
    required this.movieName,
    this.quote,
    this.locationLabel,
  });

  final String imagePath;
  final String locationId;
  final String movieName;
  final String? quote;
  /// 取景地展示用（如「中環碼頭」）；非 Firestore 字段。
  final String? locationLabel;
}
