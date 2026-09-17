import '../models/kanji.dart';
import '../models/vocabulary.dart';
import 'vocabulary_data.dart';

class KanjiData {
  static const List<String> _levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  static List<KanjiItem> getAllKanji() {
    return _levels.expand((level) => getKanjiByLevel(level)).toList();
  }

  static List<KanjiItem> getKanjiByLevel(String level) {
    return [
      ..._baseKanjiForLevel(level),
      ...(_generatedKanjiByLevel[level] ?? const <KanjiItem>[]),
    ];
  }

  static List<VocabularyWord> getPracticeWordsByLevel(
    String level, {
    int limit = 24,
  }) {
    final words = <VocabularyWord>[];
    final seenIds = <String>{};
    final entries = getKanjiByLevel(level);

    for (var i = 0; i < entries.length; i++) {
      final word = _toPracticeWord(entries[i], i);
      if (word.japanese.trim().isEmpty) continue;
      if (seenIds.add(word.id)) {
        words.add(word);
      }
      if (words.length >= limit) break;
    }

    return words;
  }

  static final List<KanjiItem> _n5Kanji = [
    KanjiItem(id: 'k_001', kanji: '日', onyomi: 'ニチ、ジツ', kunyomi: 'ひ、か', vietnamese: 'Nhật, ngày', english: 'sun, day', strokeCount: 4, jlptLevel: 'N5', exampleWords: ['日本', '今日', '毎日'], exampleReadings: ['にほん', 'きょう', 'まいにち'], exampleMeanings: ['Nhật Bản', 'hôm nay', 'mỗi ngày'], radicalMeaning: 'mặt trời'),
    KanjiItem(id: 'k_002', kanji: '月', onyomi: 'ゲツ、ガツ', kunyomi: 'つき', vietnamese: 'Nguyệt, tháng, mặt trăng', english: 'moon, month', strokeCount: 4, jlptLevel: 'N5', exampleWords: ['月曜日', '一月', '月光'], exampleReadings: ['げつようび', 'いちがつ', 'げっこう'], exampleMeanings: ['thứ Hai', 'tháng Một', 'ánh trăng'], radicalMeaning: 'mặt trăng'),
    KanjiItem(id: 'k_003', kanji: '火', onyomi: 'カ', kunyomi: 'ひ', vietnamese: 'Hỏa, lửa', english: 'fire', strokeCount: 4, jlptLevel: 'N5', exampleWords: ['火曜日', '火事', '花火'], exampleReadings: ['かようび', 'かじ', 'はなび'], exampleMeanings: ['thứ Ba', 'hỏa hoạn', 'pháo hoa'], radicalMeaning: 'lửa'),
    KanjiItem(id: 'k_004', kanji: '水', onyomi: 'スイ', kunyomi: 'みず', vietnamese: 'Thủy, nước', english: 'water', strokeCount: 4, jlptLevel: 'N5', exampleWords: ['水曜日', '水道', '水泳'], exampleReadings: ['すいようび', 'すいどう', 'すいえい'], exampleMeanings: ['thứ Tư', 'đường ống nước', 'bơi lội'], radicalMeaning: 'nước'),
    KanjiItem(id: 'k_005', kanji: '木', onyomi: 'モク、ボク', kunyomi: 'き', vietnamese: 'Mộc, cây', english: 'tree, wood', strokeCount: 4, jlptLevel: 'N5', exampleWords: ['木曜日', '木造', '木材'], exampleReadings: ['もくようび', 'もくぞう', 'もくざい'], exampleMeanings: ['thứ Năm', 'bằng gỗ', 'gỗ'], radicalMeaning: 'cây gỗ'),
    KanjiItem(id: 'k_006', kanji: '金', onyomi: 'キン、コン', kunyomi: 'かね', vietnamese: 'Kim, vàng, tiền', english: 'gold, money', strokeCount: 8, jlptLevel: 'N5', exampleWords: ['金曜日', 'お金', '金色'], exampleReadings: ['きんようび', 'おかね', 'きんいろ'], exampleMeanings: ['thứ Sáu', 'tiền', 'màu vàng'], radicalMeaning: 'kim loại vàng'),
    KanjiItem(id: 'k_007', kanji: '土', onyomi: 'ド、ト', kunyomi: 'つち', vietnamese: 'Thổ, đất', english: 'earth, soil', strokeCount: 3, jlptLevel: 'N5', exampleWords: ['土曜日', '土地', '土台'], exampleReadings: ['どようび', 'とち', 'どだい'], exampleMeanings: ['thứ Bảy', 'đất đai', 'nền móng'], radicalMeaning: 'đất'),
    KanjiItem(id: 'k_008', kanji: '山', onyomi: 'サン', kunyomi: 'やま', vietnamese: 'Sơn, núi', english: 'mountain', strokeCount: 3, jlptLevel: 'N5', exampleWords: ['山', '富士山', '山登り'], exampleReadings: ['やま', 'ふじさん', 'やまのぼり'], exampleMeanings: ['núi', 'núi Phú Sĩ', 'leo núi'], radicalMeaning: 'núi'),
    KanjiItem(id: 'k_009', kanji: '川', onyomi: 'セン', kunyomi: 'かわ', vietnamese: 'Xuyên, sông', english: 'river', strokeCount: 3, jlptLevel: 'N5', exampleWords: ['川', '川岸', '小川'], exampleReadings: ['かわ', 'かわぎし', 'おがわ'], exampleMeanings: ['sông', 'bờ sông', 'suối nhỏ'], radicalMeaning: 'sông'),
    KanjiItem(id: 'k_010', kanji: '人', onyomi: 'ジン、ニン', kunyomi: 'ひと', vietnamese: 'Nhân, người', english: 'person, people', strokeCount: 2, jlptLevel: 'N5', exampleWords: ['人', '日本人', '一人'], exampleReadings: ['ひと', 'にほんじん', 'ひとり'], exampleMeanings: ['người', 'người Nhật', 'một mình'], radicalMeaning: 'người'),
    KanjiItem(id: 'k_011', kanji: '口', onyomi: 'コウ、ク', kunyomi: 'くち', vietnamese: 'Khẩu, miệng', english: 'mouth, opening', strokeCount: 3, jlptLevel: 'N5', exampleWords: ['口', '入口', '出口'], exampleReadings: ['くち', 'いりぐち', 'でぐち'], exampleMeanings: ['miệng', 'lối vào', 'lối ra'], radicalMeaning: 'miệng'),
    KanjiItem(id: 'k_012', kanji: '手', onyomi: 'シュ', kunyomi: 'て', vietnamese: 'Thủ, tay', english: 'hand', strokeCount: 4, jlptLevel: 'N5', exampleWords: ['手', '手紙', '上手'], exampleReadings: ['て', 'てがみ', 'じょうず'], exampleMeanings: ['tay', 'thư', 'giỏi'], radicalMeaning: 'bàn tay'),
    KanjiItem(id: 'k_013', kanji: '目', onyomi: 'モク、ボク', kunyomi: 'め', vietnamese: 'Mục, mắt', english: 'eye', strokeCount: 5, jlptLevel: 'N5', exampleWords: ['目', '目的', '注目'], exampleReadings: ['め', 'もくてき', 'ちゅうもく'], exampleMeanings: ['mắt', 'mục đích', 'chú ý'], radicalMeaning: 'mắt'),
    KanjiItem(id: 'k_014', kanji: '耳', onyomi: 'ジ', kunyomi: 'みみ', vietnamese: 'Nhĩ, tai', english: 'ear', strokeCount: 6, jlptLevel: 'N5', exampleWords: ['耳', '耳元', '耳鳴り'], exampleReadings: ['みみ', 'みみもと', 'みみなり'], exampleMeanings: ['tai', 'bên tai', 'ù tai'], radicalMeaning: 'tai'),
    KanjiItem(id: 'k_015', kanji: '大', onyomi: 'ダイ、タイ', kunyomi: 'おお', vietnamese: 'Đại, lớn', english: 'big, large', strokeCount: 3, jlptLevel: 'N5', exampleWords: ['大きい', '大学', '大切'], exampleReadings: ['おおきい', 'だいがく', 'たいせつ'], exampleMeanings: ['to lớn', 'đại học', 'quan trọng'], radicalMeaning: 'to lớn'),
    KanjiItem(id: 'k_016', kanji: '小', onyomi: 'ショウ', kunyomi: 'ちい、こ', vietnamese: 'Tiểu, nhỏ', english: 'small, little', strokeCount: 3, jlptLevel: 'N5', exampleWords: ['小さい', '小学校', '小説'], exampleReadings: ['ちいさい', 'しょうがっこう', 'しょうせつ'], exampleMeanings: ['nhỏ', 'tiểu học', 'tiểu thuyết'], radicalMeaning: 'nhỏ'),
    KanjiItem(id: 'k_017', kanji: '中', onyomi: 'チュウ', kunyomi: 'なか', vietnamese: 'Trung, giữa', english: 'middle, center', strokeCount: 4, jlptLevel: 'N5', exampleWords: ['中', '中学校', '集中'], exampleReadings: ['なか', 'ちゅうがっこう', 'しゅうちゅう'], exampleMeanings: ['giữa', 'trung học cơ sở', 'tập trung'], radicalMeaning: 'ở giữa'),
    KanjiItem(id: 'k_018', kanji: '上', onyomi: 'ジョウ、ショウ', kunyomi: 'うえ、あが', vietnamese: 'Thượng, trên', english: 'above, up', strokeCount: 3, jlptLevel: 'N5', exampleWords: ['上', '上手', '上がる'], exampleReadings: ['うえ', 'じょうず', 'あがる'], exampleMeanings: ['phía trên', 'giỏi', 'đi lên'], radicalMeaning: 'trên'),
    KanjiItem(id: 'k_019', kanji: '下', onyomi: 'カ、ゲ', kunyomi: 'した、くだ', vietnamese: 'Hạ, dưới', english: 'below, down', strokeCount: 3, jlptLevel: 'N5', exampleWords: ['下', '地下', '下がる'], exampleReadings: ['した', 'ちか', 'さがる'], exampleMeanings: ['phía dưới', 'ngầm', 'giảm xuống'], radicalMeaning: 'dưới'),
    KanjiItem(id: 'k_020', kanji: '本', onyomi: 'ホン', kunyomi: 'もと', vietnamese: 'Bản, sách gốc', english: 'book, origin', strokeCount: 5, jlptLevel: 'N5', exampleWords: ['本', '日本', '本当'], exampleReadings: ['ほん', 'にほん', 'ほんとう'], exampleMeanings: ['sách', 'Nhật Bản', 'thật sự'], radicalMeaning: 'gốc rễ'),
    KanjiItem(id: 'k_021', kanji: '一', onyomi: 'イチ、イツ', kunyomi: 'ひと', vietnamese: 'Nhất, một', english: 'one', strokeCount: 1, jlptLevel: 'N5', exampleWords: ['一', '一日', '一番'], exampleReadings: ['ひとつ', 'いちにち', 'いちばん'], exampleMeanings: ['một', 'một ngày', 'số một'], radicalMeaning: 'số một'),
    KanjiItem(id: 'k_022', kanji: '二', onyomi: 'ニ', kunyomi: 'ふた', vietnamese: 'Nhị, hai', english: 'two', strokeCount: 2, jlptLevel: 'N5', exampleWords: ['二', '二日', '二月'], exampleReadings: ['ふたつ', 'ふつか', 'にがつ'], exampleMeanings: ['hai', 'ngày 2', 'tháng 2'], radicalMeaning: 'số hai'),
    KanjiItem(id: 'k_023', kanji: '三', onyomi: 'サン', kunyomi: 'み', vietnamese: 'Tam, ba', english: 'three', strokeCount: 3, jlptLevel: 'N5', exampleWords: ['三', '三日', '三月'], exampleReadings: ['みっつ', 'みっか', 'さんがつ'], exampleMeanings: ['ba', 'ngày 3', 'tháng 3'], radicalMeaning: 'số ba'),
    KanjiItem(id: 'k_024', kanji: '四', onyomi: 'シ', kunyomi: 'よ', vietnamese: 'Tứ, bốn', english: 'four', strokeCount: 5, jlptLevel: 'N5', exampleWords: ['四', '四日', '四月'], exampleReadings: ['よっつ', 'よっか', 'しがつ'], exampleMeanings: ['bốn', 'ngày 4', 'tháng 4'], radicalMeaning: 'số bốn'),
    KanjiItem(id: 'k_025', kanji: '五', onyomi: 'ゴ', kunyomi: 'いつ', vietnamese: 'Ngũ, năm', english: 'five', strokeCount: 4, jlptLevel: 'N5', exampleWords: ['五', '五日', '五月'], exampleReadings: ['いつつ', 'いつか', 'ごがつ'], exampleMeanings: ['năm', 'ngày 5', 'tháng 5'], radicalMeaning: 'số năm'),
    KanjiItem(id: 'k_026', kanji: '学', onyomi: 'ガク', kunyomi: 'まな', vietnamese: 'Học, học tập', english: 'study, learning', strokeCount: 8, jlptLevel: 'N5', exampleWords: ['学校', '大学', '学生'], exampleReadings: ['がっこう', 'だいがく', 'がくせい'], exampleMeanings: ['trường học', 'đại học', 'học sinh'], radicalMeaning: 'học hành'),
    KanjiItem(id: 'k_027', kanji: '校', onyomi: 'コウ', kunyomi: '', vietnamese: 'Hiệu, trường', english: 'school', strokeCount: 10, jlptLevel: 'N5', exampleWords: ['学校', '高校', '校長'], exampleReadings: ['がっこう', 'こうこう', 'こうちょう'], exampleMeanings: ['trường học', 'trung học', 'hiệu trưởng'], radicalMeaning: 'trường học'),
    KanjiItem(id: 'k_028', kanji: '先', onyomi: 'セン', kunyomi: 'さき', vietnamese: 'Tiên, trước', english: 'previous, ahead', strokeCount: 6, jlptLevel: 'N5', exampleWords: ['先生', '先週', '先輩'], exampleReadings: ['せんせい', 'せんしゅう', 'せんぱい'], exampleMeanings: ['giáo viên', 'tuần trước', 'đàn anh'], radicalMeaning: 'trước'),
    KanjiItem(id: 'k_029', kanji: '生', onyomi: 'セイ、ショウ', kunyomi: 'い、う、なま', vietnamese: 'Sinh, sống', english: 'life, birth', strokeCount: 5, jlptLevel: 'N5', exampleWords: ['生徒', '学生', '生活'], exampleReadings: ['せいと', 'がくせい', 'せいかつ'], exampleMeanings: ['học sinh', 'sinh viên', 'cuộc sống'], radicalMeaning: 'sinh ra'),
    KanjiItem(id: 'k_030', kanji: '年', onyomi: 'ネン', kunyomi: 'とし', vietnamese: 'Niên, năm', english: 'year', strokeCount: 6, jlptLevel: 'N5', exampleWords: ['今年', '来年', '去年'], exampleReadings: ['ことし', 'らいねん', 'きょねん'], exampleMeanings: ['năm nay', 'năm sau', 'năm ngoái'], radicalMeaning: 'năm'),
    KanjiItem(id: 'k_031', kanji: '国', onyomi: 'コク', kunyomi: 'くに', vietnamese: 'Quốc, nước', english: 'country', strokeCount: 8, jlptLevel: 'N5', exampleWords: ['国', '外国', '外国語'], exampleReadings: ['くに', 'がいこく', 'がいこくご'], exampleMeanings: ['nước', 'nước ngoài', 'ngoại ngữ'], radicalMeaning: 'quốc gia'),
    KanjiItem(id: 'k_032', kanji: '語', onyomi: 'ゴ', kunyomi: 'かた', vietnamese: 'Ngữ, ngôn ngữ', english: 'language, word', strokeCount: 14, jlptLevel: 'N5', exampleWords: ['日本語', '英語', '語る'], exampleReadings: ['にほんご', 'えいご', 'かたる'], exampleMeanings: ['tiếng Nhật', 'tiếng Anh', 'kể chuyện'], radicalMeaning: 'ngôn ngữ'),
    KanjiItem(id: 'k_033', kanji: '父', onyomi: 'フ', kunyomi: 'ちち', vietnamese: 'Phụ, cha', english: 'father', strokeCount: 4, jlptLevel: 'N5', exampleWords: ['父', 'お父さん', '父親'], exampleReadings: ['ちち', 'おとうさん', 'ちちおや'], exampleMeanings: ['bố (khiêm tốn)', 'bố', 'cha'], radicalMeaning: 'cha'),
    KanjiItem(id: 'k_034', kanji: '母', onyomi: 'ボ', kunyomi: 'はは', vietnamese: 'Mẫu, mẹ', english: 'mother', strokeCount: 5, jlptLevel: 'N5', exampleWords: ['母', 'お母さん', '母親'], exampleReadings: ['はは', 'おかあさん', 'ははおや'], exampleMeanings: ['mẹ (khiêm tốn)', 'mẹ', 'mẹ'], radicalMeaning: 'mẹ'),
    KanjiItem(id: 'k_035', kanji: '女', onyomi: 'ジョ、ニョ', kunyomi: 'おんな、め', vietnamese: 'Nữ, phụ nữ', english: 'woman, female', strokeCount: 3, jlptLevel: 'N5', exampleWords: ['女', '女性', '女の子'], exampleReadings: ['おんな', 'じょせい', 'おんなのこ'], exampleMeanings: ['phụ nữ', 'phụ nữ', 'con gái'], radicalMeaning: 'nữ giới'),
    KanjiItem(id: 'k_036', kanji: '男', onyomi: 'ダン、ナン', kunyomi: 'おとこ', vietnamese: 'Nam, đàn ông', english: 'man, male', strokeCount: 7, jlptLevel: 'N5', exampleWords: ['男', '男性', '男の子'], exampleReadings: ['おとこ', 'だんせい', 'おとこのこ'], exampleMeanings: ['đàn ông', 'nam giới', 'con trai'], radicalMeaning: 'nam giới'),
    KanjiItem(id: 'k_037', kanji: '子', onyomi: 'シ、ス', kunyomi: 'こ', vietnamese: 'Tử, trẻ em', english: 'child, kid', strokeCount: 3, jlptLevel: 'N5', exampleWords: ['子供', '子猫', '男の子'], exampleReadings: ['こども', 'こねこ', 'おとこのこ'], exampleMeanings: ['trẻ em', 'mèo con', 'con trai'], radicalMeaning: 'trẻ em'),
    KanjiItem(id: 'k_038', kanji: '白', onyomi: 'ハク、ビャク', kunyomi: 'しろ', vietnamese: 'Bạch, trắng', english: 'white', strokeCount: 5, jlptLevel: 'N5', exampleWords: ['白い', '白紙', '告白'], exampleReadings: ['しろい', 'はくし', 'こくはく'], exampleMeanings: ['màu trắng', 'giấy trắng', 'tỏ tình'], radicalMeaning: 'màu trắng'),
    KanjiItem(id: 'k_039', kanji: '気', onyomi: 'キ、ケ', kunyomi: '', vietnamese: 'Khí, tinh thần', english: 'spirit, energy', strokeCount: 6, jlptLevel: 'N5', exampleWords: ['元気', '天気', '気持ち'], exampleReadings: ['げんき', 'てんき', 'きもち'], exampleMeanings: ['khỏe mạnh', 'thời tiết', 'cảm xúc'], radicalMeaning: 'khí, tinh thần'),
    KanjiItem(id: 'k_040', kanji: '車', onyomi: 'シャ', kunyomi: 'くるま', vietnamese: 'Xa, xe', english: 'car, vehicle', strokeCount: 7, jlptLevel: 'N5', exampleWords: ['車', '電車', '自転車'], exampleReadings: ['くるま', 'でんしゃ', 'じてんしゃ'], exampleMeanings: ['ô tô', 'tàu điện', 'xe đạp'], radicalMeaning: 'xe cộ'),
  ];

