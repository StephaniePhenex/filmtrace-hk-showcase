import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:filmtrace_hk/app_shell.dart';
import 'package:filmtrace_hk/core/routing/app_routes.dart';
import 'package:filmtrace_hk/core/theme/app_colors.dart';
import 'package:filmtrace_hk/features/camera/camera_page.dart';
import 'package:filmtrace_hk/features/discovery/discovery_page.dart';
import 'package:filmtrace_hk/features/discovery/route_detail_page.dart';
import 'package:filmtrace_hk/features/location_detail/location_detail_page.dart';
import 'package:filmtrace_hk/features/map/map_page.dart';
import 'package:filmtrace_hk/features/auth/login_page.dart';
import 'package:filmtrace_hk/features/feed/feed_page.dart';
import 'package:filmtrace_hk/features/feed/feed_publish_page.dart';
import 'package:filmtrace_hk/features/feed/feed_publish_payload.dart';
import 'package:filmtrace_hk/features/feed/post_detail_page.dart';
import 'package:filmtrace_hk/features/feed/user_fan_profile_page.dart';
import 'package:filmtrace_hk/features/share/share_page.dart';
import 'package:filmtrace_hk/features/share/share_payload.dart';
import 'package:filmtrace_hk/features/discovery/movie_detail_page.dart';
import 'package:filmtrace_hk/features/discovery/person_detail_page.dart';

/// 根 Navigator key，用于 /location/:id 等脱离 Shell 的页面
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// 应用路由表：底部导航 Shell + 地点详情页（阶段 2.0）
/// PLAN_8 · 8.6：影迷圈相關路徑見 [AppRoutePaths] / [AppLocations]；全屏頁使用 [parentNavigatorKey]。
GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutePaths.map,
    redirect: (BuildContext context, GoRouterState state) {
      if (state.matchedLocation == '/' || state.matchedLocation.isEmpty) {
        return AppRoutePaths.map;
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.map,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: MapPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.discovery,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DiscoveryPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.camera,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CameraPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.feed,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FeedPage(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutePaths.location,
        name: AppRouteNames.locationDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id'] ?? '';
          return LocationDetailPage(locationId: id);
        },
      ),
      GoRoute(
        path: AppRoutePaths.route,
        name: AppRouteNames.routeDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id'] ?? '';
          return RouteDetailPage(routeId: id);
        },
      ),
      GoRoute(
        path: AppRoutePaths.cameraWithLocation,
        name: AppRouteNames.cameraWithLocation,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id'] ?? '';
          return CameraPage(locationId: id.isEmpty ? null : id);
        },
      ),
      GoRoute(
        path: AppRoutePaths.share,
        name: AppRouteNames.share,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final SharePayload? payload = state.extra is SharePayload
              ? state.extra as SharePayload
              : (state.extra is String
                  ? SharePayload(
                      imagePath: state.extra as String,
                      locationId: null,
                    )
                  : null);
          return SharePage(payload: payload);
        },
      ),
      GoRoute(
        path: AppRoutePaths.person,
        name: AppRouteNames.personDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id'] ?? '';
          return PersonDetailPage(personId: id);
        },
      ),
      GoRoute(
        path: AppRoutePaths.movie,
        name: AppRouteNames.movieDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final name = state.uri.queryParameters['name'] ?? '';
          return MovieDetailPage(movieName: name);
        },
      ),
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final redirect =
              state.uri.queryParameters['redirect'] ?? AppRoutePaths.feed;
          return LoginPage(redirectPath: redirect);
        },
      ),
      GoRoute(
        path: AppRoutePaths.feedPublish,
        name: AppRouteNames.feedPublish,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra;
          final payload = extra is FeedPublishPayload ? extra : null;
          return FeedPublishPage(payload: payload);
        },
      ),
      GoRoute(
        path: AppRoutePaths.feedPost,
        name: AppRouteNames.postDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id'] ?? '';
          return PostDetailPage(postId: id);
        },
      ),
      GoRoute(
        path: AppRoutePaths.profile,
        name: AppRouteNames.userFanProfile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final uid = state.pathParameters['uid'] ?? '';
          return UserFanProfilePage(uid: uid);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '未找到頁面：${state.matchedLocation}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.hintText,
                ),
          ),
        ),
      ),
    ),
  );
}
