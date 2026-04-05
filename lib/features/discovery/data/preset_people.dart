/// 影人預設數據（MVP 本地，無 Firestore）。
/// 與現有 5 個取景地對應：id、姓名、角色、關聯的 locationIds。
class PresetPerson {
  const PresetPerson({
    required this.id,
    required this.name,
    required this.role,
    required this.locationIds,
  });

  final String id;
  final String name;
  final String role;
  final List<String> locationIds;
}

/// MVP 預設影人（與 preset_routes / locations 對應）。
const List<PresetPerson> presetPeople = [
  PresetPerson(
    id: 'person_wong_kar_wai',
    name: '王家衛',
    role: '導演',
    locationIds: ['chungking_mansions', 'central_escalator'],
  ),
  PresetPerson(
    id: 'person_er_dong_sheng',
    name: '爾冬陞',
    role: '導演',
    locationIds: ['temple_street'],
  ),
  PresetPerson(
    id: 'person_stephen_chow',
    name: '周星馳',
    role: '導演 / 演員',
    locationIds: ['duddell_street', 'shek_o'],
  ),
];
