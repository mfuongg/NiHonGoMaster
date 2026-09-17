import '../models/quiz.dart';
import '../models/vocabulary.dart';
import 'vocabulary_data.dart';

class JLPTTestData {
  static List<JLPTTest> getAllTests() => _tests;

  static List<JLPTTest> getTestsByLevel(String level) {
    return _tests.where((test) => test.level == level).toList();
  }

  static final List<JLPTTest> _tests = _buildTests();

  static List<JLPTTest> _buildTests() {
    const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
    final tests = <JLPTTest>[];

    for (final level in levels) {
      tests.addAll(_buildLevelTests(level));
    }

    return tests;
  }

  static List<JLPTTest> _buildLevelTests(String level) {
    final words = VocabularyData.getWordsByLevel(level);
    final grammarTemplates = _grammarBank[level] ?? const <_GrammarQuestionTemplate>[];
    if (words.isEmpty || grammarTemplates.length < 2) return const [];

    final tests = <JLPTTest>[];
    final testCount = 5;

    for (var testIndex = 0; testIndex < testCount; testIndex++) {
      final selectedWords = _pickWords(words, testIndex, 8);
      final grammarA = grammarTemplates[(testIndex * 2) % grammarTemplates.length];
      final grammarB = grammarTemplates[(testIndex * 2 + 1) % grammarTemplates.length];

      final questions = <QuizQuestion>[
        _buildReadingQuestion(
          id: '${level.toLowerCase()}_${testIndex + 1}_01',
          word: selectedWords[0],
          pool: words,
          level: level,
        ),
        _buildMeaningQuestion(
          id: '${level.toLowerCase()}_${testIndex + 1}_02',
          word: selectedWords[1],
          pool: words,
          level: level,
        ),
        _buildContextWordQuestion(
          id: '${level.toLowerCase()}_${testIndex + 1}_03',
          word: selectedWords[2],
          pool: words,
          level: level,
        ),
        _buildGrammarQuestion(
          id: '${level.toLowerCase()}_${testIndex + 1}_04',
          template: grammarA,
          level: level,
        ),
        _buildUsageMeaningQuestion(
          id: '${level.toLowerCase()}_${testIndex + 1}_05',
          word: selectedWords[3],
          pool: words,
          level: level,
        ),
        _buildReverseMeaningQuestion(
          id: '${level.toLowerCase()}_${testIndex + 1}_06',
          word: selectedWords[4],
          pool: words,
          level: level,
        ),
        _buildGrammarQuestion(
          id: '${level.toLowerCase()}_${testIndex + 1}_07',
          template: grammarB,
          level: level,
        ),
        _buildKanjiQuestion(
          id: '${level.toLowerCase()}_${testIndex + 1}_08',
          word: selectedWords[5],
          pool: words,
          level: level,
        ),
        _buildContextWordQuestion(
          id: '${level.toLowerCase()}_${testIndex + 1}_09',
          word: selectedWords[6],
          pool: words,
          level: level,
        ),
        _buildMeaningQuestion(
          id: '${level.toLowerCase()}_${testIndex + 1}_10',
          word: selectedWords[7],
          pool: words,
          level: level,
        ),
      ];

      tests.add(
        JLPTTest(
          id: '${level.toLowerCase()}_test_${(testIndex + 1).toString().padLeft(2, '0')}',
          level: level,
          title: 'Đề JLPT mô phỏng $level - ${(testIndex + 1).toString().padLeft(2, '0')}',
          questions: questions,
          timeMinutes: _timeMinutesByLevel[level] ?? 20,
        ),
      );
    }

    return tests;
  }

  static List<VocabularyWord> _pickWords(
    List<VocabularyWord> words,
    int testIndex,
    int count,
  ) {
    final result = <VocabularyWord>[];
    final usedIds = <String>{};
    var cursor = (testIndex * 29) % words.length;

    while (result.length < count && usedIds.length < words.length) {
      final word = words[cursor % words.length];
      if (usedIds.add(word.id)) {
        result.add(word);
      }
      cursor += 17;
    }

    while (result.length < count) {
      result.add(words[result.length % words.length]);
    }

    return result;
  }

