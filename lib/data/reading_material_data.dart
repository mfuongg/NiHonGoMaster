import '../models/reading_material.dart';

class _LevelProfile {
  final String level;
  final String audience;
  final String grammarFocus;
  final String styleLabel;
  final int minutesBase;

  const _LevelProfile({
    required this.level,
    required this.audience,
    required this.grammarFocus,
    required this.styleLabel,
    required this.minutesBase,
  });
}

const Map<String, _LevelProfile> _profiles = {
  'N5': _LevelProfile(
    level: 'N5',
    audience: 'người mới bắt đầu',
    grammarFocus: 'câu ngắn, từ cơ bản và cấu trúc rất dễ hiểu',
    styleLabel: 'Dễ đọc · câu ngắn',
    minutesBase: 4,
  ),
  'N4': _LevelProfile(
    level: 'N4',
    audience: 'người học căn bản',
    grammarFocus: 'mẫu nối câu đơn giản và mô tả tình huống quen thuộc',
    styleLabel: 'Căn bản mở rộng',
    minutesBase: 5,
  ),
  'N3': _LevelProfile(
    level: 'N3',
    audience: 'người học trung cấp',
    grammarFocus: 'giải thích, so sánh và nêu quan điểm rõ ràng',
    styleLabel: 'Trung cấp thực tế',
    minutesBase: 6,
  ),
  'N2': _LevelProfile(
    level: 'N2',
    audience: 'người học trung-cao cấp',
    grammarFocus: 'văn phong báo chí và lập luận nhiều lớp',
    styleLabel: 'Báo chí · học thuật nhẹ',
    minutesBase: 7,
  ),
  'N1': _LevelProfile(
    level: 'N1',
    audience: 'người học cao cấp',
    grammarFocus: 'lập luận học thuật, ngữ cảnh xã hội và sắc thái tinh tế',
    styleLabel: 'Học thuật · phân tích',
    minutesBase: 8,
  ),
};

const Map<String, List<Map<String, String>>> _categoryTopics = {
  'Cổ tích': [
    {'title': 'Momotarou', 'jp': 'ももたろう'},
    {'title': 'Urashima Tarou', 'jp': 'うらしまたろう'},
    {'title': 'Hanasaka Jiisan', 'jp': 'はなさかじいさん'},
    {'title': 'Tsuru no Ongaeshi', 'jp': 'つるのおんがえし'},
  ],
  'Đời sống': [
    {'title': 'Một ngày ở Tokyo', 'jp': '東京での一日'},
    {'title': 'Đi tàu điện buổi sáng', 'jp': '朝の電車'},
    {'title': 'Mua sắm ở combini', 'jp': 'コンビニでの買い物'},
    {'title': 'Cuộc sống ký túc xá', 'jp': '学生寮の生活'},
  ],
  'Tips học tập': [
    {'title': 'Cách nhớ kana nhanh', 'jp': 'かなを早く覚える方法'},
    {'title': 'Shadowing mỗi ngày', 'jp': '毎日のシャドーイング'},
    {'title': 'Ghi sổ tay từ vựng', 'jp': '単語ノートの使い方'},
    {'title': 'Lập kế hoạch ôn JLPT', 'jp': 'JLPT学習計画'},
  ],
  'Kinh tế & xã hội': [
    {'title': 'Giá cả sinh hoạt tăng', 'jp': '生活費の上昇'},
    {'title': 'Việc làm bán thời gian', 'jp': 'アルバイト事情'},
    {'title': 'Du lịch nội địa hồi phục', 'jp': '国内旅行の回復'},
    {'title': 'AI trong doanh nghiệp Nhật', 'jp': '日本企業のAI活用'},
  ],
  'Tiểu thuyết': [
    {'title': 'Mùa hè bên biển', 'jp': '海辺の夏'},
    {'title': 'Lá thư cũ', 'jp': '古い手紙'},
    {'title': 'Con mèo ở quán cà phê', 'jp': 'カフェの猫'},
    {'title': 'Đêm mưa ở ga tàu', 'jp': '駅の雨の夜'},
  ],
};

