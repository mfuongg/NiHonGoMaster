import '../models/grammar.dart';

class GrammarData {
  static const List<String> levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  static List<GrammarLesson> getAllLessons() => [
    ..._n5Grammar,
    ..._n4Grammar,
    ..._n3Grammar,
    ..._n2Grammar,
    ..._n1Grammar,
  ];

  static List<GrammarLesson> getLessonsByLevel(String level) {
    switch (level) {
      case 'N5':
        return _n5Grammar;
      case 'N4':
        return _n4Grammar;
      case 'N3':
        return _n3Grammar;
      case 'N2':
        return _n2Grammar;
      case 'N1':
        return _n1Grammar;
      default:
        return _n5Grammar;
    }
  }

  static final List<GrammarLesson> _n5Grammar = [
    GrammarLesson(
      id: 'g_n5_001',
      pattern: '〜は〜です',
      title: 'Câu khẳng định cơ bản',
      explanation: 'Mẫu câu nền tảng để giới thiệu người, vật và nghề nghiệp trong văn phong lịch sự.',
      jlptLevel: 'N5',
      examples: [
        ExampleSentence(japanese: '私は留学生です。', hiragana: 'わたしはりゅうがくせいです。', vietnamese: 'Tôi là du học sinh.', english: 'I am an international student.'),
        ExampleSentence(japanese: 'これは日本の地図です。', hiragana: 'これはにほんのちずです。', vietnamese: 'Đây là bản đồ Nhật Bản.', english: 'This is a map of Japan.'),
      ],
      notes: ['は đọc là wa khi làm trợ từ chủ đề.', 'です giúp câu lịch sự và mềm hơn.'],
    ),
    GrammarLesson(
      id: 'g_n5_002',
      pattern: '〜は〜ですか',
      title: 'Câu hỏi yes/no',
      explanation: 'Chỉ cần thêm か ở cuối câu để tạo câu hỏi lịch sự, không đảo trật tự từ.',
      jlptLevel: 'N5',
      examples: [
        ExampleSentence(japanese: 'あなたは先生ですか。', hiragana: 'あなたはせんせいですか。', vietnamese: 'Bạn là giáo viên phải không?', english: 'Are you a teacher?'),
        ExampleSentence(japanese: 'これは新しい辞書ですか。', hiragana: 'これはあたらしいじしょですか。', vietnamese: 'Đây có phải từ điển mới không?', english: 'Is this a new dictionary?'),
      ],
      notes: ['Trong hội thoại thân mật có thể bỏ か và lên giọng.', 'Khi trả lời có thể dùng はい / いいえ.'],
    ),
    GrammarLesson(
      id: 'g_n5_003',
      pattern: '〜の〜',
      title: 'Sở hữu và liên kết danh từ',
      explanation: 'Trợ từ の nối hai danh từ, thể hiện sở hữu hoặc bổ nghĩa.',
      jlptLevel: 'N5',
      examples: [
        ExampleSentence(japanese: '日本語の本を買いました。', hiragana: 'にほんごのほんをかいました。', vietnamese: 'Tôi đã mua sách tiếng Nhật.', english: 'I bought a Japanese book.'),
        ExampleSentence(japanese: '田中さんのかばんは青いです。', hiragana: 'たなかさんのかばんはあおいです。', vietnamese: 'Cặp của anh Tanaka màu xanh.', english: 'Tanaka-san\'s bag is blue.'),
      ],
      notes: ['Có thể nối nhiều lần: 日本の大学の先生.', 'Rất hay gặp trong tiêu đề và tên gọi.'],
    ),
    GrammarLesson(
      id: 'g_n5_004',
      pattern: '〜を〜',
      title: 'Tân ngữ trực tiếp',
      explanation: 'を đánh dấu đối tượng chịu tác động trực tiếp của động từ.',
      jlptLevel: 'N5',
      examples: [
        ExampleSentence(japanese: '毎朝コーヒーを飲みます。', hiragana: 'まいあさコーヒーをのみます。', vietnamese: 'Mỗi sáng tôi uống cà phê.', english: 'I drink coffee every morning.'),
        ExampleSentence(japanese: '図書館で新聞を読みます。', hiragana: 'としょかんでしんぶんをよみます。', vietnamese: 'Tôi đọc báo ở thư viện.', english: 'I read the newspaper at the library.'),
      ],
      notes: ['を thường đọc là o trong lời nói.', 'Đi với tha động từ là chủ yếu.'],
    ),
    GrammarLesson(
      id: 'g_n5_005',
      pattern: '〜に行きます / 来ます / 帰ります',
      title: 'Nơi đến',
      explanation: 'に chỉ đích đến khi đi, đến hoặc về.',
      jlptLevel: 'N5',
      examples: [
        ExampleSentence(japanese: '土曜日に友達の家に行きます。', hiragana: 'どようびにともだちのいえにいきます。', vietnamese: 'Thứ bảy tôi đến nhà bạn.', english: 'I will go to my friend\'s house on Saturday.'),
        ExampleSentence(japanese: '夜九時に家に帰ります。', hiragana: 'よるくじにいえにかえります。', vietnamese: 'Tôi về nhà lúc 9 giờ tối.', english: 'I go home at 9 p.m.'),
      ],
      notes: ['に cũng dùng với thời gian.', 'へ có thể thay cho に khi nhấn mạnh hướng.'],
    ),
    GrammarLesson(
      id: 'g_n5_006',
      pattern: '〜で〜',
      title: 'Địa điểm hành động và phương tiện',
      explanation: 'で dùng để chỉ nơi diễn ra hành động hoặc công cụ/phương tiện sử dụng.',
      jlptLevel: 'N5',
      examples: [
        ExampleSentence(japanese: '教室で日本語を勉強します。', hiragana: 'きょうしつでにほんごをべんきょうします。', vietnamese: 'Tôi học tiếng Nhật trong lớp.', english: 'I study Japanese in the classroom.'),
        ExampleSentence(japanese: '電車で会社へ行きます。', hiragana: 'でんしゃでかいしゃへいきます。', vietnamese: 'Tôi đi làm bằng tàu điện.', english: 'I go to work by train.'),
      ],
      notes: ['に dùng cho tồn tại, で dùng cho hành động.', 'で cũng dùng với dụng cụ như 箸で.'],
    ),
    GrammarLesson(
      id: 'g_n5_007',
      pattern: '〜ます / 〜ません / 〜ました',
      title: 'Chia động từ lịch sự',
      explanation: 'Đây là nhóm mẫu cực quan trọng để dùng động từ trong hội thoại hàng ngày.',
      jlptLevel: 'N5',
      examples: [
        ExampleSentence(japanese: '毎晩三十分勉強します。', hiragana: 'まいばんさんじゅっぷんべんきょうします。', vietnamese: 'Mỗi tối tôi học 30 phút.', english: 'I study for 30 minutes every night.'),
        ExampleSentence(japanese: '昨日はテレビを見ませんでした。', hiragana: 'きのうはテレビをみませんでした。', vietnamese: 'Hôm qua tôi đã không xem TV.', english: 'I did not watch TV yesterday.'),
      ],
      notes: ['ます là hiện tại/tương lai lịch sự.', 'Quá khứ phủ định là ませんでした.'],
    ),
    GrammarLesson(
      id: 'g_n5_008',
      pattern: '〜たいです',
      title: 'Diễn tả mong muốn',
      explanation: 'Gắn vào gốc ます để nói người nói muốn làm điều gì.',
      jlptLevel: 'N5',
      examples: [
        ExampleSentence(japanese: '日本へ旅行したいです。', hiragana: 'にほんへりょこうしたいです。', vietnamese: 'Tôi muốn du lịch Nhật Bản.', english: 'I want to travel to Japan.'),
        ExampleSentence(japanese: '今日は早く寝たいです。', hiragana: 'きょうははやくねたいです。', vietnamese: 'Hôm nay tôi muốn ngủ sớm.', english: 'I want to sleep early today.'),
      ],
      notes: ['たい chia như tính từ đuôi い.', 'Với người khác thường dùng たがっています.'],
    ),
    GrammarLesson(
      id: 'g_n5_009',
      pattern: '〜ている',
      title: 'Đang làm / trạng thái',
      explanation: 'Diễn tả hành động đang tiếp diễn hoặc trạng thái kết quả duy trì.',
      jlptLevel: 'N5',
      examples: [
        ExampleSentence(japanese: '今、駅で待っています。', hiragana: 'いま、えきでまっています。', vietnamese: 'Bây giờ tôi đang đợi ở ga.', english: 'I am waiting at the station now.'),
        ExampleSentence(japanese: '兄は東京に住んでいます。', hiragana: 'あにはとうきょうにすんでいます。', vietnamese: 'Anh trai tôi đang sống ở Tokyo.', english: 'My older brother lives in Tokyo.'),
      ],
      notes: ['Một số động từ như 知る, 結婚する dùng để chỉ trạng thái.', 'Bản thân mẫu này xuất hiện rất nhiều trong đề nghe.'],
    ),
    GrammarLesson(
      id: 'g_n5_010',
      pattern: '〜から〜まで',
      title: 'Từ ... đến ...',
      explanation: 'Dùng cho thời gian hoặc phạm vi không gian.',
      jlptLevel: 'N5',
      examples: [
        ExampleSentence(japanese: '授業は九時から十二時までです。', hiragana: 'じゅぎょうはくじからじゅうにじまでです。', vietnamese: 'Lớp học từ 9 giờ đến 12 giờ.', english: 'Class is from 9 to 12.'),
        ExampleSentence(japanese: '大阪から京都までバスで行きました。', hiragana: 'おおさかからきょうとまでバスでいきました。', vietnamese: 'Tôi đã đi từ Osaka đến Kyoto bằng xe buýt.', english: 'I went from Osaka to Kyoto by bus.'),
      ],
      notes: ['から còn có nghĩa là vì.', 'まで đôi khi mang nghĩa đến tận, cho đến cả.'],
    ),
  ];