  static QuizQuestion _buildMeaningQuestion({
    required String id,
    required VocabularyWord word,
    required List<VocabularyWord> pool,
    required String level,
  }) {
    final distractors = _distractorWords(pool, word, 3)
        .map(_meaningOf)
        .toList();
    final arranged = _arrangeOptions(_meaningOf(word), distractors, id.hashCode);

    return QuizQuestion(
      id: id,
      question: 'Chọn nghĩa đúng nhất của từ "${word.japanese}".',
      questionJp: '「${word.japanese}（${word.hiragana}）」の意味として最も近いものを選びなさい。',
      options: arranged.options,
      correctIndex: arranged.correctIndex,
      explanation: '${word.japanese} (${word.hiragana}) nghĩa là "${_meaningOf(word)}".',
      jlptLevel: level,
      type: QuestionType.vocabularyMeaning,
    );
  }

  static QuizQuestion _buildReadingQuestion({
    required String id,
    required VocabularyWord word,
    required List<VocabularyWord> pool,
    required String level,
  }) {
    final distractors = _distractorWords(pool, word, 3)
        .map((item) => item.hiragana)
        .toList();
    final arranged = _arrangeOptions(word.hiragana, distractors, id.hashCode);
    final hasKanji = _containsKanji(word.japanese);

    return QuizQuestion(
      id: id,
      question: hasKanji
          ? 'Từ "${word.japanese}" được đọc như thế nào?'
          : 'Cách đọc hiragana đúng của từ "${word.japanese}" là gì?',
      questionJp: '「${word.japanese}」の読み方として正しいものを選びなさい。',
      options: arranged.options,
      correctIndex: arranged.correctIndex,
      explanation: 'Cách đọc đúng là ${word.hiragana}.',
      jlptLevel: level,
      type: hasKanji ? QuestionType.kanjiReading : QuestionType.vocabularyReading,
    );
  }

  static QuizQuestion _buildKanjiQuestion({
    required String id,
    required VocabularyWord word,
    required List<VocabularyWord> pool,
    required String level,
  }) {
    if (_containsKanji(word.japanese)) {
      final distractors = _distractorWords(pool, word, 3)
          .map(_meaningOf)
          .toList();
      final arranged = _arrangeOptions(_meaningOf(word), distractors, id.hashCode);
      return QuizQuestion(
        id: id,
        question: 'Trong các đáp án sau, đâu là nghĩa đúng của từ kanji "${word.japanese}"?',
        questionJp: '「${word.japanese}」の意味として最も近いものを選びなさい。',
        options: arranged.options,
        correctIndex: arranged.correctIndex,
        explanation: '${word.japanese} (${word.hiragana}) mang nghĩa "${_meaningOf(word)}".',
        jlptLevel: level,
        type: QuestionType.kanjiMeaning,
      );
    }

    return _buildReadingQuestion(id: id, word: word, pool: pool, level: level);
  }

  static QuizQuestion _buildReverseMeaningQuestion({
    required String id,
    required VocabularyWord word,
    required List<VocabularyWord> pool,
    required String level,
  }) {
    final distractors = _distractorWords(pool, word, 3)
        .map((item) => item.japanese)
        .toList();
    final arranged = _arrangeOptions(word.japanese, distractors, id.hashCode);

    return QuizQuestion(
      id: id,
      question: 'Từ nào phù hợp nhất với nghĩa "${_meaningOf(word)}"?',
      questionJp: '「${_meaningOf(word)}」に最も近い語を選びなさい。',
      options: arranged.options,
      correctIndex: arranged.correctIndex,
      explanation: 'Đáp án đúng là ${word.japanese} (${word.hiragana}) = ${_meaningOf(word)}.',
      jlptLevel: level,
      type: QuestionType.vocabularyMeaning,
    );
  }