List<ReadingMaterial> buildReadingMaterials() {
  final materials = <ReadingMaterial>[];
  final levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  for (final level in levels) {
    final profile = _profiles[level]!;
    _categoryTopics.forEach((category, topics) {
      for (var i = 0; i < topics.length; i++) {
        final topic = topics[i];
        final itemNumber = materials.length + 1;
        final featured = i == 0;
        materials.add(
          ReadingMaterial(
            id: '${level.toLowerCase()}_${category.toLowerCase().replaceAll(' ', '_')}_$i',
            level: level,
            category: category,
            title: '${topic['title']} · ${_headlineForLevel(level, category)}',
            japaneseTitle: topic['jp']!,
            summary: _summaryFor(level, category, topic['title']!),
            preview: _previewFor(level, category, topic['title']!),
            content: _contentFor(level, category, topic['title']!, topic['jp']!, profile),
            estimatedMinutes: profile.minutesBase + i,
            tags: [
              level,
              category,
              profile.styleLabel,
              if (featured) 'Gợi ý hôm nay',
            ],
            isFeatured: featured || itemNumber % 9 == 0,
          ),
        );
      }
    });
  }

  return materials;
}

List<CultureTopic> buildCultureTopics() {
  return const [
    CultureTopic(
      id: 'matsuri',
      title: 'Matsuri',
      subtitle: 'Lễ hội truyền thống của Nhật Bản',
      icon: '🏮',
      keywords: ['Lễ hội', 'Truyền thống', 'Mùa hè'],
      content: 'Matsuri là tên gọi chung cho các lễ hội truyền thống ở Nhật Bản. Mỗi địa phương có thể có một lễ hội riêng gắn với đền thần, mùa vụ hoặc lịch sử vùng miền. Người tham gia thường mặc yukata, ăn đồ lễ hội và xem diễu hành mikoshi. Đây là dịp rất tốt để hiểu nhịp sống cộng đồng của người Nhật.',
    ),
    CultureTopic(
      id: 'tea',
      title: 'Sadou',
      subtitle: 'Trà đạo và tinh thần wabi-sabi',
      icon: '🍵',
      keywords: ['Trà đạo', 'Wabi-sabi', 'Tĩnh lặng'],
      content: 'Trà đạo không chỉ là uống trà mà còn là một nghệ thuật về nhịp điệu, sự tôn trọng và vẻ đẹp của sự giản dị. Trong mỗi động tác pha trà đều có tính nghi thức. Người học văn hóa Nhật thường tìm hiểu trà đạo để hiểu sâu hơn về khái niệm tĩnh lặng, cân bằng và tinh tế.',
    ),
    CultureTopic(
      id: 'hanami',
      title: 'Hanami',
      subtitle: 'Văn hóa ngắm hoa anh đào',
      icon: '🌸',
      keywords: ['Hoa anh đào', 'Mùa xuân', 'Gia đình'],
      content: 'Hanami là hoạt động ngắm hoa anh đào nở vào mùa xuân. Mọi người tụ tập ở công viên, trải bạt, ăn uống và tận hưởng thời gian bên nhau. Điều đặc biệt là hoa nở đẹp nhưng ngắn ngày, nên hanami cũng gợi nhắc đến vẻ đẹp mong manh của thời gian.',
    ),
    CultureTopic(
      id: 'onsen',
      title: 'Onsen',
      subtitle: 'Văn hóa tắm suối nước nóng',
      icon: '♨️',
      keywords: ['Onsen', 'Nghỉ dưỡng', 'Phép lịch sự'],
      content: 'Onsen là một phần rất quen thuộc trong đời sống nghỉ dưỡng của người Nhật. Khi vào onsen, người dùng cần tắm sạch trước, giữ yên tĩnh và không mặc đồ bơi trong khu tắm công cộng truyền thống. Trải nghiệm onsen giúp người học hiểu thêm về phép lịch sự nơi công cộng ở Nhật.',
    ),
    CultureTopic(
      id: 'shinto',
      title: 'Đền Thần đạo',
      subtitle: 'Không gian tâm linh trong đời sống Nhật',
      icon: '⛩️',
      keywords: ['Thần đạo', 'Đền', 'Tâm linh'],
      content: 'Đền Thần đạo xuất hiện rất nhiều trong đời sống Nhật Bản. Người Nhật thường đến đền vào đầu năm mới để cầu may, hoặc trước những cột mốc quan trọng như thi cử, sinh con, khai trương. Cổng torii trước đền là biểu tượng rất dễ nhận ra của văn hóa Nhật.',
    ),
    CultureTopic(
      id: 'omotenashi',
      title: 'Omotenashi',
      subtitle: 'Tinh thần hiếu khách kiểu Nhật',
      icon: '🤝',
      keywords: ['Hiếu khách', 'Dịch vụ', 'Tinh tế'],
      content: 'Omotenashi là tinh thần phục vụ chân thành, chu đáo và nghĩ trước nhu cầu của người khác. Trong khách sạn, nhà hàng hay tàu điện, bạn có thể thấy rõ tinh thần này qua những chi tiết rất nhỏ. Đây là một giá trị giúp giải thích vì sao dịch vụ ở Nhật thường rất đồng đều và tinh tế.',
    ),
    CultureTopic(
      id: 'bento',
      title: 'Bento',
      subtitle: 'Hộp cơm và thẩm mỹ đời sống',
      icon: '🍱',
      keywords: ['Bento', 'Ẩm thực', 'Chăm sóc'],
      content: 'Bento không chỉ là một hộp cơm trưa tiện lợi mà còn thể hiện tính tổ chức và sự chăm chút trong đời sống Nhật Bản. Cách sắp xếp màu sắc, dinh dưỡng và khẩu phần thường được cân nhắc kỹ. Nhiều gia đình xem việc chuẩn bị bento là một cách thể hiện sự quan tâm.',
    ),
    CultureTopic(
      id: 'tatami',
      title: 'Tatami',
      subtitle: 'Không gian sống truyền thống',
      icon: '🏡',
      keywords: ['Tatami', 'Nhà truyền thống', 'Sinh hoạt'],
      content: 'Tatami là loại chiếu làm từ cỏ igusa, thường dùng trong phòng kiểu Nhật. Căn phòng có tatami tạo cảm giác ấm, mềm và yên tĩnh. Khi tìm hiểu về tatami, người học cũng hiểu thêm cách người Nhật tổ chức không gian sống và ứng xử trong nhà.',
    ),
    CultureTopic(
      id: 'senpai',
      title: 'Senpai - Kouhai',
      subtitle: 'Quan hệ tiền bối - hậu bối',
      icon: '🎓',
      keywords: ['Senpai', 'Kouhai', 'Quan hệ xã hội'],
      content: 'Mối quan hệ senpai - kouhai ảnh hưởng đến trường học, câu lạc bộ và môi trường làm việc tại Nhật. Người đi trước có vai trò dẫn dắt, còn người đi sau thể hiện sự kính trọng và học hỏi. Hiểu cấu trúc này giúp bạn hiểu sâu hơn về giao tiếp và hệ thống thứ bậc trong xã hội Nhật.',
    ),
    CultureTopic(
      id: 'shodo',
      title: 'Shodou',
      subtitle: 'Thư pháp Nhật Bản',
      icon: '🖌️',
      keywords: ['Thư pháp', 'Nghệ thuật', 'Tập trung'],
      content: 'Shodou là nghệ thuật viết chữ bằng bút lông. Người học không chỉ luyện nét chữ mà còn luyện sự tập trung, hơi thở và nhịp điệu. Đây là một hoạt động gắn kết chữ Hán, mỹ học và tinh thần rèn luyện rất rõ trong văn hóa Nhật.',
    ),
    CultureTopic(
      id: 'ikebana',
      title: 'Ikebana',
      subtitle: 'Nghệ thuật cắm hoa Nhật',
      icon: '💐',
      keywords: ['Ikebana', 'Thẩm mỹ', 'Cân bằng'],
      content: 'Ikebana khác với cắm hoa trang trí thông thường ở chỗ nó nhấn mạnh đường nét, khoảng trống và mối quan hệ giữa cành, lá, hoa. Nhiều trường phái ikebana xem sự cân bằng và tiết chế là cốt lõi của cái đẹp.',
    ),
    CultureTopic(
      id: 'newyear',
      title: 'Oshougatsu',
      subtitle: 'Tết truyền thống Nhật Bản',
      icon: '🎍',
      keywords: ['Năm mới', 'Gia đình', 'Phong tục'],
      content: 'Oshougatsu là một trong những dịp lễ quan trọng nhất ở Nhật. Mọi người dọn nhà, gửi thiệp năm mới, ăn osechi ryouri và đi chùa hoặc đền đầu năm. Đây là dịp thể hiện rõ giá trị gia đình và sự khởi đầu trang trọng của năm mới.',
    ),
    CultureTopic(
      id: 'schoolclean',
      title: 'Tự dọn lớp học',
      subtitle: 'Ý thức tập thể từ trường học',
      icon: '🧹',
      keywords: ['Giáo dục', 'Kỷ luật', 'Tập thể'],
      content: 'Ở nhiều trường học Nhật, học sinh tự dọn lớp và khuôn viên trường thay vì phụ thuộc hoàn toàn vào lao công. Việc này giúp rèn trách nhiệm, tính kỷ luật và ý thức cộng đồng từ sớm. Đây là một nét văn hóa giáo dục rất đặc trưng.',
    ),
    CultureTopic(
      id: 'keigo',
      title: 'Keigo',
      subtitle: 'Kính ngữ trong giao tiếp',
      icon: '🗣️',
      keywords: ['Kính ngữ', 'Lịch sự', 'Ngôn ngữ'],
      content: 'Keigo là hệ thống kính ngữ dùng trong giao tiếp trang trọng ở Nhật. Nó phản ánh mối quan hệ xã hội, vị trí vai vế và mức độ lịch sự. Người học tiếng Nhật thường thấy khó với keigo, nhưng đây là chìa khóa để hiểu văn hóa giao tiếp Nhật Bản.',
    ),
    CultureTopic(
      id: 'manga',
      title: 'Manga',
      subtitle: 'Văn hóa truyện tranh đại chúng',
      icon: '📚',
      keywords: ['Manga', 'Giải trí', 'Xuất bản'],
      content: 'Manga không chỉ dành cho trẻ em mà có nhiều thể loại cho mọi lứa tuổi. Từ giáo dục, lịch sử đến kinh doanh, manga đóng vai trò quan trọng trong xuất bản và văn hóa đại chúng Nhật. Đây cũng là cánh cửa hấp dẫn để người học tiếp xúc tiếng Nhật tự nhiên.',
    ),
    CultureTopic(
      id: 'animepilgrimage',
      title: 'Seichi Junrei',
      subtitle: 'Du lịch theo địa điểm anime',
      icon: '🚆',
      keywords: ['Anime', 'Du lịch', 'Địa phương'],
      content: 'Seichi junrei là hình thức du lịch đến các địa điểm xuất hiện trong anime, manga hoặc game. Nó giúp thúc đẩy kinh tế địa phương và tạo sự gắn kết giữa fan với địa danh thực tế. Xu hướng này cho thấy sức ảnh hưởng mạnh của văn hóa pop Nhật.',
    ),
    CultureTopic(
      id: 'konbini',
      title: 'Konbini',
      subtitle: 'Cửa hàng tiện lợi kiểu Nhật',
      icon: '🏪',
      keywords: ['Konbini', 'Đời sống', 'Tiện lợi'],
      content: 'Konbini là một phần không thể thiếu trong nhịp sống hiện đại tại Nhật. Tại đây có thể thanh toán hóa đơn, gửi hàng, mua đồ ăn, in tài liệu và làm nhiều việc khác. Konbini phản ánh rõ văn hóa tiện lợi và hiệu quả trong đời sống Nhật Bản.',
    ),
    CultureTopic(
      id: 'eki',
      title: 'Ga tàu Nhật Bản',
      subtitle: 'Nhịp sống xoay quanh giao thông công cộng',
      icon: '🚉',
      keywords: ['Ga tàu', 'Đô thị', 'Di chuyển'],
      content: 'Ga tàu ở Nhật không chỉ là nơi di chuyển mà còn là trung tâm mua sắm, ăn uống và kết nối cộng đồng. Nhiều thành phố được tổ chức xoay quanh mạng lưới đường sắt. Hiểu văn hóa ga tàu là hiểu một phần lớn nhịp sống đô thị Nhật.',
    ),
    CultureTopic(
      id: 'washoku',
      title: 'Washoku',
      subtitle: 'Ẩm thực truyền thống Nhật',
      icon: '🍣',
      keywords: ['Ẩm thực', 'Washoku', 'Mùa vụ'],
      content: 'Washoku nhấn mạnh sự cân bằng dinh dưỡng, hương vị tự nhiên và tính mùa vụ. Bữa ăn truyền thống thường có cơm, súp miso và nhiều món nhỏ. Washoku được UNESCO công nhận là di sản văn hóa phi vật thể, cho thấy vai trò sâu sắc của ẩm thực trong văn hóa Nhật.',
    ),
    CultureTopic(
      id: 'yukata',
      title: 'Yukata',
      subtitle: 'Trang phục mùa hè gần gũi',
      icon: '👘',
      keywords: ['Yukata', 'Trang phục', 'Mùa hè'],
      content: 'Yukata là trang phục nhẹ, thường mặc vào mùa hè, khi đi lễ hội hoặc nghỉ tại ryokan. So với kimono, yukata đơn giản và dễ mặc hơn. Đây là một biểu tượng văn hóa gần gũi mà người nước ngoài dễ tiếp cận khi trải nghiệm Nhật Bản.',
    ),
  ];
}

