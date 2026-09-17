from pathlib import Path

levels = {
    'N5': [
        {
            'id': 'g_n5_001', 'pattern': '〜は〜です', 'title': 'Câu khẳng định cơ bản',
            'explanation': 'Mẫu câu nền tảng để giới thiệu người, vật và nghề nghiệp trong văn phong lịch sự.',
            'examples': [
                ('私は留学生です。', 'わたしはりゅうがくせいです。', 'Tôi là du học sinh.', 'I am an international student.'),
                ('これは日本の地図です。', 'これはにほんのちずです。', 'Đây là bản đồ Nhật Bản.', 'This is a map of Japan.'),
            ],
            'notes': ['は đọc là wa khi làm trợ từ chủ đề.', 'です giúp câu lịch sự và mềm hơn.'],
        },
        {
            'id': 'g_n5_002', 'pattern': '〜は〜ですか', 'title': 'Câu hỏi yes/no',
            'explanation': 'Chỉ cần thêm か ở cuối câu để tạo câu hỏi lịch sự, không đảo trật tự từ.',
            'examples': [
                ('あなたは先生ですか。', 'あなたはせんせいですか。', 'Bạn là giáo viên phải không?', 'Are you a teacher?'),
                ('これは新しい辞書ですか。', 'これはあたらしいじしょですか。', 'Đây có phải từ điển mới không?', 'Is this a new dictionary?'),
            ],
            'notes': ['Trong hội thoại thân mật có thể bỏ か và lên giọng.', 'Khi trả lời có thể dùng はい / いいえ.'],
        },
        {
            'id': 'g_n5_003', 'pattern': '〜の〜', 'title': 'Sở hữu và liên kết danh từ',
            'explanation': 'Trợ từ の nối hai danh từ, thể hiện sở hữu hoặc bổ nghĩa.',
            'examples': [
                ('日本語の本を買いました。', 'にほんごのほんをかいました。', 'Tôi đã mua sách tiếng Nhật.', 'I bought a Japanese book.'),
                ('田中さんのかばんは青いです。', 'たなかさんのかばんはあおいです。', 'Cặp của anh Tanaka màu xanh.', 'Tanaka-san\'s bag is blue.'),
            ],
            'notes': ['Có thể nối nhiều lần: 日本の大学の先生.', 'Rất hay gặp trong tiêu đề và tên gọi.'],
        },
        {
            'id': 'g_n5_004', 'pattern': '〜を〜', 'title': 'Tân ngữ trực tiếp',
            'explanation': 'を đánh dấu đối tượng chịu tác động trực tiếp của động từ.',
            'examples': [
                ('毎朝コーヒーを飲みます。', 'まいあさコーヒーをのみます。', 'Mỗi sáng tôi uống cà phê.', 'I drink coffee every morning.'),
                ('図書館で新聞を読みます。', 'としょかんでしんぶんをよみます。', 'Tôi đọc báo ở thư viện.', 'I read the newspaper at the library.'),
            ],
            'notes': ['を thường đọc là o trong lời nói.', 'Đi với tha động từ là chủ yếu.'],
        },
        {
            'id': 'g_n5_005', 'pattern': '〜に行きます / 来ます / 帰ります', 'title': 'Nơi đến',
            'explanation': 'に chỉ đích đến khi đi, đến hoặc về.',
            'examples': [
                ('土曜日に友達の家に行きます。', 'どようびにともだちのいえにいきます。', 'Thứ bảy tôi đến nhà bạn.', 'I will go to my friend\'s house on Saturday.'),
                ('夜九時に家に帰ります。', 'よるくじにいえにかえります。', 'Tôi về nhà lúc 9 giờ tối.', 'I go home at 9 p.m.'),
            ],
            'notes': ['に cũng dùng với thời gian.', 'へ có thể thay cho に khi nhấn mạnh hướng.'],
        },
        {
            'id': 'g_n5_006', 'pattern': '〜で〜', 'title': 'Địa điểm hành động và phương tiện',
            'explanation': 'で dùng để chỉ nơi diễn ra hành động hoặc công cụ/phương tiện sử dụng.',
            'examples': [
                ('教室で日本語を勉強します。', 'きょうしつでにほんごをべんきょうします。', 'Tôi học tiếng Nhật trong lớp.', 'I study Japanese in the classroom.'),
                ('電車で会社へ行きます。', 'でんしゃでかいしゃへいきます。', 'Tôi đi làm bằng tàu điện.', 'I go to work by train.'),
            ],
            'notes': ['に dùng cho tồn tại, で dùng cho hành động.', 'で cũng dùng với dụng cụ như 箸で.'],
        },
        {
            'id': 'g_n5_007', 'pattern': '〜ます / 〜ません / 〜ました', 'title': 'Chia động từ lịch sự',
            'explanation': 'Đây là nhóm mẫu cực quan trọng để dùng động từ trong hội thoại hàng ngày.',
            'examples': [
                ('毎晩三十分勉強します。', 'まいばんさんじゅっぷんべんきょうします。', 'Mỗi tối tôi học 30 phút.', 'I study for 30 minutes every night.'),
                ('昨日はテレビを見ませんでした。', 'きのうはテレビをみませんでした。', 'Hôm qua tôi đã không xem TV.', 'I did not watch TV yesterday.'),
            ],
            'notes': ['ます là hiện tại/tương lai lịch sự.', 'Quá khứ phủ định là ませんでした.'],
        },
        {
            'id': 'g_n5_008', 'pattern': '〜たいです', 'title': 'Diễn tả mong muốn',
            'explanation': 'Gắn vào gốc ます để nói người nói muốn làm điều gì.',
            'examples': [
                ('日本へ旅行したいです。', 'にほんへりょこうしたいです。', 'Tôi muốn du lịch Nhật Bản.', 'I want to travel to Japan.'),
                ('今日は早く寝たいです。', 'きょうははやくねたいです。', 'Hôm nay tôi muốn ngủ sớm.', 'I want to sleep early today.'),
            ],
            'notes': ['たい chia như tính từ đuôi い.', 'Với người khác thường dùng たがっています.'],
        },
        {
            'id': 'g_n5_009', 'pattern': '〜ている', 'title': 'Đang làm / trạng thái',
            'explanation': 'Diễn tả hành động đang tiếp diễn hoặc trạng thái kết quả duy trì.',
            'examples': [
                ('今、駅で待っています。', 'いま、えきでまっています。', 'Bây giờ tôi đang đợi ở ga.', 'I am waiting at the station now.'),
                ('兄は東京に住んでいます。', 'あにはとうきょうにすんでいます。', 'Anh trai tôi đang sống ở Tokyo.', 'My older brother lives in Tokyo.'),
            ],
            'notes': ['Một số động từ như 知る, 結婚する dùng để chỉ trạng thái.', 'Bản thân mẫu này xuất hiện rất nhiều trong đề nghe.'],
        },
        {
            'id': 'g_n5_010', 'pattern': '〜から〜まで', 'title': 'Từ ... đến ...',
            'explanation': 'Dùng cho thời gian hoặc phạm vi không gian.',
            'examples': [
                ('授業は九時から十二時までです。', 'じゅぎょうはくじからじゅうにじまでです。', 'Lớp học từ 9 giờ đến 12 giờ.', 'Class is from 9 to 12.'),
                ('大阪から京都までバスで行きました。', 'おおさかからきょうとまでバスでいきました。', 'Tôi đã đi từ Osaka đến Kyoto bằng xe buýt.', 'I went from Osaka to Kyoto by bus.'),
            ],
            'notes': ['から còn có nghĩa là vì.', 'まで đôi khi mang nghĩa đến tận, cho đến cả.'],
        },
    ],
    'N4': [
        {
            'id': 'g_n4_001', 'pattern': '〜てから', 'title': 'Sau khi làm xong',
            'explanation': 'Diễn tả thứ tự hành động: sau A thì mới B.',
            'examples': [
                ('朝ご飯を食べてから、学校へ行きます。', 'あさごはんをたべてから、がっこうへいきます。', 'Sau khi ăn sáng tôi đi học.', 'After eating breakfast, I go to school.'),
                ('宿題をしてから、寝ました。', 'しゅくだいをしてから、ねました。', 'Sau khi làm bài tập xong tôi đi ngủ.', 'I went to sleep after doing my homework.'),
            ],
            'notes': ['Phù hợp để nói trình tự rõ ràng.', 'Rất hay xuất hiện trong hội thoại sinh hoạt.'],
        },
        {
            'id': 'g_n4_002', 'pattern': '〜ながら', 'title': 'Vừa ... vừa ...',
            'explanation': 'Hai hành động đồng thời do cùng một chủ thể thực hiện.',
            'examples': [
                ('音楽を聞きながら、レポートを書きます。', 'おんがくをききながら、レポートをかきます。', 'Tôi vừa nghe nhạc vừa viết báo cáo.', 'I write a report while listening to music.'),
                ('歩きながら電話しないでください。', 'あるきながらでんわしないでください。', 'Xin đừng vừa đi vừa gọi điện.', 'Please do not talk on the phone while walking.'),
            ],
            'notes': ['Hành động chính thường đứng ở mệnh đề sau.', 'Chủ thể phải giống nhau.'],
        },
        {
            'id': 'g_n4_003', 'pattern': '〜たり〜たりする', 'title': 'Liệt kê hành động tiêu biểu',
            'explanation': 'Nói một vài hành động đại diện chứ không phải toàn bộ.',
            'examples': [
                ('休みの日は本を読んだり、料理をしたりします。', 'やすみのひはほんをよんだり、りょうりをしたりします。', 'Ngày nghỉ tôi đọc sách, nấu ăn các kiểu.', 'On my days off I do things like reading and cooking.'),
                ('天気は暑かったり寒かったりです。', 'てんきはあつかったりさむかったりです。', 'Thời tiết lúc nóng lúc lạnh.', 'The weather is sometimes hot and sometimes cold.'),
            ],
            'notes': ['Có thể dùng với động từ, tính từ, danh từ.', 'Cuối câu thường kết bằng します / です.'],
        },
        {
            'id': 'g_n4_004', 'pattern': '〜ために', 'title': 'Để / nhằm mục đích',
            'explanation': 'Nói mục đích của hành động hoặc vì lợi ích của điều gì.',
            'examples': [
                ('日本で働くために、日本語を勉強しています。', 'にほんではたらくために、にほんごをべんきょうしています。', 'Để làm việc ở Nhật tôi đang học tiếng Nhật.', 'I am studying Japanese to work in Japan.'),
                ('健康のために、毎日歩いています。', 'けんこうのために、まいにちあるいています。', 'Vì sức khỏe tôi đi bộ mỗi ngày.', 'I walk every day for my health.'),
            ],
            'notes': ['Động từ điển + ために.', 'Danh từ + のために.'],
        },
        {
            'id': 'g_n4_005', 'pattern': '〜そうです（様態）', 'title': 'Trông có vẻ',
            'explanation': 'Dựa vào bề ngoài để suy đoán trạng thái ngay trước mắt.',
            'examples': [
                ('このスープは熱そうですね。', 'このスープはあつそうですね。', 'Món súp này trông có vẻ nóng nhỉ.', 'This soup looks hot.'),
                ('彼は元気そうに見えます。', 'かれはげんきそうにみえます。', 'Anh ấy trông có vẻ khỏe.', 'He looks energetic.'),
            ],
            'notes': ['いい -> よさそう.', 'Khác với 〜そうです mang nghĩa nghe nói.'],
        },
        {
            'id': 'g_n4_006', 'pattern': '〜ようになる', 'title': 'Trở nên có thể / thành thói quen',
            'explanation': 'Diễn tả sự thay đổi về năng lực hoặc trạng thái theo thời gian.',
            'examples': [
                ('ひらがなが読めるようになりました。', 'ひらがながよめるようになりました。', 'Tôi đã trở nên đọc được hiragana.', 'I became able to read hiragana.'),
                ('最近、早く起きるようになりました。', 'さいきん、はやくおきるようになりました。', 'Dạo gần đây tôi đã có thói quen dậy sớm.', 'Recently I have started waking up early.'),
            ],
            'notes': ['Thường đi với động từ khả năng hoặc động từ thường.', 'Nhấn mạnh kết quả thay đổi.'],
        },
        {
            'id': 'g_n4_007', 'pattern': '〜なければならない', 'title': 'Phải làm',
            'explanation': 'Một mẫu rất quan trọng để diễn tả nghĩa vụ, trách nhiệm.',
            'examples': [
                ('明日までにレポートを出さなければなりません。', 'あしたまでにレポートをださなければなりません。', 'Tôi phải nộp báo cáo trước ngày mai.', 'I must submit the report by tomorrow.'),
                ('学生は時間を守らなければならない。', 'がくせいはじかんをまもらなければならない。', 'Học sinh phải đúng giờ.', 'Students must be punctual.'),
            ],
            'notes': ['Trong khẩu ngữ hay rút gọn thành 〜なきゃ.', 'Mang sắc thái bắt buộc.'],
        },
        {
            'id': 'g_n4_008', 'pattern': '〜てもいい', 'title': 'Được phép làm',
            'explanation': 'Xin phép hoặc cho phép thực hiện hành động.',
            'examples': [
                ('ここに座ってもいいですか。', 'ここにすわってもいいですか。', 'Tôi ngồi ở đây có được không?', 'May I sit here?'),
                ('写真を撮ってもいいですよ。', 'しゃしんをとってもいいですよ。', 'Bạn có thể chụp ảnh nhé.', 'You may take photos.'),
            ],
            'notes': ['Phủ định là 〜てはいけない.', 'Rất phổ biến trong lớp học và nơi công cộng.'],
        },
        {
            'id': 'g_n4_009', 'pattern': '〜てしまう', 'title': 'Lỡ / hoàn thành mất rồi',
            'explanation': 'Diễn tả hoàn thành hoàn toàn hoặc cảm giác tiếc nuối, không mong muốn.',
            'examples': [
                ('電車で寝てしまいました。', 'でんしゃでねてしまいました。', 'Tôi lỡ ngủ quên trên tàu.', 'I accidentally fell asleep on the train.'),
                ('宿題はもう終わってしまいました。', 'しゅくだいはもうおわってしまいました。', 'Bài tập đã xong mất rồi.', 'I have already finished the homework.'),
            ],
            'notes': ['Khẩu ngữ rút gọn thành 〜ちゃう / 〜じゃう.', 'Ngữ cảnh quyết định nghĩa tích cực hay tiếc nuối.'],
        },
        {
            'id': 'g_n4_010', 'pattern': '〜と思う', 'title': 'Tôi nghĩ rằng',
            'explanation': 'Dùng để diễn tả ý kiến, suy nghĩ và cảm nhận cá nhân.',
            'examples': [
                ('日本語はおもしろいと思います。', 'にほんごはおもしろいとおもいます。', 'Tôi nghĩ tiếng Nhật thú vị.', 'I think Japanese is interesting.'),
                ('あの店は安いと思いません。', 'あのみせはやすいとおもいません。', 'Tôi không nghĩ quán đó rẻ.', 'I do not think that shop is cheap.'),
            ],
            'notes': ['Với động từ/tính từ thường dùng mệnh đề thường + と思う.', 'Lịch sự hơn khi thêm 〜と思います.'],
        },
    ],
    'N3': [
        {
            'id': 'g_n3_001', 'pattern': '〜ことにする', 'title': 'Quyết định sẽ làm',
            'explanation': 'Người nói chủ động đưa ra quyết định của bản thân.',
            'examples': [
                ('今年から毎日漢字を五つ覚えることにしました。', 'ことしからまいにちかんじをいつつおぼえることにしました。', 'Từ năm nay tôi quyết định mỗi ngày học 5 kanji.', 'From this year I decided to memorize five kanji a day.'),
                ('甘い物は食べないことにしています。', 'あまいものはたべないことにしています。', 'Tôi duy trì quyết định không ăn đồ ngọt.', 'I make it a rule not to eat sweets.'),
            ],
            'notes': ['ことにしている diễn tả quy tắc tự đặt ra.', 'Khác với ことになる là do hoàn cảnh quyết định.'],
        },
        {
            'id': 'g_n3_002', 'pattern': '〜ことになる', 'title': 'Được quyết định là / trở thành',
            'explanation': 'Kết quả do quy định, hoàn cảnh hoặc người khác quyết định.',
            'examples': [
                ('来月大阪支社へ転勤することになりました。', 'らいげつおおさかししゃへてんきんすることになりました。', 'Tôi đã được quyết định chuyển công tác đến chi nhánh Osaka vào tháng sau.', 'It has been decided that I will transfer to the Osaka branch next month.'),
                ('会議はオンラインで行うことになっています。', 'かいぎはオンラインでおこなうことになっています。', 'Cuộc họp được quy định sẽ diễn ra online.', 'It is مقرر that the meeting will be held online.'),
            ],
            'notes': ['Thể ことになっている diễn tả quy tắc/quy định.', 'Chủ ngữ ít mang tính chủ động.'],
        },
        {
            'id': 'g_n3_003', 'pattern': '〜ようにする', 'title': 'Cố gắng để / tạo thói quen',
            'explanation': 'Nói về nỗ lực có ý thức nhằm hình thành hành vi mong muốn.',
            'examples': [
                ('忘れないように、メモするようにしています。', 'わすれないように、メモするようにしています。', 'Để khỏi quên, tôi cố tạo thói quen ghi chú.', 'To avoid forgetting, I make it a habit to take notes.'),
                ('毎日日本語を聞くようにしてください。', 'まいにちにほんごをきくようにしてください。', 'Hãy cố gắng nghe tiếng Nhật mỗi ngày.', 'Please try to listen to Japanese every day.'),
            ],
            'notes': ['ようにする nhấn mạnh nỗ lực có chủ đích.', 'Khác với ようになる là kết quả thay đổi.'],
        },
        {
            'id': 'g_n3_004', 'pattern': '〜ようになる', 'title': 'Dần trở nên',
            'explanation': 'Dùng khi kết quả thay đổi diễn ra tự nhiên sau quá trình rèn luyện.',
            'examples': [
                ('ニュースの内容が少しずつ分かるようになりました。', 'ニュースのないようがすこしずつわかるようになりました。', 'Tôi dần dần hiểu được nội dung tin tức.', 'I gradually became able to understand news content.'),
                ('練習して、きれいに発音できるようになった。', 'れんしゅうして、きれいにはつおんできるようになった。', 'Luyện tập xong tôi đã phát âm được rõ hơn.', 'After practice I became able to pronounce clearly.'),
            ],
            'notes': ['Thường đi cùng quá trình thay đổi theo thời gian.', 'Rất hợp khi nói về tiến bộ học tập.'],
        },
        {
            'id': 'g_n3_005', 'pattern': '〜ば〜ほど', 'title': 'Càng ... càng ...',
            'explanation': 'Diễn tả hai vế thay đổi tỉ lệ thuận.',
            'examples': [
                ('日本語は勉強すればするほど面白くなります。', 'にほんごはべんきょうすればするほどおもしろくなります。', 'Tiếng Nhật càng học càng thú vị.', 'The more you study Japanese, the more interesting it becomes.'),
                ('この町は歩けば歩くほど好きになります。', 'このまちはあるけばあるほどすきになります。', 'Thị trấn này càng đi bộ khám phá càng thích.', 'The more I walk around this town, the more I like it.'),
            ],
            'notes': ['Mẫu nhấn mạnh mối tương quan tăng dần.', 'Vế sau thường chứa cảm nhận/kết quả.'],
        },
        {
            'id': 'g_n3_006', 'pattern': '〜ように見える / 聞こえる', 'title': 'Có vẻ như / nghe như',
            'explanation': 'Diễn tả ấn tượng rút ra từ quan sát hoặc âm thanh.',
            'examples': [
                ('彼は忙しいように見えます。', 'かれはいそがしいようにみえます。', 'Anh ấy trông có vẻ bận.', 'He seems busy.'),
                ('外は雨が降っているように聞こえます。', 'そとはあめがふっているようにきこえます。', 'Bên ngoài nghe như đang mưa.', 'It sounds like it is raining outside.'),
            ],
            'notes': ['Khác với そうだ mang suy đoán trực quan ngắn gọn hơn.', 'Thường gặp trong văn miêu tả.'],
        },
        {
            'id': 'g_n3_007', 'pattern': '〜かもしれない', 'title': 'Có lẽ',
            'explanation': 'Biểu thị khả năng có thể xảy ra với độ chắc chắn không cao.',
            'examples': [
                ('明日は雪が降るかもしれません。', 'あしたはゆきがふるかもしれません。', 'Ngày mai có lẽ trời sẽ có tuyết.', 'It may snow tomorrow.'),
                ('あの人はもう帰ったかもしれない。', 'あのひとはもうかえったかもしれない。', 'Người đó có lẽ đã về rồi.', 'That person might have already gone home.'),
            ],
            'notes': ['Mức chắc chắn thấp hơn でしょう.', 'Có thể dùng ở cả văn nói và viết.'],
        },
        {
            'id': 'g_n3_008', 'pattern': '〜わけではない', 'title': 'Không hẳn là',
            'explanation': 'Phủ định một phần, làm mềm phát biểu để tránh tuyệt đối hóa.',
            'examples': [
                ('辛い物が嫌いなわけではありません。', 'からいものがきらいなわけではありません。', 'Không hẳn là tôi ghét đồ cay.', 'It is not that I dislike spicy food.'),
                ('忙しいからといって、全然勉強しないわけではない。', 'いそがしいからといって、ぜんぜんべんきょうしないわけではない。', 'Dù bận nhưng không phải là tôi không học chút nào.', 'Even though I am busy, it is not that I do not study at all.'),
            ],
            'notes': ['Rất hữu ích khi trình bày ý kiến cân bằng.', 'Hay đi cùng biểu thức giải thích.'],
        },
        {
            'id': 'g_n3_009', 'pattern': '〜たばかり', 'title': 'Vừa mới làm xong',
            'explanation': 'Diễn tả một hành động vừa xảy ra cách đây không lâu theo cảm nhận người nói.',
            'examples': [
                ('さっき昼ご飯を食べたばかりです。', 'さっきひるごはんをたべたばかりです。', 'Tôi vừa mới ăn trưa xong.', 'I just ate lunch.'),
                ('日本に来たばかりで、まだ道が分かりません。', 'にほんにきたばかりで、まだみちがわかりません。', 'Vì tôi mới sang Nhật nên vẫn chưa rành đường.', 'I just came to Japan, so I still do not know the roads well.'),
            ],
            'notes': ['Mang tính cảm nhận, không phải thời gian tuyệt đối.', 'Khác với ところ là nhấn mạnh đúng thời điểm.'],
        },
        {
            'id': 'g_n3_010', 'pattern': '〜に違いない', 'title': 'Chắc chắn là',
            'explanation': 'Người nói suy luận rất mạnh dựa trên căn cứ hiện có.',
            'examples': [
                ('彼はこの仕事に向いているに違いない。', 'かれはこのしごとにむいているにちがいない。', 'Anh ấy chắc chắn hợp với công việc này.', 'He must be suited for this job.'),
                ('電気がついているから、だれかいるに違いありません。', 'でんきがついているから、だれかいるにちがいありません。', 'Đèn đang bật nên chắc chắn có ai ở đó.', 'The light is on, so there must be someone there.'),
            ],
            'notes': ['Mạnh hơn でしょう và かもしれない.', 'Thường dùng khi suy luận có cơ sở.'],
        },
    ],
    'N2': [
        {
            'id': 'g_n2_001', 'pattern': '〜わけにはいかない', 'title': 'Không thể / không đành',
            'explanation': 'Dùng khi hoàn cảnh, trách nhiệm hoặc đạo đức khiến người nói không thể làm điều gì.',
            'examples': [
                ('明日は大事な試験があるので、休むわけにはいきません。', 'あしたはだいじなしけんがあるので、やすむわけにはいきません。', 'Ngày mai có kỳ thi quan trọng nên tôi không thể nghỉ được.', 'I cannot take a day off because I have an important exam tomorrow.'),
                ('約束したから、途中でやめるわけにはいかない。', 'やくそくしたから、とちゅうでやめるわけにはいかない。', 'Vì đã hứa rồi nên không thể bỏ dở giữa chừng.', 'I cannot quit halfway because I promised.'),
            ],
            'notes': ['Mang sắc thái bị ràng buộc.', 'Khác với できない thuần năng lực.'],
        },
        {
            'id': 'g_n2_002', 'pattern': '〜にすぎない', 'title': 'Chỉ là / không hơn',
            'explanation': 'Hạ thấp mức độ, nhấn mạnh điều gì đó không quá lớn lao.',
            'examples': [
                ('それはうわさにすぎません。', 'それはうわさにすぎません。', 'Đó chỉ là tin đồn thôi.', 'That is nothing more than a rumor.'),
                ('彼の説明は一つの例にすぎない。', 'かれのせつめいはひとつのれいにすぎない。', 'Lời giải thích của anh ấy chỉ là một ví dụ.', 'His explanation is only one example.'),
            ],
            'notes': ['Thường dùng trong văn viết và tranh luận.', 'Có sắc thái khách quan, tỉnh táo.'],
        },
        {
            'id': 'g_n2_003', 'pattern': '〜おそれがある', 'title': 'Có nguy cơ',
            'explanation': 'Diễn tả khả năng xấu có thể xảy ra, thường thấy trong bản tin và văn bản chính thức.',
            'examples': [
                ('台風の影響で、電車が遅れるおそれがあります。', 'たいふうのえいきょうで、でんしゃがおくれるおそれがあります。', 'Do ảnh hưởng của bão, tàu điện có nguy cơ trễ.', 'Because of the typhoon, trains may be delayed.'),
                ('このままではデータが消えるおそれがある。', 'このままではデータがきえるおそれがある。', 'Nếu cứ thế này thì có nguy cơ mất dữ liệu.', 'If this continues, there is a risk that the data will be lost.'),
            ],
            'notes': ['Hay kết hợp với tin tức, cảnh báo.', 'Sắc thái trang trọng hơn かもしれない.'],
        },
        {
            'id': 'g_n2_004', 'pattern': '〜ことなく', 'title': 'Không hề / mà không',
            'explanation': 'Diễn tả một hành động diễn ra mà không cần hoặc không hề làm hành động khác.',
            'examples': [
                ('彼は一度も休むことなく働き続けた。', 'かれはいちどもやすむことなくはたらきつづけた。', 'Anh ấy tiếp tục làm việc mà không nghỉ một lần nào.', 'He kept working without taking a single break.'),
                ('辞書を見ることなく答えられました。', 'じしょをみることなくこたえられました。', 'Tôi đã trả lời được mà không cần xem từ điển.', 'I was able to answer without looking at a dictionary.'),
            ],
            'notes': ['Trang trọng hơn ないで.', 'Xuất hiện nhiều trong văn viết.'],
        },
        {
            'id': 'g_n2_005', 'pattern': '〜どころか', 'title': 'Đừng nói là ... mà ngay cả ...',
            'explanation': 'Phủ định mạnh kỳ vọng ban đầu rồi nêu kết quả trái ngược hơn.',
            'examples': [
                ('忙しくて、旅行どころか週末も休めない。', 'いそがしくて、りょこうどころかしゅうまつもやすめない。', 'Bận đến mức đừng nói là đi du lịch, cuối tuần còn không nghỉ được.', 'I am so busy that far from traveling, I cannot even rest on weekends.'),
                ('彼は漢字どころか、ひらがなもまだ読めない。', 'かれはかんじどころか、ひらがなもまだよめない。', 'Đừng nói kanji, anh ấy còn chưa đọc được cả hiragana.', 'Far from reading kanji, he still cannot even read hiragana.'),
            ],
            'notes': ['Tạo sắc thái nhấn mạnh rất mạnh.', 'Hay dùng trong nói và viết bán trang trọng.'],
        },
        {
            'id': 'g_n2_006', 'pattern': '〜に伴って', 'title': 'Cùng với / kéo theo',
            'explanation': 'Một sự thay đổi diễn ra song hành với một thay đổi khác.',
            'examples': [
                ('物価の上昇に伴って、家計も苦しくなっている。', 'ぶっかのじょうしょうにともなって、かけいもくるしくなっている。', 'Cùng với việc giá cả tăng, chi tiêu gia đình cũng khó khăn hơn.', 'As prices rise, household finances are also becoming tighter.'),
                ('駅前の開発に伴い、人口が増えた。', 'えきまえのかいはつにともない、じんこうがふえた。', 'Kéo theo việc phát triển khu trước ga, dân số đã tăng.', 'Along with the redevelopment around the station, the population increased.'),
            ],
            'notes': ['Rất hay gặp trong báo chí, báo cáo.', 'Biến thể: に伴い.'],
        },
        {
            'id': 'g_n2_007', 'pattern': '〜をめぐって', 'title': 'Xung quanh / về vấn đề',
            'explanation': 'Dùng khi có tranh luận, đối lập ý kiến hoặc sự kiện xoay quanh một chủ đề.',
            'examples': [
                ('新しい制度をめぐって、さまざまな意見が出ている。', 'あたらしいせいどをめぐって、さまざまないけんがでている。', 'Xung quanh chế độ mới đang có nhiều ý kiến khác nhau.', 'Various opinions are emerging over the new system.'),
                ('土地の利用をめぐる争いが続いている。', 'とちのりようをめぐるあらそいがつづいている。', 'Tranh chấp xoay quanh việc sử dụng đất vẫn tiếp diễn.', 'The dispute over land use continues.'),
            ],
            'notes': ['Rất điển hình trong bài báo thời sự.', 'Dạng bổ nghĩa: 〜をめぐる + danh từ.'],
        },
        {
            'id': 'g_n2_008', 'pattern': '〜ものの', 'title': 'Mặc dù ... nhưng',
            'explanation': 'Công nhận một thực tế ở vế đầu nhưng kết quả vế sau không như mong đợi.',
            'examples': [
                ('日本へ留学したものの、最初は友達ができなかった。', 'にほんへりゅうがくしたものの、さいしょはともだちができなかった。', 'Mặc dù đi du học Nhật nhưng ban đầu tôi không kết được bạn.', 'Although I studied abroad in Japan, at first I could not make friends.'),
                ('薬を飲んだものの、熱は下がらなかった。', 'くすりをのんだものの、ねつはさがらなかった。', 'Dù uống thuốc nhưng sốt vẫn không hạ.', 'Although I took medicine, my fever did not go down.'),
            ],
            'notes': ['Sắc thái trang trọng hơn けれども.', 'Hay gặp trong văn kể chuyện và báo cáo.'],
        },
        {
            'id': 'g_n2_009', 'pattern': '〜に違いない', 'title': 'Hẳn là / chắc chắn',
            'explanation': 'N2 vẫn gặp rất nhiều trong văn viết, dùng khi suy luận mạnh dựa trên căn cứ.',
            'examples': [
                ('あの表情からすると、彼は真実を知っているに違いない。', 'あのひょうじょうからすると、かれはしんじつをしっているにちがいない。', 'Nhìn vẻ mặt đó thì anh ấy hẳn là biết sự thật.', 'Judging from that expression, he must know the truth.'),
                ('ここまで準備したのだから、成功するに違いありません。', 'ここまでじゅんびしたのだから、せいこうするにちがいありません。', 'Đã chuẩn bị đến mức này thì chắc chắn sẽ thành công.', 'We have prepared this much, so it must succeed.'),
            ],
            'notes': ['Thường dùng khi muốn nhấn mạnh niềm tin mạnh.', 'Trang trọng và quyết đoán.'],
        },
        {
            'id': 'g_n2_010', 'pattern': '〜にしては', 'title': 'So với ... thì',
            'explanation': 'So sánh kết quả thực tế với chuẩn mực thông thường rồi thấy khác dự đoán.',
            'examples': [
                ('このレストランは駅前にしては静かですね。', 'このレストランはえきまえにしてはしずかですね。', 'Nhà hàng này so với vị trí trước ga thì khá yên tĩnh nhỉ.', 'This restaurant is quiet for one near the station.'),
                ('彼は一年目にしては仕事が速い。', 'かれはいちねんめにしてはしごとがはやい。', 'So với nhân viên năm đầu thì anh ấy làm việc nhanh.', 'He works quickly for a first-year employee.'),
            ],
            'notes': ['Mang sắc thái đánh giá ngoài dự kiến.', 'Hay dùng trong giao tiếp và nhận xét.'],
        },
    ],
    'N1': [
        {
            'id': 'g_n1_001', 'pattern': '〜にほかならない', 'title': 'Không gì khác ngoài',
            'explanation': 'Dùng để khẳng định bản chất thực sự của một vấn đề theo lối diễn đạt trang trọng.',
            'examples': [
                ('今回の成功は、チーム全員の努力の結果にほかなりません。', 'こんかいのせいこうは、チームぜんいんのどりょくのけっかにほかなりません。', 'Thành công lần này không gì khác ngoài kết quả nỗ lực của cả đội.', 'This success is nothing other than the result of the whole team\'s efforts.'),
                ('言葉は文化を映す鏡にほかならない。', 'ことばはぶんかをうつすかがみにほかならない。', 'Ngôn ngữ không gì khác ngoài tấm gương phản chiếu văn hóa.', 'Language is nothing other than a mirror reflecting culture.'),
            ],
            'notes': ['Rất đặc trưng cho văn nghị luận.', 'Sắc thái khẳng định mạnh, trang trọng.'],
        },
        {
            'id': 'g_n1_002', 'pattern': '〜を皮切りに', 'title': 'Mở đầu bằng',
            'explanation': 'Chỉ điểm khởi đầu của chuỗi sự kiện hoặc hoạt động nối tiếp sau đó.',
            'examples': [
                ('東京公演を皮切りに、全国ツアーが始まる。', 'とうきょうこうえんをかわきりに、ぜんこくツアーがはじまる。', 'Mở đầu bằng buổi diễn Tokyo, tour toàn quốc sẽ bắt đầu.', 'Starting with the Tokyo performance, the nationwide tour will begin.'),
                ('四月の研修を皮切りとして、新制度が導入された。', 'しがつのけんしゅうをかわきりとして、しんせいどがどうにゅうされた。', 'Mở đầu từ đợt tập huấn tháng tư, chế độ mới đã được áp dụng.', 'Beginning with the April training, the new system was introduced.'),
            ],
            'notes': ['Thường gặp trong tin tức, thông báo.', 'Biến thể: を皮切りとして.'],
        },
        {
            'id': 'g_n1_003', 'pattern': '〜まみれ', 'title': 'Đầy / bê bết',
            'explanation': 'Chỉ tình trạng bị phủ đầy một thứ gì đó, thường mang sắc thái tiêu cực.',
            'examples': [
                ('子どもたちは泥まみれになって遊んでいた。', 'こどもたちはどろまみれになってあそんでいた。', 'Bọn trẻ chơi đùa đến mức lấm lem đầy bùn.', 'The children were playing, covered in mud.'),
                ('失敗が続き、頭の中は不安まみれだった。', 'しっぱいがつづき、あたまのなかはふあんまみれだった。', 'Thất bại nối tiếp khiến đầu óc tôi đầy bất an.', 'After repeated failures, my mind was filled with anxiety.'),
            ],
            'notes': ['Dùng được với nghĩa bóng.', 'Khác với だらけ ở cảm giác nặng, đặc quánh hơn.'],
        },
        {
            'id': 'g_n1_004', 'pattern': '〜ずにはすまない', 'title': 'Không thể không',
            'explanation': 'Một tình huống tất yếu dẫn đến hành động hoặc cảm xúc không thể tránh.',
            'examples': [
                ('その映画を見たら、だれでも涙を流さずにはすまない。', 'そのえいがをみたら、だれでもなみだをながさずにはすまない。', 'Xem bộ phim đó thì ai cũng không thể không rơi nước mắt.', 'Anyone who watches that movie cannot help but cry.'),
                ('彼の態度には文句を言わずにはすまなかった。', 'かれのたいどにはもんくをいわずにはすまなかった。', 'Thái độ của anh ấy khiến tôi không thể không phàn nàn.', 'His attitude made me unable to keep from complaining.'),
            ],
            'notes': ['Sắc thái mạnh và văn viết.', 'Hay đi với cảm xúc hoặc phản ứng tất yếu.'],
        },
        {
            'id': 'g_n1_005', 'pattern': '〜にかたくない', 'title': 'Không khó để ...',
            'explanation': 'Diễn tả việc tưởng tượng, suy đoán là điều rất dễ dàng.',
            'examples': [
                ('被害者の苦しみは想像にかたくない。', 'ひがいしゃのくるしみはそうぞうにかたくない。', 'Không khó để tưởng tượng nỗi khổ của nạn nhân.', 'It is not hard to imagine the suffering of the victims.'),
                ('あの結果に彼が落胆したことは察するにかたくない。', 'あのけっかにかれがらくたんしたことはさっするにかたくない。', 'Không khó để đoán anh ấy đã thất vọng với kết quả đó.', 'It is easy to infer that he was disappointed by that result.'),
            ],
            'notes': ['Hay kết hợp với 想像する, 察する.', 'Mang sắc thái nghị luận.'],
        },
        {
            'id': 'g_n1_006', 'pattern': '〜ならでは', 'title': 'Chỉ ... mới có',
            'explanation': 'Nhấn mạnh đặc trưng riêng chỉ đối tượng đó mới thể hiện được.',
            'examples': [
                ('京都ならではの落ち着いた町並みが好きです。', 'きょうとならではのおちついたまちなみがすきです。', 'Tôi thích phố xá trầm lắng rất riêng chỉ Kyoto mới có.', 'I like the calm streetscape unique to Kyoto.'),
                ('職人ならではの丁寧な仕事ぶりに感動した。', 'しょくにんならではのていねいなしごとぶりにかんどうした。', 'Tôi ấn tượng trước lối làm việc tỉ mỉ chỉ có ở nghệ nhân.', 'I was impressed by the careful workmanship unique to a craftsman.'),
            ],
            'notes': ['Thường dùng với danh từ.', 'Rất hợp khi mô tả văn hóa, sản phẩm, địa phương.'],
        },
        {
            'id': 'g_n1_007', 'pattern': '〜をものともせず', 'title': 'Bất chấp / không nao núng trước',
            'explanation': 'Dùng để ca ngợi tinh thần vượt qua khó khăn, trở ngại.',
            'examples': [
                ('選手たちは強風をものともせず走り続けた。', 'せんしゅたちはきょうふうをものともせずはしりつづけた。', 'Các vận động viên tiếp tục chạy bất chấp gió mạnh.', 'The athletes kept running in spite of the strong wind.'),
                ('彼女は批判をものともせず、自分の信念を貫いた。', 'かのじょはひはんをものともせず、じぶんのしんねんをつらぬいた。', 'Cô ấy giữ vững niềm tin của mình bất chấp chỉ trích.', 'She stuck to her beliefs despite criticism.'),
            ],
            'notes': ['Mang sắc thái tích cực, khâm phục.', 'Thường dùng với trở ngại mạnh như 困難, 批判.'],
        },
        {
            'id': 'g_n1_008', 'pattern': '〜とあって', 'title': 'Chính vì ... nên',
            'explanation': 'Giải thích nguyên nhân được mọi người chấp nhận như hiển nhiên.',
            'examples': [
                ('連休初日とあって、駅は朝から混雑していた。', 'れんきゅうしょにちとあって、えきはあさからこんざつしていた。', 'Chính vì là ngày đầu kỳ nghỉ dài nên ga đông nghịt từ sáng.', 'Since it was the first day of the holiday, the station was crowded from morning.'),
                ('人気作家の新作とあって、多くの人が店に並んだ。', 'にんきさっかのしんさくとあって、おおくのひとがみせにならんだ。', 'Vì là tác phẩm mới của tác giả nổi tiếng nên nhiều người đã xếp hàng.', 'Because it was a new work by a popular author, many people lined up.'),
            ],
            'notes': ['Thường đi với sự kiện, lý do ai cũng hiểu.', 'Hay gặp trong văn báo chí.'],
        },
        {
            'id': 'g_n1_009', 'pattern': '〜といえども', 'title': 'Dù là ... đi nữa',
            'explanation': 'Thừa nhận một thân phận hay địa vị nhưng nhấn mạnh ngoại lệ hoặc giới hạn.',
            'examples': [
                ('プロといえども、毎日の基礎練習は欠かせない。', 'プロといえども、まいにちのきそれんしゅうはかかせない。', 'Dù là chuyên nghiệp đi nữa cũng không thể thiếu luyện cơ bản mỗi ngày.', 'Even professionals cannot do without daily basic practice.'),
                ('子どもといえども、約束は守るべきだ。', 'こどもといえども、やくそくはまもるべきだ。', 'Dù là trẻ con thì cũng nên giữ lời hứa.', 'Even children should keep their promises.'),
            ],
            'notes': ['Trang trọng hơn でも.', 'Phổ biến trong văn nghị luận.'],
        },
        {
            'id': 'g_n1_010', 'pattern': '〜極まりない / 〜極まる', 'title': 'Vô cùng / cực kỳ',
            'explanation': 'Nhấn mạnh mức độ cực hạn, thường dùng với cảm xúc hoặc tính chất.',
            'examples': [
                ('その判決は不公平極まりない。', 'そのはんけつはふこうへいきわまりない。', 'Phán quyết đó vô cùng bất công.', 'That ruling is extremely unfair.'),
                ('失礼極まる態度に会場が静まり返った。', 'しつれいきわまるたいどにかいじょうがしずまりかえった。', 'Cả hội trường lặng đi trước thái độ cực kỳ vô lễ đó.', 'The venue fell silent at that extremely rude attitude.'),
            ],
            'notes': ['Hay dùng trong văn viết, phê bình, bình luận.', 'Thường đứng sau danh từ/tính chất tiêu cực.'],
        },
    ],
}