  static QuizQuestion _buildUsageMeaningQuestion({
    required String id,
    required VocabularyWord word,
    required List<VocabularyWord> pool,
    required String level,
  }) {
    final distractors = _distractorWords(pool, word, 3)
        .map(_meaningOf)
        .toList();
    final arranged = _arrangeOptions(_meaningOf(word), distractors, id.hashCode);
    final sentence = _bestExampleSentence(word);

    return QuizQuestion(
      id: id,
      question: 'Trong câu dưới đây, từ "${word.japanese}" mang nghĩa gần nhất với đáp án nào?',
      questionJp: sentence,
      options: arranged.options,
      correctIndex: arranged.correctIndex,
      explanation: 'Trong ngữ cảnh này, ${word.japanese} được dùng với nghĩa "${_meaningOf(word)}".',
      jlptLevel: level,
      type: QuestionType.vocabularyMeaning,
    );
  }

  static QuizQuestion _buildContextWordQuestion({
    required String id,
    required VocabularyWord word,
    required List<VocabularyWord> pool,
    required String level,
  }) {
    final distractors = _distractorWords(pool, word, 3)
        .map((item) => item.japanese)
        .toList();
    final arranged = _arrangeOptions(word.japanese, distractors, id.hashCode);
    final maskedSentence = _maskedExampleSentence(word);

    return QuizQuestion(
      id: id,
      question: 'Chọn từ phù hợp nhất để điền vào chỗ trống.',
      questionJp: maskedSentence,
      options: arranged.options,
      correctIndex: arranged.correctIndex,
      explanation: 'Điền ${word.japanese} vì từ này có nghĩa "${_meaningOf(word)}" và phù hợp nhất với ngữ cảnh.',
      jlptLevel: level,
      type: QuestionType.vocabularyMeaning,
    );
  }

  static QuizQuestion _buildGrammarQuestion({
    required String id,
    required _GrammarQuestionTemplate template,
    required String level,
  }) {
    return QuizQuestion(
      id: id,
      question: template.question,
      questionJp: template.questionJp,
      options: template.options,
      correctIndex: template.correctIndex,
      explanation: template.explanation,
      jlptLevel: level,
      type: QuestionType.grammar,
    );
  }

  static _ArrangedOptions _arrangeOptions(
    String correct,
    List<String> distractors,
    int seed,
  ) {
    final uniqueDistractors = <String>[];
    for (final item in distractors) {
      if (item != correct && !uniqueDistractors.contains(item)) {
        uniqueDistractors.add(item);
      }
    }

    while (uniqueDistractors.length < 3) {
      uniqueDistractors.add('Phương án ${String.fromCharCode(65 + uniqueDistractors.length)}');
    }

    final options = <String>[correct, ...uniqueDistractors.take(3)];
    final shift = options.isEmpty ? 0 : seed.abs() % options.length;
    final rotated = <String>[
      ...options.skip(shift),
      ...options.take(shift),
    ];

    return _ArrangedOptions(
      rotated,
      rotated.indexOf(correct),
    );
  }

  static List<VocabularyWord> _distractorWords(
    List<VocabularyWord> pool,
    VocabularyWord correct,
    int count,
  ) {
    final result = <VocabularyWord>[];
    var cursor = (correct.id.hashCode.abs() + correct.japanese.length) % pool.length;

    while (result.length < count && result.length < pool.length - 1) {
      final candidate = pool[cursor % pool.length];
      final sameWord = candidate.id == correct.id;
      final duplicated = result.any((item) => item.id == candidate.id);
      if (!sameWord && !duplicated) {
        result.add(candidate);
      }
      cursor += 11;
    }

    return result;
  }

