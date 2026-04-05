/// Demo 階段：按 locationId 使用本地劇照資源，不修改 Firestore / Model。
/// 若某 id 在此映射中，UI 使用 Image.asset；否則使用 Image.network(stillUrl)。
/// 正式環境可刪除本文件並還原各處僅用 Image.network。
const Map<String, String> localStills = {
  'central_escalator': 'assets/stills/central_escalator.jpg',
  'temple_street': 'assets/stills/temple_street.jpg',
  'duddell_street': 'assets/stills/duddell_street.jpg',
  'shek_o': 'assets/stills/shek_o.jpg',
  'chungking_mansions': 'assets/stills/chungking_mansions.jpg',
};