  static final List<KanjiItem> _n4Kanji = [
    KanjiItem(id: 'k_n4_001', kanji: '体', onyomi: 'タイ、テイ', kunyomi: 'からだ', vietnamese: 'Thể, cơ thể', english: 'body', strokeCount: 7, jlptLevel: 'N4', exampleWords: ['体', '体力', '体育'], exampleReadings: ['からだ', 'たいりょく', 'たいいく'], exampleMeanings: ['cơ thể', 'thể lực', 'thể dục'], radicalMeaning: 'cơ thể'),
    KanjiItem(id: 'k_n4_002', kanji: '心', onyomi: 'シン', kunyomi: 'こころ', vietnamese: 'Tâm, tâm hồn', english: 'heart, mind', strokeCount: 4, jlptLevel: 'N4', exampleWords: ['心', '心配', '安心'], exampleReadings: ['こころ', 'しんぱい', 'あんしん'], exampleMeanings: ['tâm hồn', 'lo lắng', 'an tâm'], radicalMeaning: 'trái tim'),
    KanjiItem(id: 'k_n4_003', kanji: '力', onyomi: 'リョク、リキ', kunyomi: 'ちから', vietnamese: 'Lực, sức mạnh', english: 'power, force', strokeCount: 2, jlptLevel: 'N4', exampleWords: ['力', '努力', '体力'], exampleReadings: ['ちから', 'どりょく', 'たいりょく'], exampleMeanings: ['sức mạnh', 'nỗ lực', 'thể lực'], radicalMeaning: 'sức mạnh'),
    KanjiItem(id: 'k_n4_004', kanji: '活', onyomi: 'カツ', kunyomi: '', vietnamese: 'Hoạt, sống động', english: 'lively, active', strokeCount: 9, jlptLevel: 'N4', exampleWords: ['生活', '活動', '活躍'], exampleReadings: ['せいかつ', 'かつどう', 'かつやく'], exampleMeanings: ['cuộc sống', 'hoạt động', 'hoạt động tích cực'], radicalMeaning: 'sống động'),
    KanjiItem(id: 'k_n4_005', kanji: '意', onyomi: 'イ', kunyomi: '', vietnamese: 'Ý, ý nghĩa', english: 'meaning, idea', strokeCount: 13, jlptLevel: 'N4', exampleWords: ['意見', '意味', '注意'], exampleReadings: ['いけん', 'いみ', 'ちゅうい'], exampleMeanings: ['ý kiến', 'ý nghĩa', 'chú ý'], radicalMeaning: 'ý nghĩa'),
    KanjiItem(id: 'k_n4_006', kanji: '味', onyomi: 'ミ', kunyomi: 'あじ', vietnamese: 'Vị, hương vị', english: 'taste, flavor', strokeCount: 8, jlptLevel: 'N4', exampleWords: ['味', '意味', '趣味'], exampleReadings: ['あじ', 'いみ', 'しゅみ'], exampleMeanings: ['mùi vị', 'ý nghĩa', 'sở thích'], radicalMeaning: 'vị giác'),
    KanjiItem(id: 'k_n4_007', kanji: '知', onyomi: 'チ', kunyomi: 'し', vietnamese: 'Tri, biết', english: 'know, knowledge', strokeCount: 8, jlptLevel: 'N4', exampleWords: ['知る', '知識', '知らせ'], exampleReadings: ['しる', 'ちしき', 'しらせ'], exampleMeanings: ['biết', 'kiến thức', 'thông báo'], radicalMeaning: 'kiến thức'),
    KanjiItem(id: 'k_n4_008', kanji: '思', onyomi: 'シ', kunyomi: 'おも', vietnamese: 'Tư, suy nghĩ', english: 'think, thought', strokeCount: 9, jlptLevel: 'N4', exampleWords: ['思う', '思い出', '思考'], exampleReadings: ['おもう', 'おもいで', 'しこう'], exampleMeanings: ['nghĩ', 'kỷ niệm', 'suy nghĩ'], radicalMeaning: 'suy nghĩ'),
    KanjiItem(id: 'k_n4_009', kanji: '声', onyomi: 'セイ、ショウ', kunyomi: 'こえ', vietnamese: 'Thanh, giọng', english: 'voice, sound', strokeCount: 7, jlptLevel: 'N4', exampleWords: ['声', '大声', '声援'], exampleReadings: ['こえ', 'おおごえ', 'せいえん'], exampleMeanings: ['giọng nói', 'giọng to', 'cổ vũ'], radicalMeaning: 'giọng nói'),
    KanjiItem(id: 'k_n4_010', kanji: '色', onyomi: 'ショク、シキ', kunyomi: 'いろ', vietnamese: 'Sắc, màu sắc', english: 'color', strokeCount: 6, jlptLevel: 'N4', exampleWords: ['色', '特色', '景色'], exampleReadings: ['いろ', 'とくしょく', 'けしき'], exampleMeanings: ['màu sắc', 'đặc điểm', 'phong cảnh'], radicalMeaning: 'màu sắc'),
  ];