  static String _meaningOf(VocabularyWord word) {
    final meaning = word.vietnamese.trim();
    return meaning.isNotEmpty ? meaning : word.english.trim();
  }

  static String _bestExampleSentence(VocabularyWord word) {
    if (word.exampleSentences.isNotEmpty && word.exampleSentences.first.trim().isNotEmpty) {
      return word.exampleSentences.first.trim();
    }
    return 'この言葉「${word.japanese}」の使い方として最も自然なものを考えなさい。';
  }

  static String _maskedExampleSentence(VocabularyWord word) {
    final sentence = _bestExampleSentence(word);
    final targets = [word.japanese, word.hiragana]
        .where((item) => item.trim().isNotEmpty)
        .toList();

    for (final target in targets) {
      if (sentence.contains(target)) {
        return sentence.replaceFirst(target, '＿＿');
      }
    }

    return '文脈に最も合う語として「＿＿」に入るものを選びなさい。';
  }

  static bool _containsKanji(String text) {
    for (final rune in text.runes) {
      if (rune >= 0x4E00 && rune <= 0x9FFF) {
        return true;
      }
    }
    return false;
  }

  static const Map<String, int> _timeMinutesByLevel = {
    'N5': 18,
    'N4': 20,
    'N3': 22,
    'N2': 25,
    'N1': 28,
  };