  static final List<GrammarLesson> _n4Grammar = [
    GrammarLesson(
      id: 'g_n4_001',
      pattern: '〜てから',
      title: 'Sau khi làm xong',
      explanation: 'Diễn tả thứ tự hành động: sau A thì mới B.',
      jlptLevel: 'N4',
      examples: [
        ExampleSentence(japanese: '朝ご飯を食べてから、学校へ行きます。', hiragana: 'あさごはんをたべてから、がっこうへいきます。', vietnamese: 'Sau khi ăn sáng tôi đi học.', english: 'After eating breakfast, I go to school.'),
        ExampleSentence(japanese: '宿題をしてから、寝ました。', hiragana: 'しゅくだいをしてから、ねました。', vietnamese: 'Sau khi làm bài tập xong tôi đi ngủ.', english: 'I went to sleep after doing my homework.'),
      ],
      notes: ['Phù hợp để nói trình tự rõ ràng.', 'Rất hay xuất hiện trong hội thoại sinh hoạt.'],
    ),
    GrammarLesson(
      id: 'g_n4_002',
      pattern: '〜ながら',
      title: 'Vừa ... vừa ...',
      explanation: 'Hai hành động đồng thời do cùng một chủ thể thực hiện.',
      jlptLevel: 'N4',
      examples: [
        ExampleSentence(japanese: '音楽を聞きながら、レポートを書きます。', hiragana: 'おんがくをききながら、レポートをかきます。', vietnamese: 'Tôi vừa nghe nhạc vừa viết báo cáo.', english: 'I write a report while listening to music.'),
        ExampleSentence(japanese: '歩きながら電話しないでください。', hiragana: 'あるきながらでんわしないでください。', vietnamese: 'Xin đừng vừa đi vừa gọi điện.', english: 'Please do not talk on the phone while walking.'),
      ],
      notes: ['Hành động chính thường đứng ở mệnh đề sau.', 'Chủ thể phải giống nhau.'],
    ),
    GrammarLesson(
      id: 'g_n4_003',
      pattern: '〜たり〜たりする',
      title: 'Liệt kê hành động tiêu biểu',
      explanation: 'Nói một vài hành động đại diện chứ không phải toàn bộ.',
      jlptLevel: 'N4',
      examples: [
        ExampleSentence(japanese: '休みの日は本を読んだり、料理をしたりします。', hiragana: 'やすみのひはほんをよんだり、りょうりをしたりします。', vietnamese: 'Ngày nghỉ tôi đọc sách, nấu ăn các kiểu.', english: 'On my days off I do things like reading and cooking.'),
        ExampleSentence(japanese: '天気は暑かったり寒かったりです。', hiragana: 'てんきはあつかったりさむかったりです。', vietnamese: 'Thời tiết lúc nóng lúc lạnh.', english: 'The weather is sometimes hot and sometimes cold.'),
      ],
      notes: ['Có thể dùng với động từ, tính từ, danh từ.', 'Cuối câu thường kết bằng します / です.'],
    ),
    GrammarLesson(
      id: 'g_n4_004',
      pattern: '〜ために',
      title: 'Để / nhằm mục đích',
      explanation: 'Nói mục đích của hành động hoặc vì lợi ích của điều gì.',
      jlptLevel: 'N4',
      examples: [
        ExampleSentence(japanese: '日本で働くために、日本語を勉強しています。', hiragana: 'にほんではたらくために、にほんごをべんきょうしています。', vietnamese: 'Để làm việc ở Nhật tôi đang học tiếng Nhật.', english: 'I am studying Japanese to work in Japan.'),
        ExampleSentence(japanese: '健康のために、毎日歩いています。', hiragana: 'けんこうのために、まいにちあるいています。', vietnamese: 'Vì sức khỏe tôi đi bộ mỗi ngày.', english: 'I walk every day for my health.'),
      ],
      notes: ['Động từ điển + ために.', 'Danh từ + のために.'],
    ),
    GrammarLesson(
      id: 'g_n4_005',
      pattern: '〜そうです（様態）',
      title: 'Trông có vẻ',
      explanation: 'Dựa vào bề ngoài để suy đoán trạng thái ngay trước mắt.',
      jlptLevel: 'N4',
      examples: [
        ExampleSentence(japanese: 'このスープは熱そうですね。', hiragana: 'このスープはあつそうですね。', vietnamese: 'Món súp này trông có vẻ nóng nhỉ.', english: 'This soup looks hot.'),
        ExampleSentence(japanese: '彼は元気そうに見えます。', hiragana: 'かれはげんきそうにみえます。', vietnamese: 'Anh ấy trông có vẻ khỏe.', english: 'He looks energetic.'),
      ],
      notes: ['いい -> よさそう.', 'Khác với 〜そうです mang nghĩa nghe nói.'],
    ),
    GrammarLesson(
      id: 'g_n4_006',
      pattern: '〜ようになる',
      title: 'Trở nên có thể / thành thói quen',
      explanation: 'Diễn tả sự thay đổi về năng lực hoặc trạng thái theo thời gian.',
      jlptLevel: 'N4',
      examples: [
        ExampleSentence(japanese: 'ひらがなが読めるようになりました。', hiragana: 'ひらがながよめるようになりました。', vietnamese: 'Tôi đã trở nên đọc được hiragana.', english: 'I became able to read hiragana.'),
        ExampleSentence(japanese: '最近、早く起きるようになりました。', hiragana: 'さいきん、はやくおきるようになりました。', vietnamese: 'Dạo gần đây tôi đã có thói quen dậy sớm.', english: 'Recently I have started waking up early.'),
      ],
      notes: ['Thường đi với động từ khả năng hoặc động từ thường.', 'Nhấn mạnh kết quả thay đổi.'],
    ),
    GrammarLesson(
      id: 'g_n4_007',
      pattern: '〜なければならない',
      title: 'Phải làm',
      explanation: 'Một mẫu rất quan trọng để diễn tả nghĩa vụ, trách nhiệm.',
      jlptLevel: 'N4',
      examples: [
        ExampleSentence(japanese: '明日までにレポートを出さなければなりません。', hiragana: 'あしたまでにレポートをださなければなりません。', vietnamese: 'Tôi phải nộp báo cáo trước ngày mai.', english: 'I must submit the report by tomorrow.'),
        ExampleSentence(japanese: '学生は時間を守らなければならない。', hiragana: 'がくせいはじかんをまもらなければならない。', vietnamese: 'Học sinh phải đúng giờ.', english: 'Students must be punctual.'),
      ],
      notes: ['Trong khẩu ngữ hay rút gọn thành 〜なきゃ.', 'Mang sắc thái bắt buộc.'],
    ),
    GrammarLesson(
      id: 'g_n4_008',
      pattern: '〜てもいい',
      title: 'Được phép làm',
      explanation: 'Xin phép hoặc cho phép thực hiện hành động.',
      jlptLevel: 'N4',
      examples: [
        ExampleSentence(japanese: 'ここに座ってもいいですか。', hiragana: 'ここにすわってもいいですか。', vietnamese: 'Tôi ngồi ở đây có được không?', english: 'May I sit here?'),
        ExampleSentence(japanese: '写真を撮ってもいいですよ。', hiragana: 'しゃしんをとってもいいですよ。', vietnamese: 'Bạn có thể chụp ảnh nhé.', english: 'You may take photos.'),
      ],
      notes: ['Phủ định là 〜てはいけない.', 'Rất phổ biến trong lớp học và nơi công cộng.'],
    ),
    GrammarLesson(
      id: 'g_n4_009',
      pattern: '〜てしまう',
      title: 'Lỡ / hoàn thành mất rồi',
      explanation: 'Diễn tả hoàn thành hoàn toàn hoặc cảm giác tiếc nuối, không mong muốn.',
      jlptLevel: 'N4',
      examples: [
        ExampleSentence(japanese: '電車で寝てしまいました。', hiragana: 'でんしゃでねてしまいました。', vietnamese: 'Tôi lỡ ngủ quên trên tàu.', english: 'I accidentally fell asleep on the train.'),
        ExampleSentence(japanese: '宿題はもう終わってしまいました。', hiragana: 'しゅくだいはもうおわってしまいました。', vietnamese: 'Bài tập đã xong mất rồi.', english: 'I have already finished the homework.'),
      ],
      notes: ['Khẩu ngữ rút gọn thành 〜ちゃう / 〜じゃう.', 'Ngữ cảnh quyết định nghĩa tích cực hay tiếc nuối.'],
    ),
    GrammarLesson(
      id: 'g_n4_010',
      pattern: '〜と思う',
      title: 'Tôi nghĩ rằng',
      explanation: 'Dùng để diễn tả ý kiến, suy nghĩ và cảm nhận cá nhân.',
      jlptLevel: 'N4',
      examples: [
        ExampleSentence(japanese: '日本語はおもしろいと思います。', hiragana: 'にほんごはおもしろいとおもいます。', vietnamese: 'Tôi nghĩ tiếng Nhật thú vị.', english: 'I think Japanese is interesting.'),
        ExampleSentence(japanese: 'あの店は安いと思いません。', hiragana: 'あのみせはやすいとおもいません。', vietnamese: 'Tôi không nghĩ quán đó rẻ.', english: 'I do not think that shop is cheap.'),
      ],
      notes: ['Với động từ/tính từ thường dùng mệnh đề thường + と思う.', 'Lịch sự hơn khi thêm 〜と思います.'],
    ),
  ];

