/// PLAN_8 · 8.6：與 [GoRouter] 對齊的路徑與 name。
///
/// **約定：** 業務參數只走 path / query；[GoRouterState.extra] 僅傳小對象
///（如 `SharePayload`、`FeedPublishPayload`），不傳大圖或冗長 JSON。
abstract final class AppRoutePaths {
  AppRoutePaths._();

  static const map = '/map';
  static const discovery = '/discovery';
  static const camera = '/camera';
  static const feed = '/feed';

  static const location = '/location/:id';
  static const route = '/route/:id';
  static const cameraWithLocation = '/camera/:id';
  static const share = '/share';
  static const person = '/person/:id';
  static const movie = '/movie';

  static const login = '/login';
  static const feedPublish = '/feed/publish';
  static const feedPost = '/feed/post/:id';
  static const profile = '/profile/:uid';
}

/// [GoRoute.name] 與 `context.pushNamed` 用。
abstract final class AppRouteNames {
  AppRouteNames._();

  static const locationDetail = 'locationDetail';
  static const routeDetail = 'routeDetail';
  static const cameraWithLocation = 'cameraWithLocation';
  static const share = 'share';
  static const personDetail = 'personDetail';
  static const movieDetail = 'movieDetail';
  static const login = 'login';
  static const feedPublish = 'feedPublish';
  static const postDetail = 'postDetail';
  static const userFanProfile = 'userFanProfile';
}

/// 帶參數的完整 location（給 `context.push` / `go`）。
abstract final class AppLocations {
  AppLocations._();

  static String location(String id) => '/location/$id';
  static String route(String id) => '/route/$id';
  static String cameraAt(String id) => '/camera/$id';
  static String feedPost(String postId) => '/feed/post/$postId';
  static String profile(String uid) => '/profile/$uid';

  static String movieNamed(String name) =>
      '${AppRoutePaths.movie}?name=${Uri.encodeQueryComponent(name)}';

  /// `/login?redirect=...`（redirect 已 URL 編碼）。
  static String loginRedirect(String redirectPath) =>
      '${AppRoutePaths.login}?redirect=${Uri.encodeComponent(redirectPath)}';
}