  static const Map<String, List<_GrammarQuestionTemplate>> _grammarBank = {
    'N5': [
      _GrammarQuestionTemplate(
        question: 'Điền trợ từ đúng: わたし___がくせいです。',
        questionJp: 'わたし___がくせいです。',
        options: ['を', 'に', 'は', 'で'],
        correctIndex: 2,
        explanation: 'は dùng để đánh dấu chủ đề của câu: Tôi là học sinh.',
      ),
      _GrammarQuestionTemplate(
        question: 'Chọn mẫu đúng để diễn tả “muốn uống nước”.',
        questionJp: '「みずをのみたい」と同じ意味のものを選びなさい。',
        options: ['みずをのみます', 'みずをのみたいです', 'みずをのみました', 'みずをのみません'],
        correctIndex: 1,
        explanation: 'Động từ thể ます bỏ ます rồi thêm たい để diễn tả mong muốn.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền trợ từ đúng: まいあさ ７じ___おきます。',
        questionJp: 'まいあさ ７じ___おきます。',
        options: ['を', 'に', 'で', 'へ'],
        correctIndex: 1,
        explanation: 'に dùng với mốc thời gian cụ thể.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu nào dùng để rủ rê “Cùng đi nhé”?',
        questionJp: 'いっしょに行くことをさそう文を選びなさい。',
        options: ['行きます', '行きません', '行きましょう', '行きたいです'],
        correctIndex: 2,
        explanation: '〜ましょう dùng để rủ rê hoặc đề nghị cùng làm.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền trợ từ đúng: バス___学校へ行きます。',
        questionJp: 'バス___学校へ行きます。',
        options: ['に', 'を', 'で', 'が'],
        correctIndex: 2,
        explanation: 'で dùng để chỉ phương tiện hoặc cách thức thực hiện hành động.',
      ),
      _GrammarQuestionTemplate(
        question: 'Câu nào diễn tả hành động đang diễn ra?',
        questionJp: '今していることを表す文を選びなさい。',
        options: ['本を読みます', '本を読んでいます', '本を読みました', '本を読みたいです'],
        correctIndex: 1,
        explanation: '〜ている diễn tả hành động đang diễn ra hoặc trạng thái hiện tại.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền từ đúng: あめ___、さんぽしません。',
        questionJp: 'あめ___、さんぽしません。',
        options: ['から', 'まで', 'より', 'ほど'],
        correctIndex: 0,
        explanation: 'から diễn tả lý do: vì trời mưa nên không đi dạo.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu nào mang nghĩa “đừng làm” một cách nhẹ nhàng?',
        questionJp: 'やさしい禁止の言い方を選びなさい。',
        options: ['しないでください', 'してください', 'してもいいです', 'したいです'],
        correctIndex: 0,
        explanation: '〜ないでください dùng để yêu cầu ai đó đừng làm gì.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền trợ từ đúng: きのう ともだち___会いました。',
        questionJp: 'きのう ともだち___会いました。',
        options: ['が', 'に', 'を', 'で'],
        correctIndex: 1,
        explanation: '会う đi với に khi chỉ đối tượng gặp.',
      ),
      _GrammarQuestionTemplate(
        question: 'Câu nào đúng ngữ pháp để nói “ở Nhật có nhiều núi”?',
        questionJp: '「日本には山が多い」の文として正しいものを選びなさい。',
        options: ['日本で山が多いです', '日本には山が多いです', '日本を山が多いです', '日本が山に多いです'],
        correctIndex: 1,
        explanation: 'には dùng để chỉ nơi tồn tại, が đánh dấu chủ ngữ “núi”.',
      ),
    ],
    'N4': [
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: しゅくだいを___から、テレビを見ます。',
        questionJp: 'しゅくだいを___から、テレビを見ます。',
        options: ['して', 'した', 'してから', 'する'],
        correctIndex: 2,
        explanation: '〜てから diễn tả “sau khi làm xong A thì làm B”.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu nào diễn tả hai hành động đồng thời?',
        questionJp: '二つの動作を同時に表す形を選びなさい。',
        options: ['〜ながら', '〜ために', '〜のに', '〜ので'],
        correctIndex: 0,
        explanation: '〜ながら mang nghĩa “vừa ... vừa ...”.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền từ phù hợp: あしたは雨がふり___です。',
        questionJp: 'あしたは雨がふり___です。',
        options: ['そう', 'よう', 'らしい', 'みたい'],
        correctIndex: 0,
        explanation: '〜そうです (dạng nhìn có vẻ) dùng với gốc từ: 雨が降りそうです.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu “〜予定です” gần nghĩa nhất với gì?',
        questionJp: '「〜予定です」の意味に近いものを選びなさい。',
        options: ['thói quen', 'dự định/kế hoạch', 'cấm đoán', 'khả năng'],
        correctIndex: 1,
        explanation: '〜予定です dùng để nói lịch trình hoặc dự định đã lên kế hoạch.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: 日本語が話せる___、毎日練習しています。',
        questionJp: '日本語が話せる___、毎日練習しています。',
        options: ['ように', 'ために', 'そうに', 'みたいに'],
        correctIndex: 0,
        explanation: '〜ように dùng với mục tiêu/kết quả mong muốn khi năng lực còn chưa đạt.',
      ),
      _GrammarQuestionTemplate(
        question: 'Chọn câu thể hiện sự cho phép.',
        questionJp: '許可を表す文を選びなさい。',
        options: ['ここで写真を撮ってはいけません', 'ここで写真を撮ってもいいです', 'ここで写真を撮らないでください', 'ここで写真を撮るはずです'],
        correctIndex: 1,
        explanation: '〜てもいいです diễn tả được phép làm gì.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: 雨が___、行きます。',
        questionJp: '雨が___、行きます。',
        options: ['ふったら', 'ふれば', 'ふっても', 'ふるので'],
        correctIndex: 2,
        explanation: '〜ても diễn tả “dù ... vẫn ...”.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu nào phù hợp để nói “đã lỡ làm mất vé rồi”?',
        questionJp: '失敗や完了の気持ちを表す形を選びなさい。',
        options: ['なくしておきました', 'なくしてしまいました', 'なくしてみました', 'なくしたいです'],
        correctIndex: 1,
        explanation: '〜てしまう diễn tả hoàn tất hoặc nuối tiếc/lỡ làm.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: しけんのまえに、もう一度見て___。',
        questionJp: 'しけんのまえに、もう一度見て___。',
        options: ['あります', 'おきます', 'みます', 'います'],
        correctIndex: 1,
        explanation: '〜ておく = làm trước để chuẩn bị cho việc sau.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu “〜はずです” diễn tả điều gì?',
        questionJp: '「〜はずです」が表す意味として正しいものを選びなさい。',
        options: ['mong muốn chủ quan', 'điều được kỳ vọng/đáng lẽ đúng', 'mệnh lệnh mạnh', 'cấm đoán'],
        correctIndex: 1,
        explanation: '〜はずです dùng cho điều suy đoán chắc chắn hoặc đáng lẽ phải thế.',
      ),
    ],
    'N3': [
      _GrammarQuestionTemplate(
        question: 'Mẫu “〜ことになっている” thường dùng để nói gì?',
        questionJp: '「〜ことになっている」は何を表しますか。',
        options: ['quy định/điều đã được sắp xếp', 'ý chí mạnh', 'mệnh lệnh trực tiếp', 'thói quen cá nhân'],
        correctIndex: 0,
        explanation: '〜ことになっている diễn tả quy định hoặc quyết định mang tính hệ thống.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: 彼がうそをついた___ない。',
        questionJp: '彼がうそをついた___ない。',
        options: ['わけが', 'わけでは', 'ものでは', 'ことでは'],
        correctIndex: 1,
        explanation: '〜わけではない = không hẳn là / không phải hoàn toàn như vậy.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu nào diễn tả “sắp/định làm”?',
        questionJp: 'これからしようとする気持ちを表す形を選びなさい。',
        options: ['〜ようとする', '〜てしまう', '〜ことになる', '〜かねない'],
        correctIndex: 0,
        explanation: '〜ようとする diễn tả định làm hoặc sắp bắt đầu làm.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: 物価は上がる___だ。',
        questionJp: '物価は上がる___だ。',
        options: ['ばかり', 'ほど', 'ところ', 'わけ'],
        correctIndex: 0,
        explanation: '〜ばかりだ = chỉ có xu hướng tăng lên/tiến triển theo một chiều.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu “〜に違いない” phù hợp nhất với ý nào?',
        questionJp: '「〜に違いない」の意味として最も近いものを選びなさい。',
        options: ['chắc chắn là', 'không thể nào', 'có lẽ không', 'không cần phải'],
        correctIndex: 0,
        explanation: '〜に違いない diễn tả sự khẳng định rất mạnh của người nói.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: 努力した___、結果が出なかった。',
        questionJp: '努力した___、結果が出なかった。',
        options: ['ものの', 'ところで', 'うちに', 'ばかりに'],
        correctIndex: 0,
        explanation: '〜ものの = tuy ... nhưng ..., sắc thái văn viết và nhượng bộ.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu nào nói về nguy cơ xảy ra điều xấu?',
        questionJp: '悪い結果の可能性を表す形を選びなさい。',
        options: ['〜ようにする', '〜おそれがある', '〜ことになる', '〜にすぎない'],
        correctIndex: 1,
        explanation: '〜おそれがある = có e rằng, có nguy cơ.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: 読め___読むほど、日本語がおもしろい。',
        questionJp: '読め___読むほど、日本語がおもしろい。',
        options: ['ば', 'たら', 'ても', 'ので'],
        correctIndex: 0,
        explanation: '〜ば〜ほど = càng ... càng ...',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu “〜ことから” thường dùng để làm gì?',
        questionJp: '「〜ことから」は何に使いますか。',
        options: ['nêu căn cứ/lý do để suy ra', 'đưa ra mệnh lệnh', 'diễn tả hy vọng', 'thể hiện cấm đoán'],
        correctIndex: 0,
        explanation: '〜ことから dùng để nêu lý do/căn cứ cho nhận định.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: 彼は疲れている___見える。',
        questionJp: '彼は疲れている___見える。',
        options: ['ように', 'そうに', 'らしく', 'みたいな'],
        correctIndex: 0,
        explanation: '〜ように見える = trông như là...',
      ),
    ],
    'N2': [
      _GrammarQuestionTemplate(
        question: 'Mẫu “〜にすぎない” gần nghĩa nhất với gì?',
        questionJp: '「〜にすぎない」の意味として最も近いものを選びなさい。',
        options: ['chỉ là... mà thôi', 'quá mức', 'rất cần thiết', 'không thể tránh'],
        correctIndex: 0,
        explanation: '〜にすぎない = chỉ là, không hơn không kém.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: その問題___、さまざまな意見が出ている。',
        questionJp: 'その問題___、さまざまな意見が出ている。',
        options: ['をめぐって', 'にすぎて', 'に反して', 'かねて'],
        correctIndex: 0,
        explanation: '〜をめぐって = xoay quanh, liên quan đến chủ đề nào đó.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu nào diễn tả “càng ngày chỉ càng xấu đi”?',
        questionJp: '悪い方向へ変化し続ける意味の形を選びなさい。',
        options: ['〜一方だ', '〜どころか', '〜末に', '〜わりに'],
        correctIndex: 0,
        explanation: '〜一方だ diễn tả xu hướng chỉ tiến triển theo một hướng.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: 彼は一度も文句を言う___働き続けた。',
        questionJp: '彼は一度も文句を言う___働き続けた。',
        options: ['ことなく', 'かねなく', 'ばかりに', '末に'],
        correctIndex: 0,
        explanation: '〜ことなく = mà không làm ..., dùng trong văn viết/trang trọng.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu “〜ものだから” thường dùng khi nào?',
        questionJp: '「〜ものだから」はどんな時に使いますか。',
        options: ['nêu lý do mang tính biện minh/giải thích', 'ra mệnh lệnh', 'nói khả năng', 'nói song song hai hành động'],
        correctIndex: 0,
        explanation: '〜ものだから thường mang sắc thái giải thích hoặc thanh minh.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: この店は有名な___、値段はそれほど高くない。',
        questionJp: 'この店は有名な___、値段はそれほど高くない。',
        options: ['わりに', 'に反して', '末に', '一方'],
        correctIndex: 0,
        explanation: '〜わりに = so với ... thì ..., trái với mức mong đợi.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu “〜に反して” diễn tả điều gì?',
        questionJp: '「〜に反して」は何を表しますか。',
        options: ['trái với / ngược với', 'bổ sung thêm', 'không kể đến', 'cùng với'],
        correctIndex: 0,
        explanation: '〜に反して = trái với quy định, kỳ vọng hoặc ý định.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: 国籍___、応募できます。',
        questionJp: '国籍___、応募できます。',
        options: ['を問わず', 'にすぎず', 'に反せず', 'をめぐらず'],
        correctIndex: 0,
        explanation: '〜を問わず = bất kể, không phân biệt.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu nào mang nghĩa “có nguy cơ dẫn đến điều xấu”?',
        questionJp: '悪い結果につながる可能性を表す形を選びなさい。',
        options: ['〜わりに', '〜かねない', '〜にすぎない', '〜どころか'],
        correctIndex: 1,
        explanation: '〜かねない = có nguy cơ, rất dễ dẫn đến kết quả không mong muốn.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: 何年も考えた___、留学することにした。',
        questionJp: '何年も考えた___、留学することにした。',
        options: ['末に', 'わりに', 'かねて', 'を問わず'],
        correctIndex: 0,
        explanation: '〜末に = sau nhiều cân nhắc/diễn biến lâu dài thì cuối cùng...',
      ),
    ],
    'N1': [
      _GrammarQuestionTemplate(
        question: 'Mẫu “〜に至って” thường dùng để nhấn mạnh điều gì?',
        questionJp: '「〜に至って」は何を強調しますか。',
        options: ['mức độ đi tới tận / thậm chí đến cả', 'mệnh lệnh mạnh', 'dự định đơn giản', 'sự cho phép'],
        correctIndex: 0,
        explanation: '〜に至って nhấn mạnh mức độ đi tới tận điểm cực hạn.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: 東京公演___、全国ツアーが始まる。',
        questionJp: '東京公演___、全国ツアーが始まる。',
        options: ['を皮切りに', 'ならでは', 'まみれ', 'いかんでは'],
        correctIndex: 0,
        explanation: '〜を皮切りに = lấy ... làm mở đầu, khởi đầu cho chuỗi sự kiện.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu “〜ならでは” phù hợp nhất với ý nào?',
        questionJp: '「〜ならでは」の意味として最も近いものを選びなさい。',
        options: ['chỉ riêng ... mới có', 'không phân biệt', 'dù cho ... đi nữa', 'không thể không'],
        correctIndex: 0,
        explanation: '〜ならでは = nét đặc trưng/chỉ có ở đối tượng đó.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: 事情を聞けば、助けずに___。',
        questionJp: '事情を聞けば、助けずに___。',
        options: ['はおかない', 'はいられない', 'はすまない', 'はならない'],
        correctIndex: 2,
        explanation: '〜ずにはすまない = không thể cứ thế mà không..., buộc phải làm.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu “〜いかんでは” dùng để nói gì?',
        questionJp: '「〜いかんでは」は何を表しますか。',
        options: ['kết quả tùy thuộc vào', 'bắt đầu từ', 'chỉ riêng mới có', 'đầy kín bởi'],
        correctIndex: 0,
        explanation: '〜いかんでは = tùy vào / phụ thuộc vào.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: 子どもが泥___帰ってきた。',
        questionJp: '子どもが泥___帰ってきた。',
        options: ['だらけで', 'まみれで', 'っぽく', 'ずくめで'],
        correctIndex: 1,
        explanation: '〜まみれ = dính đầy, phủ đầy bởi thứ gì.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu “〜にたえない” thường đi với cảm xúc nào?',
        questionJp: '「〜にたえない」はどんな気持ちを表しますか。',
        options: ['không thể chịu nổi / vô cùng...', 'không đáng để', 'chỉ mới bắt đầu', 'có khả năng'],
        correctIndex: 0,
        explanation: '〜にたえない thường dùng trong văn trang trọng với cảm xúc rất mạnh.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: その勇気ある行動に、感動___。',
        questionJp: 'その勇気ある行動に、感動___。',
        options: ['を禁じ得ない', 'に至らない', 'まみれでいる', 'いかんではない'],
        correctIndex: 0,
        explanation: '〜を禁じ得ない = không sao kìm nén được cảm xúc.',
      ),
      _GrammarQuestionTemplate(
        question: 'Mẫu “〜そばから” diễn tả điều gì?',
        questionJp: '「〜そばから」は何を表しますか。',
        options: ['vừa mới ... xong lại ... ngay', 'bắt đầu từ', 'càng ... càng ...', 'rốt cuộc là'],
        correctIndex: 0,
        explanation: '〜そばから = vừa làm xong thì lập tức lại xảy ra điều tương tự.',
      ),
      _GrammarQuestionTemplate(
        question: 'Điền mẫu đúng: ベルが鳴る___、学生たちは教室を飛び出した。',
        questionJp: 'ベルが鳴る___、学生たちは教室を飛び出した。',
        options: ['が早いか', 'ならでは', 'まみれで', 'いかんで'],
        correctIndex: 0,
        explanation: '〜が早いか = vừa mới ... là ngay lập tức ...',
      ),
    ],
  };
}

class _ArrangedOptions {
  final List<String> options;
  final int correctIndex;

  const _ArrangedOptions(this.options, this.correctIndex);
}

class _GrammarQuestionTemplate {
  final String question;
  final String questionJp;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const _GrammarQuestionTemplate({
    required this.question,
    required this.questionJp,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}