String _headlineForLevel(String level, String category) {
  switch (category) {
    case 'Cổ tích':
      return level == 'N1' ? 'đọc sâu biểu tượng văn hóa' : 'phiên bản học theo cấp độ';
    case 'Đời sống':
      return level == 'N5' ? 'tình huống gần gũi mỗi ngày' : 'góc nhìn đời sống Nhật';
    case 'Tips học tập':
      return level == 'N1' ? 'chiến lược học tối ưu' : 'mẹo học dễ áp dụng';
    case 'Kinh tế & xã hội':
      return level == 'N5' ? 'tin tức đơn giản' : 'phân tích xu hướng';
    case 'Tiểu thuyết':
      return level == 'N1' ? 'văn phong giàu sắc thái' : 'đọc truyện theo cấp độ';
    default:
      return 'bài đọc theo cấp độ';
  }
}

String _summaryFor(String level, String category, String topic) {
  final profile = _profiles[level]!;
  return 'Bài đọc $level dành cho ${profile.audience}, xoay quanh chủ đề "$topic" thuộc nhóm $category, giúp luyện ${profile.grammarFocus}.';
}

String _previewFor(String level, String category, String topic) {
  switch (category) {
    case 'Cổ tích':
      return 'Đọc lại câu chuyện "$topic" với độ khó $level, có tóm tắt, từ khóa và câu hỏi suy nghĩ.';
    case 'Đời sống':
      return 'Một lát cắt đời sống Nhật xoay quanh "$topic", phù hợp để luyện đọc thực dụng ở cấp $level.';
    case 'Tips học tập':
      return 'Bài viết chia sẻ cách học hiệu quả về "$topic", phù hợp người học đang ôn JLPT $level.';
    case 'Kinh tế & xã hội':
      return 'Bài báo mini về "$topic" giúp làm quen văn phong thông tin và từ vựng xã hội cho cấp $level.';
    case 'Tiểu thuyết':
      return 'Một đoạn truyện ngắn mang không khí văn học về "$topic", được viết lại cho trình độ $level.';
    default:
      return 'Bài đọc theo cấp độ $level.';
  }
}

