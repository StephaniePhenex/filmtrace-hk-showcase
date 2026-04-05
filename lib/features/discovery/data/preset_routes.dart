/// 經典路線預設數據（MVP 本地，無 Firestore 路線集合）。
/// id、名稱、取景地 id 列表、簡短描述。
class PresetRoute {
  const PresetRoute({
    required this.id,
    required this.name,
    required this.locationIds,
    required this.description,
  });

  final String id;
  final String name;
  final List<String> locationIds;
  final String description;

  /// 第一個取景地 id（可選，如需要「直接進首站」時使用）。
  String? get firstLocationId =>
      locationIds.isNotEmpty ? locationIds.first : null;
}

/// MVP 預設經典路線（使用現有 locations 的 id）。
const List<PresetRoute> presetRoutes = [
  PresetRoute(
    id: 'route_chungking',
    name: '重慶森林朝聖',
    locationIds: ['chungking_mansions', 'central_escalator'],
    description: '尖沙咀重慶大廈 → 中環半山扶手電梯',
  ),
  PresetRoute(
    id: 'route_temple',
    name: '廟街夜色',
    locationIds: ['temple_street'],
    description: '油麻地廟街 · 新不了情',
  ),
  PresetRoute(
    id: 'route_comedy',
    name: '喜劇之王經典',
    locationIds: ['duddell_street', 'shek_o'],
    description: '都爹利街石階與煤氣燈 → 石澳健康院',
  ),
];