  static final List<GrammarLesson> _n3Grammar = [
    GrammarLesson(
      id: 'g_n3_001',
      pattern: '〜ことにする',
      title: 'Quyết định sẽ làm',
      explanation: 'Người nói chủ động đưa ra quyết định của bản thân.',
      jlptLevel: 'N3',
      examples: [
        ExampleSentence(japanese: '今年から毎日漢字を五つ覚えることにしました。', hiragana: 'ことしからまいにちかんじをいつつおぼえることにしました。', vietnamese: 'Từ năm nay tôi quyết định mỗi ngày học 5 kanji.', english: 'From this year I decided to memorize five kanji a day.'),
        ExampleSentence(japanese: '甘い物は食べないことにしています。', hiragana: 'あまいものはたべないことにしています。', vietnamese: 'Tôi duy trì quyết định không ăn đồ ngọt.', english: 'I make it a rule not to eat sweets.'),
      ],
      notes: ['ことにしている diễn tả quy tắc tự đặt ra.', 'Khác với ことになる là do hoàn cảnh quyết định.'],
    ),
    GrammarLesson(
      id: 'g_n3_002',
      pattern: '〜ことになる',
      title: 'Được quyết định là / trở thành',
      explanation: 'Kết quả do quy định, hoàn cảnh hoặc người khác quyết định.',
      jlptLevel: 'N3',
      examples: [
        ExampleSentence(japanese: '来月大阪支社へ転勤することになりました。', hiragana: 'らいげつおおさかししゃへてんきんすることになりました。', vietnamese: 'Tôi đã được quyết định chuyển công tác đến chi nhánh Osaka vào tháng sau.', english: 'It has been decided that I will transfer to the Osaka branch next month.'),
        ExampleSentence(japanese: '会議はオンラインで行うことになっています。', hiragana: 'かいぎはオンラインでおこなうことになっています。', vietnamese: 'Cuộc họp được quy định sẽ diễn ra online.', english: 'It has been decided that the meeting will be held online.'),
      ],
      notes: ['Thể ことになっている diễn tả quy tắc/quy định.', 'Chủ ngữ ít mang tính chủ động.'],
    ),
    GrammarLesson(
      id: 'g_n3_003',
      pattern: '〜ようにする',
      title: 'Cố gắng để / tạo thói quen',
      explanation: 'Nói về nỗ lực có ý thức nhằm hình thành hành vi mong muốn.',
      jlptLevel: 'N3',
      examples: [
        ExampleSentence(japanese: '忘れないように、メモするようにしています。', hiragana: 'わすれないように、メモするようにしています。', vietnamese: 'Để khỏi quên, tôi cố tạo thói quen ghi chú.', english: 'To avoid forgetting, I make it a habit to take notes.'),
        ExampleSentence(japanese: '毎日日本語を聞くようにしてください。', hiragana: 'まいにちにほんごをきくようにしてください。', vietnamese: 'Hãy cố gắng nghe tiếng Nhật mỗi ngày.', english: 'Please try to listen to Japanese every day.'),
      ],
      notes: ['ようにする nhấn mạnh nỗ lực có chủ đích.', 'Khác với ようになる là kết quả thay đổi.'],
    ),
    GrammarLesson(
      id: 'g_n3_004',
      pattern: '〜ようになる',
      title: 'Dần trở nên',
      explanation: 'Dùng khi kết quả thay đổi diễn ra tự nhiên sau quá trình rèn luyện.',
      jlptLevel: 'N3',
      examples: [
        ExampleSentence(japanese: 'ニュースの内容が少しずつ分かるようになりました。', hiragana: 'ニュースのないようがすこしずつわかるようになりました。', vietnamese: 'Tôi dần dần hiểu được nội dung tin tức.', english: 'I gradually became able to understand news content.'),
        ExampleSentence(japanese: '練習して、きれいに発音できるようになった。', hiragana: 'れんしゅうして、きれいにはつおんできるようになった。', vietnamese: 'Luyện tập xong tôi đã phát âm được rõ hơn.', english: 'After practice I became able to pronounce clearly.'),
      ],
      notes: ['Thường đi cùng quá trình thay đổi theo thời gian.', 'Rất hợp khi nói về tiến bộ học tập.'],
    ),
    GrammarLesson(
      id: 'g_n3_005',
      pattern: '〜ば〜ほど',
      title: 'Càng ... càng ...',
      explanation: 'Diễn tả hai vế thay đổi tỉ lệ thuận.',
      jlptLevel: 'N3',
      examples: [
        ExampleSentence(japanese: '日本語は勉強すればするほど面白くなります。', hiragana: 'にほんごはべんきょうすればするほどおもしろくなります。', vietnamese: 'Tiếng Nhật càng học càng thú vị.', english: 'The more you study Japanese, the more interesting it becomes.'),
        ExampleSentence(japanese: 'この町は歩けば歩くほど好きになります。', hiragana: 'このまちはあるけばあるほどすきになります。', vietnamese: 'Thị trấn này càng đi bộ khám phá càng thích.', english: 'The more I walk around this town, the more I like it.'),
      ],
      notes: ['Mẫu nhấn mạnh mối tương quan tăng dần.', 'Vế sau thường chứa cảm nhận/kết quả.'],
    ),
    GrammarLesson(
      id: 'g_n3_006',
      pattern: '〜ように見える / 聞こえる',
      title: 'Có vẻ như / nghe như',
      explanation: 'Diễn tả ấn tượng rút ra từ quan sát hoặc âm thanh.',
      jlptLevel: 'N3',
      examples: [
        ExampleSentence(japanese: '彼は忙しいように見えます。', hiragana: 'かれはいそがしいようにみえます。', vietnamese: 'Anh ấy trông có vẻ bận.', english: 'He seems busy.'),
        ExampleSentence(japanese: '外は雨が降っているように聞こえます。', hiragana: 'そとはあめがふっているようにきこえます。', vietnamese: 'Bên ngoài nghe như đang mưa.', english: 'It sounds like it is raining outside.'),
      ],
      notes: ['Khác với そうだ mang suy đoán trực quan ngắn gọn hơn.', 'Thường gặp trong văn miêu tả.'],
    ),
    GrammarLesson(
      id: 'g_n3_007',
      pattern: '〜かもしれない',
      title: 'Có lẽ',
      explanation: 'Biểu thị khả năng có thể xảy ra với độ chắc chắn không cao.',
      jlptLevel: 'N3',
      examples: [
        ExampleSentence(japanese: '明日は雪が降るかもしれません。', hiragana: 'あしたはゆきがふるかもしれません。', vietnamese: 'Ngày mai có lẽ trời sẽ có tuyết.', english: 'It may snow tomorrow.'),
        ExampleSentence(japanese: 'あの人はもう帰ったかもしれない。', hiragana: 'あのひとはもうかえったかもしれない。', vietnamese: 'Người đó có lẽ đã về rồi.', english: 'That person might have already gone home.'),
      ],
      notes: ['Mức chắc chắn thấp hơn でしょう.', 'Có thể dùng ở cả văn nói và viết.'],
    ),
    GrammarLesson(
      id: 'g_n3_008',
      pattern: '〜わけではない',
      title: 'Không hẳn là',
      explanation: 'Phủ định một phần, làm mềm phát biểu để tránh tuyệt đối hóa.',
      jlptLevel: 'N3',
      examples: [
        ExampleSentence(japanese: '辛い物が嫌いなわけではありません。', hiragana: 'からいものがきらいなわけではありません。', vietnamese: 'Không hẳn là tôi ghét đồ cay.', english: 'It is not that I dislike spicy food.'),
        ExampleSentence(japanese: '忙しいからといって、全然勉強しないわけではない。', hiragana: 'いそがしいからといって、ぜんぜんべんきょうしないわけではない。', vietnamese: 'Dù bận nhưng không phải là tôi không học chút nào.', english: 'Even though I am busy, it is not that I do not study at all.'),
      ],
      notes: ['Rất hữu ích khi trình bày ý kiến cân bằng.', 'Hay đi cùng biểu thức giải thích.'],
    ),
    GrammarLesson(
      id: 'g_n3_009',
      pattern: '〜たばかり',
      title: 'Vừa mới làm xong',
      explanation: 'Diễn tả một hành động vừa xảy ra cách đây không lâu theo cảm nhận người nói.',
      jlptLevel: 'N3',
      examples: [
        ExampleSentence(japanese: 'さっき昼ご飯を食べたばかりです。', hiragana: 'さっきひるごはんをたべたばかりです。', vietnamese: 'Tôi vừa mới ăn trưa xong.', english: 'I just ate lunch.'),
        ExampleSentence(japanese: '日本に来たばかりで、まだ道が分かりません。', hiragana: 'にほんにきたばかりで、まだみちがわかりません。', vietnamese: 'Vì tôi mới sang Nhật nên vẫn chưa rành đường.', english: 'I just came to Japan, so I still do not know the roads well.'),
      ],
      notes: ['Mang tính cảm nhận, không phải thời gian tuyệt đối.', 'Khác với ところ là nhấn mạnh đúng thời điểm.'],
    ),
    GrammarLesson(
      id: 'g_n3_010',
      pattern: '〜に違いない',
      title: 'Chắc chắn là',
      explanation: 'Người nói suy luận rất mạnh dựa trên căn cứ hiện có.',
      jlptLevel: 'N3',
      examples: [
        ExampleSentence(japanese: '彼はこの仕事に向いているに違いない。', hiragana: 'かれはこのしごとにむいているにちがいない。', vietnamese: 'Anh ấy chắc chắn hợp với công việc này.', english: 'He must be suited for this job.'),
        ExampleSentence(japanese: '電気がついているから、だれかいるに違いありません。', hiragana: 'でんきがついているから、だれかいるにちがいありません。', vietnamese: 'Đèn đang bật nên chắc chắn có ai ở đó.', english: 'The light is on, so there must be someone there.'),
      ],
      notes: ['Mạnh hơn でしょう và かもしれない.', 'Thường dùng khi suy luận có cơ sở.'],
    ),
  ];

