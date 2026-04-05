import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmtrace_hk/core/data/location_model.dart';
import 'package:filmtrace_hk/core/data/location_repository.dart';
import 'package:filmtrace_hk/features/discovery/data/preset_people.dart';
import 'package:filmtrace_hk/features/discovery/data/preset_routes.dart';

/// 用於搜索匹配的歸一化：去除《》等標點，簡體轉繁體（常見字），便於「重庆森林」匹配「重慶森林」。
String _normalizeForSearch(String s) {
  String t = s
      .replaceAll('《', '')
      .replaceAll('》', '')
      .replaceAll('「', '')
      .replaceAll('」', '')
      .trim()
      .toLowerCase();
  const Map<String, String> s2t = {
    '庆': '慶', '国': '國', '会': '會', '发': '發', '时': '時',
    '对': '對', '说': '說', '经': '經', '过': '過', '还': '還',
    '这': '這', '来': '來', '们': '們', '为': '為', '个': '個',
    '样': '樣', '无': '無', '爱': '愛', '见': '見', '树': '樹',
    '戏': '戲', '梦': '夢', '剧': '劇', '难': '難', '题': '題',
  };
  final sb = StringBuffer();
  for (final rune in t.runes) {
    final c = String.fromCharCode(rune);
    sb.write(s2t[c] ?? c);
  }
  return sb.toString();
}

/// 發現頁取景地列表：從 Repository 拉取，UI 僅 ref.watch，不直接調 Repository。
final discoveryLocationsProvider =
    FutureProvider.autoDispose<List<LocationModel>>((ref) async {
  return LocationRepository.getLocations();
});

/// 搜索框輸入內容（方案 A：客戶端過濾，邏輯在 Provider）。
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// 搜索結果：依 searchQuery 過濾 discoveryLocations，按 name / movieName 包含匹配。
/// 支持簡繁對照與去除《》標點；query 為空時返回空列表。
final searchResultsProvider = Provider.autoDispose<List<LocationModel>>((ref) {
  final rawQuery = ref.watch(searchQueryProvider).trim();
  if (rawQuery.isEmpty) return [];
  final query = _normalizeForSearch(rawQuery);
  final asyncLocations = ref.watch(discoveryLocationsProvider);
  return asyncLocations.when(
    data: (list) {
      return list
          .where((l) {
            final nameNorm = _normalizeForSearch(l.name);
            final movieNorm = _normalizeForSearch(l.movieName);
            return nameNorm.contains(query) || movieNorm.contains(query);
          })
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// 經典路線預設列表（MVP 本地數據，無 Firestore）。
final presetRoutesProvider = Provider<List<PresetRoute>>((ref) {
  return presetRoutes;
});

/// 單條路線（按 id），供路線詳情頁使用。
final routeDetailProvider =
    Provider.autoDispose.family<PresetRoute?, String>((ref, routeId) {
  final routes = ref.watch(presetRoutesProvider);
  try {
    return routes.firstWhere((r) => r.id == routeId);
  } catch (_) {
    return null;
  }
});

/// 路線各站點詳情（按 routeId 拉取各 locationId 對應的 LocationModel，保持順序）。
final routeStopsProvider =
    FutureProvider.autoDispose.family<List<LocationModel>, String>(
        (ref, routeId) async {
  final route = ref.watch(routeDetailProvider(routeId));
  if (route == null || route.locationIds.isEmpty) return [];
  final list = <LocationModel>[];
  for (final id in route.locationIds) {
    final loc = await LocationRepository.getLocationById(id);
    if (loc != null) list.add(loc);
  }
  return list;
});

// ----- 階段 7：影人、電影、打卡地關係 -----

/// 影人預設列表。
final presetPeopleProvider = Provider<List<PresetPerson>>((ref) {
  return presetPeople;
});

/// 單條影人（按 id）。
final personDetailProvider =
    Provider.autoDispose.family<PresetPerson?, String>((ref, personId) {
  final list = ref.watch(presetPeopleProvider);
  try {
    return list.firstWhere((p) => p.id == personId);
  } catch (_) {
    return null;
  }
});

/// 打卡地 → 影人：該地點關聯的影人列表（locationIds 包含 locationId）。
final peopleAtLocationProvider =
    Provider.autoDispose.family<List<PresetPerson>, String>((ref, locationId) {
  final list = ref.watch(presetPeopleProvider);
  return list
      .where((p) => p.locationIds.contains(locationId))
      .toList();
});

/// 影人 → 取景地：該影人關聯的 LocationModel 列表（保持 locationIds 順序）。
final personDetailLocationsProvider =
    FutureProvider.autoDispose.family<List<LocationModel>, String>(
        (ref, personId) async {
  final person = ref.watch(personDetailProvider(personId));
  if (person == null || person.locationIds.isEmpty) return [];
  final list = <LocationModel>[];
  for (final id in person.locationIds) {
    final loc = await LocationRepository.getLocationById(id);
    if (loc != null) list.add(loc);
  }
  return list;
});

/// 影人 → 涉及電影：從關聯取景地的 movieName 去重、排序。
final personDetailMoviesProvider =
    Provider.autoDispose.family<List<String>, String>((ref, personId) {
  final asyncLocations = ref.watch(personDetailLocationsProvider(personId));
  return asyncLocations.when(
    data: (locations) {
      final names = locations.map((l) => l.movieName).toSet().toList();
      names.sort();
      return names;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// 電影 → 取景地：按電影名篩選（movieName 為已解碼的電影名）。
final movieDetailLocationsProvider =
    FutureProvider.autoDispose.family<List<LocationModel>, String>(
        (ref, movieName) async {
  final all = await LocationRepository.getLocations();
  return all.where((l) => l.movieName == movieName).toList();
});

// ----- 發現頁「電影」Tab：海報列表 -----

/// 已收藏的電影名集合（點擊海報卡愛心可切換，僅內存，重啟後清空）。
final favoriteMovieNamesProvider =
    StateProvider<Set<String>>((ref) => <String>{});

/// 發現頁電影項：電影名、首張劇照用於海報、占位評分。
class DiscoveryMovieItem {
  const DiscoveryMovieItem({
    required this.movieName,
    this.posterStillUrl,
    this.posterLocationId,
    this.rating = 7.5,
  });
  final String movieName;
  final String? posterStillUrl;
  final String? posterLocationId;
  final double rating;
}

/// 發現頁電影列表：從取景地按 movieName 聚合，每部電影取第一個取景地的劇照作海報圖。
final discoveryMoviesProvider =
    FutureProvider.autoDispose<List<DiscoveryMovieItem>>((ref) async {
  final locations = await LocationRepository.getLocations();
  final byMovie = <String, List<LocationModel>>{};
  for (final loc in locations) {
    byMovie.putIfAbsent(loc.movieName, () => []).add(loc);
  }
  return byMovie.entries.map((e) {
    final first = e.value.first;
    return DiscoveryMovieItem(
      movieName: e.key,
      posterStillUrl: first.stillUrl,
      posterLocationId: first.id,
      rating: 7.5,
    );
  }).toList();
});