def esc(text: str) -> str:
    return text.replace('\\', '\\\\').replace("'", "\\'")


def example_block(examples):
    lines = []
    for jp, hira, vi, en in examples:
        lines.append(
            "        ExampleSentence(japanese: '%s', hiragana: '%s', vietnamese: '%s', english: '%s')," % (
                esc(jp), esc(hira), esc(vi), esc(en)
            )
        )
    return '\n'.join(lines)


def notes_block(notes):
    return ', '.join("'%s'" % esc(n) for n in notes)

out = ["import '../models/grammar.dart';", '', 'class GrammarData {',
       "  static const List<String> levels = ['N5', 'N4', 'N3', 'N2', 'N1'];",
       '',
       '  static List<GrammarLesson> getAllLessons() => [',
       '    ..._n5Grammar,',
       '    ..._n4Grammar,',
       '    ..._n3Grammar,',
       '    ..._n2Grammar,',
       '    ..._n1Grammar,',
       '  ];',
       '',
       '  static List<GrammarLesson> getLessonsByLevel(String level) {',
       '    switch (level) {',
       "      case 'N5':", '        return _n5Grammar;',
       "      case 'N4':", '        return _n4Grammar;',
       "      case 'N3':", '        return _n3Grammar;',
       "      case 'N2':", '        return _n2Grammar;',
       "      case 'N1':", '        return _n1Grammar;',
       '      default:', '        return _n5Grammar;', '    }', '  }', '']

for level in ['N5', 'N4', 'N3', 'N2', 'N1']:
    out.append(f'  static final List<GrammarLesson> _{level.lower()}Grammar = [')
    for item in levels[level]:
        out.extend([
            '    GrammarLesson(',
            f"      id: '{esc(item['id'])}',",
            f"      pattern: '{esc(item['pattern'])}',",
            f"      title: '{esc(item['title'])}',",
            f"      explanation: '{esc(item['explanation'])}',",
            f"      jlptLevel: '{level}',",
            '      examples: [',
            example_block(item['examples']),
            '      ],',
            f"      notes: [{notes_block(item['notes'])}],",
            '    ),',
        ])
    out.append('  ];')
    out.append('')

out.append('}')

Path('/home/user/proj2_work/lib/data/grammar_data.dart').write_text('\n'.join(out), encoding='utf-8')
print('Generated grammar_data.dart with', sum(len(v) for v in levels.values()), 'lessons')