  static final List<GrammarLesson> _n2Grammar = [
    GrammarLesson(
      id: 'g_n2_001',
      pattern: '〜わけにはいかない',
      title: 'Không thể / không đành',
      explanation: 'Dùng khi hoàn cảnh, trách nhiệm hoặc đạo đức khiến người nói không thể làm điều gì.',
      jlptLevel: 'N2',
      examples: [
        ExampleSentence(japanese: '明日は大事な試験があるので、休むわけにはいきません。', hiragana: 'あしたはだいじなしけんがあるので、やすむわけにはいきません。', vietnamese: 'Ngày mai có kỳ thi quan trọng nên tôi không thể nghỉ được.', english: 'I cannot take a day off because I have an important exam tomorrow.'),
        ExampleSentence(japanese: '約束したから、途中でやめるわけにはいかない。', hiragana: 'やくそくしたから、とちゅうでやめるわけにはいかない。', vietnamese: 'Vì đã hứa rồi nên không thể bỏ dở giữa chừng.', english: 'I cannot quit halfway because I promised.'),
      ],
      notes: ['Mang sắc thái bị ràng buộc.', 'Khác với できない thuần năng lực.'],
    ),
    GrammarLesson(
      id: 'g_n2_002',
      pattern: '〜にすぎない',
      title: 'Chỉ là / không hơn',
      explanation: 'Hạ thấp mức độ, nhấn mạnh điều gì đó không quá lớn lao.',
      jlptLevel: 'N2',
      examples: [
        ExampleSentence(japanese: 'それはうわさにすぎません。', hiragana: 'それはうわさにすぎません。', vietnamese: 'Đó chỉ là tin đồn thôi.', english: 'That is nothing more than a rumor.'),
        ExampleSentence(japanese: '彼の説明は一つの例にすぎない。', hiragana: 'かれのせつめいはひとつのれいにすぎない。', vietnamese: 'Lời giải thích của anh ấy chỉ là một ví dụ.', english: 'His explanation is only one example.'),
      ],
      notes: ['Thường dùng trong văn viết và tranh luận.', 'Có sắc thái khách quan, tỉnh táo.'],
    ),
    GrammarLesson(
      id: 'g_n2_003',
      pattern: '〜おそれがある',
      title: 'Có nguy cơ',
      explanation: 'Diễn tả khả năng xấu có thể xảy ra, thường thấy trong bản tin và văn bản chính thức.',
      jlptLevel: 'N2',
      examples: [
        ExampleSentence(japanese: '台風の影響で、電車が遅れるおそれがあります。', hiragana: 'たいふうのえいきょうで、でんしゃがおくれるおそれがあります。', vietnamese: 'Do ảnh hưởng của bão, tàu điện có nguy cơ trễ.', english: 'Because of the typhoon, trains may be delayed.'),
        ExampleSentence(japanese: 'このままではデータが消えるおそれがある。', hiragana: 'このままではデータがきえるおそれがある。', vietnamese: 'Nếu cứ thế này thì có nguy cơ mất dữ liệu.', english: 'If this continues, there is a risk that the data will be lost.'),
      ],
      notes: ['Hay kết hợp với tin tức, cảnh báo.', 'Sắc thái trang trọng hơn かもしれない.'],
    ),
    GrammarLesson(
      id: 'g_n2_004',
      pattern: '〜ことなく',
      title: 'Không hề / mà không',
      explanation: 'Diễn tả một hành động diễn ra mà không cần hoặc không hề làm hành động khác.',
      jlptLevel: 'N2',
      examples: [
        ExampleSentence(japanese: '彼は一度も休むことなく働き続けた。', hiragana: 'かれはいちどもやすむことなくはたらきつづけた。', vietnamese: 'Anh ấy tiếp tục làm việc mà không nghỉ một lần nào.', english: 'He kept working without taking a single break.'),
        ExampleSentence(japanese: '辞書を見ることなく答えられました。', hiragana: 'じしょをみることなくこたえられました。', vietnamese: 'Tôi đã trả lời được mà không cần xem từ điển.', english: 'I was able to answer without looking at a dictionary.'),
      ],
      notes: ['Trang trọng hơn ないで.', 'Xuất hiện nhiều trong văn viết.'],
    ),
    GrammarLesson(
      id: 'g_n2_005',
      pattern: '〜どころか',
      title: 'Đừng nói là ... mà ngay cả ...',
      explanation: 'Phủ định mạnh kỳ vọng ban đầu rồi nêu kết quả trái ngược hơn.',
      jlptLevel: 'N2',
      examples: [
        ExampleSentence(japanese: '忙しくて、旅行どころか週末も休めない。', hiragana: 'いそがしくて、りょこうどころかしゅうまつもやすめない。', vietnamese: 'Bận đến mức đừng nói là đi du lịch, cuối tuần còn không nghỉ được.', english: 'I am so busy that far from traveling, I cannot even rest on weekends.'),
        ExampleSentence(japanese: '彼は漢字どころか、ひらがなもまだ読めない。', hiragana: 'かれはかんじどころか、ひらがなもまだよめない。', vietnamese: 'Đừng nói kanji, anh ấy còn chưa đọc được cả hiragana.', english: 'Far from reading kanji, he still cannot even read hiragana.'),
      ],
      notes: ['Tạo sắc thái nhấn mạnh rất mạnh.', 'Hay dùng trong nói và viết bán trang trọng.'],
    ),
    GrammarLesson(
      id: 'g_n2_006',
      pattern: '〜に伴って',
      title: 'Cùng với / kéo theo',
      explanation: 'Một sự thay đổi diễn ra song hành với một thay đổi khác.',
      jlptLevel: 'N2',
      examples: [
        ExampleSentence(japanese: '物価の上昇に伴って、家計も苦しくなっている。', hiragana: 'ぶっかのじょうしょうにともなって、かけいもくるしくなっている。', vietnamese: 'Cùng với việc giá cả tăng, chi tiêu gia đình cũng khó khăn hơn.', english: 'As prices rise, household finances are also becoming tighter.'),
        ExampleSentence(japanese: '駅前の開発に伴い、人口が増えた。', hiragana: 'えきまえのかいはつにともない、じんこうがふえた。', vietnamese: 'Kéo theo việc phát triển khu trước ga, dân số đã tăng.', english: 'Along with the redevelopment around the station, the population increased.'),
      ],
      notes: ['Rất hay gặp trong báo chí, báo cáo.', 'Biến thể: に伴い.'],
    ),
    GrammarLesson(
      id: 'g_n2_007',
      pattern: '〜をめぐって',
      title: 'Xung quanh / về vấn đề',
      explanation: 'Dùng khi có tranh luận, đối lập ý kiến hoặc sự kiện xoay quanh một chủ đề.',
      jlptLevel: 'N2',
      examples: [
        ExampleSentence(japanese: '新しい制度をめぐって、さまざまな意見が出ている。', hiragana: 'あたらしいせいどをめぐって、さまざまないけんがでている。', vietnamese: 'Xung quanh chế độ mới đang có nhiều ý kiến khác nhau.', english: 'Various opinions are emerging over the new system.'),
        ExampleSentence(japanese: '土地の利用をめぐる争いが続いている。', hiragana: 'とちのりようをめぐるあらそいがつづいている。', vietnamese: 'Tranh chấp xoay quanh việc sử dụng đất vẫn tiếp diễn.', english: 'The dispute over land use continues.'),
      ],
      notes: ['Rất điển hình trong bài báo thời sự.', 'Dạng bổ nghĩa: 〜をめぐる + danh từ.'],
    ),
    GrammarLesson(
      id: 'g_n2_008',
      pattern: '〜ものの',
      title: 'Mặc dù ... nhưng',
      explanation: 'Công nhận một thực tế ở vế đầu nhưng kết quả vế sau không như mong đợi.',
      jlptLevel: 'N2',
      examples: [
        ExampleSentence(japanese: '日本へ留学したものの、最初は友達ができなかった。', hiragana: 'にほんへりゅうがくしたものの、さいしょはともだちができなかった。', vietnamese: 'Mặc dù đi du học Nhật nhưng ban đầu tôi không kết được bạn.', english: 'Although I studied abroad in Japan, at first I could not make friends.'),
        ExampleSentence(japanese: '薬を飲んだものの、熱は下がらなかった。', hiragana: 'くすりをのんだものの、ねつはさがらなかった。', vietnamese: 'Dù uống thuốc nhưng sốt vẫn không hạ.', english: 'Although I took medicine, my fever did not go down.'),
      ],
      notes: ['Sắc thái trang trọng hơn けれども.', 'Hay gặp trong văn kể chuyện và báo cáo.'],
    ),
    GrammarLesson(
      id: 'g_n2_009',
      pattern: '〜に違いない',
      title: 'Hẳn là / chắc chắn',
      explanation: 'N2 vẫn gặp rất nhiều trong văn viết, dùng khi suy luận mạnh dựa trên căn cứ.',
      jlptLevel: 'N2',
      examples: [
        ExampleSentence(japanese: 'あの表情からすると、彼は真実を知っているに違いない。', hiragana: 'あのひょうじょうからすると、かれはしんじつをしっているにちがいない。', vietnamese: 'Nhìn vẻ mặt đó thì anh ấy hẳn là biết sự thật.', english: 'Judging from that expression, he must know the truth.'),
        ExampleSentence(japanese: 'ここまで準備したのだから、成功するに違いありません。', hiragana: 'ここまでじゅんびしたのだから、せいこうするにちがいありません。', vietnamese: 'Đã chuẩn bị đến mức này thì chắc chắn sẽ thành công.', english: 'We have prepared this much, so it must succeed.'),
      ],
      notes: ['Thường dùng khi muốn nhấn mạnh niềm tin mạnh.', 'Trang trọng và quyết đoán.'],
    ),
    GrammarLesson(
      id: 'g_n2_010',
      pattern: '〜にしては',
      title: 'So với ... thì',
      explanation: 'So sánh kết quả thực tế với chuẩn mực thông thường rồi thấy khác dự đoán.',
      jlptLevel: 'N2',
      examples: [
        ExampleSentence(japanese: 'このレストランは駅前にしては静かですね。', hiragana: 'このレストランはえきまえにしてはしずかですね。', vietnamese: 'Nhà hàng này so với vị trí trước ga thì khá yên tĩnh nhỉ.', english: 'This restaurant is quiet for one near the station.'),
        ExampleSentence(japanese: '彼は一年目にしては仕事が速い。', hiragana: 'かれはいちねんめにしてはしごとがはやい。', vietnamese: 'So với nhân viên năm đầu thì anh ấy làm việc nhanh.', english: 'He works quickly for a first-year employee.'),
      ],
      notes: ['Mang sắc thái đánh giá ngoài dự kiến.', 'Hay dùng trong giao tiếp và nhận xét.'],
    ),
  ];