String _contentFor(
  String level,
  String category,
  String topic,
  String japaneseTitle,
  _LevelProfile profile,
) {
  final focus = _focusWords(level, category, topic);
  final question = _reflectionQuestion(level, category, topic);

  return '''
Tiêu đề Nhật: $japaneseTitle
Cấp độ: $level
Thể loại: $category
Phong cách: ${profile.styleLabel}

1) Mở bài
Bài đọc này dành cho ${profile.audience}. Nội dung xoay quanh chủ đề "$topic" và được viết theo phong cách ${profile.styleLabel.toLowerCase()}. Khi đọc, bạn nên chú ý đến ${profile.grammarFocus}.

2) Đoạn tiếng Nhật mẫu
「$japaneseTitle」は、日本語学習者が段階的に読解力を伸ばせるように再構成した読み物です。主題は「$topic」で、$levelの学習者でも流れを追いやすいように情報の並び方を整えています。

この文章では、内容理解だけでなく、場面に合った言い回しや語彙の広がりも意識できるようにしています。特に$categoryに関する文脈では、単語の意味だけでなく、使われる場面や日本社会とのつながりも考えながら読むことが大切です。

読んだあとには、自分の経験や意見と比べてみてください。そうすることで、受け身の読解ではなく、考えながら読む練習になり、JLPTの長文問題や実際の文章理解にもつながります。

3) Gợi ý đọc hiểu bằng tiếng Việt
- Tóm ý chính của bài trong 1 đến 2 câu.
- Tìm 3 từ khóa quan trọng và đặt câu mới với chúng.
- Gạch chân những mẫu câu bạn muốn ghi vào sổ tay ngữ pháp.
- Tự hỏi: tác giả muốn người đọc hiểu điều gì từ chủ đề "$topic"?

4) Từ khóa nên nhớ
$focus

5) Câu hỏi tự suy ngẫm
$question
''';
}

String _focusWords(String level, String category, String topic) {
  return '- 主題: chủ đề chính của bài "$topic"\n'
      '- 文脈: ngữ cảnh sử dụng trong nhóm "$category"\n'
      '- 表現: cách diễn đạt phù hợp với trình độ $level\n'
      '- 読解: kỹ năng đọc hiểu và nắm ý chính';
}

String _reflectionQuestion(String level, String category, String topic) {
  if (category == 'Kinh tế & xã hội') {
    return 'Theo bạn, chủ đề "$topic" phản ánh điều gì về xã hội Nhật hiện đại, và cách diễn đạt nào trong bài phù hợp với văn phong $level nhất?';
  }
  if (category == 'Tips học tập') {
    return 'Bạn có thể áp dụng ý tưởng nào từ bài "$topic" vào kế hoạch học tiếng Nhật tuần này?';
  }
  if (category == 'Tiểu thuyết') {
    return 'Không khí cảm xúc của bài "$topic" được tạo ra nhờ những chi tiết nào?';
  }
  return 'Sau khi đọc "$topic", bạn nhớ nhất từ hoặc mẫu câu nào ở cấp $level?';
}