  static final List<KanjiItem> _n3Kanji = [];
  static final List<KanjiItem> _n2Kanji = [];
  static final List<KanjiItem> _n1Kanji = [];

  static final Map<String, List<KanjiItem>> _generatedKanjiByLevel = {
    for (final level in _levels) level: _buildGeneratedKanjiForLevel(level),
  };

  static List<KanjiItem> _baseKanjiForLevel(String level) {
    switch (level) {
      case 'N5':
        return _n5Kanji;
      case 'N4':
        return _n4Kanji;
      case 'N3':
        return _n3Kanji;
      case 'N2':
        return _n2Kanji;
      case 'N1':
        return _n1Kanji;
      default:
        return _n5Kanji;
    }
  }

  static List<KanjiItem> _buildGeneratedKanjiForLevel(String level) {
    final seenJapanese = <String>{};
    final kanjiRegex = RegExp(r'[一-鿿]');

    return VocabularyData.getWordsByLevel(level)
        .where((word) => kanjiRegex.hasMatch(word.japanese))
        .where((word) => seenJapanese.add(word.japanese))
        .take(100)
        .toList()
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key + 1;
      final word = entry.value;
      return KanjiItem(
        id: 'kanji_vocab_${level.toLowerCase()}_${index.toString().padLeft(3, '0')}',
        kanji: word.japanese,
        onyomi: word.hiragana,
        kunyomi: word.romaji,
        vietnamese: word.vietnamese,
        english: word.english,
        strokeCount: word.japanese.runes.length,
        jlptLevel: level,
        exampleWords: [word.japanese],
        exampleReadings: [word.hiragana],
        exampleMeanings: [word.vietnamese],
        radicalMeaning: 'Từ vựng Kanji • ${word.category}',
      );
    }).toList();
  }

  static VocabularyWord _toPracticeWord(KanjiItem item, int index) {
    final japanese = _bestExampleWord(item);
    final vietnamese = _bestMeaning(item);
    final reading = item.exampleReadings.isNotEmpty
        ? item.exampleReadings.first
        : (item.onyomi.isNotEmpty ? item.onyomi : item.kunyomi);
    final examples = item.exampleWords.isNotEmpty
        ? item.exampleWords.take(2).toList()
        : [item.kanji];
    final translations = item.exampleMeanings.isNotEmpty
        ? item.exampleMeanings.take(2).toList()
        : [vietnamese];

    return VocabularyWord(
      id: 'kanji_practice_${item.id}_$index',
      japanese: japanese,
      hiragana: reading,
      romaji: item.kunyomi.isNotEmpty ? item.kunyomi : reading,
      vietnamese: vietnamese,
      english: item.english,
      jlptLevel: item.jlptLevel,
      category: 'kanji',
      exampleSentences: examples,
      exampleTranslations: translations,
    );
  }

  static String _bestExampleWord(KanjiItem item) {
    if (item.exampleWords.isNotEmpty) return item.exampleWords.first;
    return item.kanji;
  }

  static String _bestMeaning(KanjiItem item) {
    if (item.exampleMeanings.isNotEmpty) return item.exampleMeanings.first;
    return item.vietnamese;
  }

  static List<KanjiItem> search(String query) {
    if (query.isEmpty) return [];
    final normalized = query.toLowerCase();
    return getAllKanji().where((k) {
      return k.kanji.contains(query) ||
          k.onyomi.contains(query) ||
          k.kunyomi.contains(query) ||
          k.vietnamese.toLowerCase().contains(normalized) ||
          k.english.toLowerCase().contains(normalized) ||
          k.exampleWords.any((word) => word.contains(query)) ||
          k.exampleMeanings.any((meaning) => meaning.toLowerCase().contains(normalized));
    }).toList();
  }
}