  static final List<GrammarLesson> _n1Grammar = [
    GrammarLesson(
      id: 'g_n1_001',
      pattern: '〜にほかならない',
      title: 'Không gì khác ngoài',
      explanation: 'Dùng để khẳng định bản chất thực sự của một vấn đề theo lối diễn đạt trang trọng.',
      jlptLevel: 'N1',
      examples: [
        ExampleSentence(japanese: '今回の成功は、チーム全員の努力の結果にほかなりません。', hiragana: 'こんかいのせいこうは、チームぜんいんのどりょくのけっかにほかなりません。', vietnamese: 'Thành công lần này không gì khác ngoài kết quả nỗ lực của cả đội.', english: 'This success is nothing other than the result of the whole team\'s efforts.'),
        ExampleSentence(japanese: '言葉は文化を映す鏡にほかならない。', hiragana: 'ことばはぶんかをうつすかがみにほかならない。', vietnamese: 'Ngôn ngữ không gì khác ngoài tấm gương phản chiếu văn hóa.', english: 'Language is nothing other than a mirror reflecting culture.'),
      ],
      notes: ['Rất đặc trưng cho văn nghị luận.', 'Sắc thái khẳng định mạnh, trang trọng.'],
    ),
    GrammarLesson(
      id: 'g_n1_002',
      pattern: '〜を皮切りに',
      title: 'Mở đầu bằng',
      explanation: 'Chỉ điểm khởi đầu của chuỗi sự kiện hoặc hoạt động nối tiếp sau đó.',
      jlptLevel: 'N1',
      examples: [
        ExampleSentence(japanese: '東京公演を皮切りに、全国ツアーが始まる。', hiragana: 'とうきょうこうえんをかわきりに、ぜんこくツアーがはじまる。', vietnamese: 'Mở đầu bằng buổi diễn Tokyo, tour toàn quốc sẽ bắt đầu.', english: 'Starting with the Tokyo performance, the nationwide tour will begin.'),
        ExampleSentence(japanese: '四月の研修を皮切りとして、新制度が導入された。', hiragana: 'しがつのけんしゅうをかわきりとして、しんせいどがどうにゅうされた。', vietnamese: 'Mở đầu từ đợt tập huấn tháng tư, chế độ mới đã được áp dụng.', english: 'Beginning with the April training, the new system was introduced.'),
      ],
      notes: ['Thường gặp trong tin tức, thông báo.', 'Biến thể: を皮切りとして.'],
    ),
    GrammarLesson(
      id: 'g_n1_003',
      pattern: '〜まみれ',
      title: 'Đầy / bê bết',
      explanation: 'Chỉ tình trạng bị phủ đầy một thứ gì đó, thường mang sắc thái tiêu cực.',
      jlptLevel: 'N1',
      examples: [
        ExampleSentence(japanese: '子どもたちは泥まみれになって遊んでいた。', hiragana: 'こどもたちはどろまみれになってあそんでいた。', vietnamese: 'Bọn trẻ chơi đùa đến mức lấm lem đầy bùn.', english: 'The children were playing, covered in mud.'),
        ExampleSentence(japanese: '失敗が続き、頭の中は不安まみれだった。', hiragana: 'しっぱいがつづき、あたまのなかはふあんまみれだった。', vietnamese: 'Thất bại nối tiếp khiến đầu óc tôi đầy bất an.', english: 'After repeated failures, my mind was filled with anxiety.'),
      ],
      notes: ['Dùng được với nghĩa bóng.', 'Khác với だらけ ở cảm giác nặng, đặc quánh hơn.'],
    ),
    GrammarLesson(
      id: 'g_n1_004',
      pattern: '〜ずにはすまない',
      title: 'Không thể không',
      explanation: 'Một tình huống tất yếu dẫn đến hành động hoặc cảm xúc không thể tránh.',
      jlptLevel: 'N1',
      examples: [
        ExampleSentence(japanese: 'その映画を見たら、だれでも涙を流さずにはすまない。', hiragana: 'そのえいがをみたら、だれでもなみだをながさずにはすまない。', vietnamese: 'Xem bộ phim đó thì ai cũng không thể không rơi nước mắt.', english: 'Anyone who watches that movie cannot help but cry.'),
        ExampleSentence(japanese: '彼の態度には文句を言わずにはすまなかった。', hiragana: 'かれのたいどにはもんくをいわずにはすまなかった。', vietnamese: 'Thái độ của anh ấy khiến tôi không thể không phàn nàn.', english: 'His attitude made me unable to keep from complaining.'),
      ],
      notes: ['Sắc thái mạnh và văn viết.', 'Hay đi với cảm xúc hoặc phản ứng tất yếu.'],
    ),
    GrammarLesson(
      id: 'g_n1_005',
      pattern: '〜にかたくない',
      title: 'Không khó để ...',
      explanation: 'Diễn tả việc tưởng tượng, suy đoán là điều rất dễ dàng.',
      jlptLevel: 'N1',
      examples: [
        ExampleSentence(japanese: '被害者の苦しみは想像にかたくない。', hiragana: 'ひがいしゃのくるしみはそうぞうにかたくない。', vietnamese: 'Không khó để tưởng tượng nỗi khổ của nạn nhân.', english: 'It is not hard to imagine the suffering of the victims.'),
        ExampleSentence(japanese: 'あの結果に彼が落胆したことは察するにかたくない。', hiragana: 'あのけっかにかれがらくたんしたことはさっするにかたくない。', vietnamese: 'Không khó để đoán anh ấy đã thất vọng với kết quả đó.', english: 'It is easy to infer that he was disappointed by that result.'),
      ],
      notes: ['Hay kết hợp với 想像する, 察する.', 'Mang sắc thái nghị luận.'],
    ),
    GrammarLesson(
      id: 'g_n1_006',
      pattern: '〜ならでは',
      title: 'Chỉ ... mới có',
      explanation: 'Nhấn mạnh đặc trưng riêng chỉ đối tượng đó mới thể hiện được.',
      jlptLevel: 'N1',
      examples: [
        ExampleSentence(japanese: '京都ならではの落ち着いた町並みが好きです。', hiragana: 'きょうとならではのおちついたまちなみがすきです。', vietnamese: 'Tôi thích phố xá trầm lắng rất riêng chỉ Kyoto mới có.', english: 'I like the calm streetscape unique to Kyoto.'),
        ExampleSentence(japanese: '職人ならではの丁寧な仕事ぶりに感動した。', hiragana: 'しょくにんならではのていねいなしごとぶりにかんどうした。', vietnamese: 'Tôi ấn tượng trước lối làm việc tỉ mỉ chỉ có ở nghệ nhân.', english: 'I was impressed by the careful workmanship unique to a craftsman.'),
      ],
      notes: ['Thường dùng với danh từ.', 'Rất hợp khi mô tả văn hóa, sản phẩm, địa phương.'],
    ),
    GrammarLesson(
      id: 'g_n1_007',
      pattern: '〜をものともせず',
      title: 'Bất chấp / không nao núng trước',
      explanation: 'Dùng để ca ngợi tinh thần vượt qua khó khăn, trở ngại.',
      jlptLevel: 'N1',
      examples: [
        ExampleSentence(japanese: '選手たちは強風をものともせず走り続けた。', hiragana: 'せんしゅたちはきょうふうをものともせずはしりつづけた。', vietnamese: 'Các vận động viên tiếp tục chạy bất chấp gió mạnh.', english: 'The athletes kept running in spite of the strong wind.'),
        ExampleSentence(japanese: '彼女は批判をものともせず、自分の信念を貫いた。', hiragana: 'かのじょはひはんをものともせず、じぶんのしんねんをつらぬいた。', vietnamese: 'Cô ấy giữ vững niềm tin của mình bất chấp chỉ trích.', english: 'She stuck to her beliefs despite criticism.'),
      ],
      notes: ['Mang sắc thái tích cực, khâm phục.', 'Thường dùng với trở ngại mạnh như 困難, 批判.'],
    ),
    GrammarLesson(
      id: 'g_n1_008',
      pattern: '〜とあって',
      title: 'Chính vì ... nên',
      explanation: 'Giải thích nguyên nhân được mọi người chấp nhận như hiển nhiên.',
      jlptLevel: 'N1',
      examples: [
        ExampleSentence(japanese: '連休初日とあって、駅は朝から混雑していた。', hiragana: 'れんきゅうしょにちとあって、えきはあさからこんざつしていた。', vietnamese: 'Chính vì là ngày đầu kỳ nghỉ dài nên ga đông nghịt từ sáng.', english: 'Since it was the first day of the holiday, the station was crowded from morning.'),
        ExampleSentence(japanese: '人気作家の新作とあって、多くの人が店に並んだ。', hiragana: 'にんきさっかのしんさくとあって、おおくのひとがみせにならんだ。', vietnamese: 'Vì là tác phẩm mới của tác giả nổi tiếng nên nhiều người đã xếp hàng.', english: 'Because it was a new work by a popular author, many people lined up.'),
      ],
      notes: ['Thường đi với sự kiện, lý do ai cũng hiểu.', 'Hay gặp trong văn báo chí.'],
    ),
    GrammarLesson(
      id: 'g_n1_009',
      pattern: '〜といえども',
      title: 'Dù là ... đi nữa',
      explanation: 'Thừa nhận một thân phận hay địa vị nhưng nhấn mạnh ngoại lệ hoặc giới hạn.',
      jlptLevel: 'N1',
      examples: [
        ExampleSentence(japanese: 'プロといえども、毎日の基礎練習は欠かせない。', hiragana: 'プロといえども、まいにちのきそれんしゅうはかかせない。', vietnamese: 'Dù là chuyên nghiệp đi nữa cũng không thể thiếu luyện cơ bản mỗi ngày.', english: 'Even professionals cannot do without daily basic practice.'),
        ExampleSentence(japanese: '子どもといえども、約束は守るべきだ。', hiragana: 'こどもといえども、やくそくはまもるべきだ。', vietnamese: 'Dù là trẻ con thì cũng nên giữ lời hứa.', english: 'Even children should keep their promises.'),
      ],
      notes: ['Trang trọng hơn でも.', 'Phổ biến trong văn nghị luận.'],
    ),
    GrammarLesson(
      id: 'g_n1_010',
      pattern: '〜極まりない / 〜極まる',
      title: 'Vô cùng / cực kỳ',
      explanation: 'Nhấn mạnh mức độ cực hạn, thường dùng với cảm xúc hoặc tính chất.',
      jlptLevel: 'N1',
      examples: [
        ExampleSentence(japanese: 'その判決は不公平極まりない。', hiragana: 'そのはんけつはふこうへいきわまりない。', vietnamese: 'Phán quyết đó vô cùng bất công.', english: 'That ruling is extremely unfair.'),
        ExampleSentence(japanese: '失礼極まる態度に会場が静まり返った。', hiragana: 'しつれいきわまるたいどにかいじょうがしずまりかえった。', vietnamese: 'Cả hội trường lặng đi trước thái độ cực kỳ vô lễ đó.', english: 'The venue fell silent at that extremely rude attitude.'),
      ],
      notes: ['Hay dùng trong văn viết, phê bình, bình luận.', 'Thường đứng sau danh từ/tính chất tiêu cực.'],
    ),
  ];

}
