import 'dart:math' as math;
import '../models/vocabulary.dart';

class PracticeCheckResult {
  final bool isCorrect;
  final double score;
  final String recognizedText;
  final String matchedTarget;
  final String feedback;
  final List<String> suggestions;  
  final String encouragement;      

  const PracticeCheckResult({
    required this.isCorrect,
    required this.score,
    required this.recognizedText,
    required this.matchedTarget,
    required this.feedback,
    this.suggestions = const [],
    this.encouragement = '',
  });
}

class AiPracticeEvaluator {
  
  static const Map<String, int> _strokeCounts = {
    'あ': 3, 'い': 2, 'う': 2, 'え': 2, 'お': 3,
    'か': 3, 'き': 4, 'く': 2, 'け': 3, 'こ': 2,
    'さ': 3, 'し': 1, 'す': 2, 'せ': 3, 'そ': 2,
    'た': 4, 'ち': 3, 'つ': 1, 'て': 1, 'と': 2,
    'な': 4, 'に': 3, 'ぬ': 2, 'ね': 4, 'の': 1,
    'は': 3, 'ひ': 1, 'ふ': 4, 'へ': 1, 'ほ': 4,
    'ま': 3, 'み': 3, 'む': 3, 'め': 2, 'も': 3,
    'や': 3, 'ゆ': 2, 'よ': 2,
    'ら': 2, 'り': 2, 'る': 2, 'れ': 2, 'ろ': 1,
    'わ': 2, 'を': 3, 'ん': 1,
    'ア': 2, 'イ': 2, 'ウ': 3, 'エ': 2, 'オ': 3,
    'カ': 2, 'キ': 3, 'ク': 2, 'ケ': 3, 'コ': 2,
    'サ': 3, 'シ': 3, 'ス': 2, 'セ': 3, 'ソ': 2,
    'タ': 3, 'チ': 3, 'ツ': 3, 'テ': 3, 'ト': 2,
    'ナ': 2, 'ニ': 2, 'ヌ': 2, 'ネ': 4, 'ノ': 1,
    'ハ': 3, 'ヒ': 2, 'フ': 1, 'ヘ': 1, 'ホ': 4,
    'マ': 3, 'ミ': 3, 'ム': 2, 'メ': 2, 'モ': 3,
    'ヤ': 2, 'ユ': 2, 'ヨ': 3,
    'ラ': 2, 'リ': 2, 'ル': 2, 'レ': 1, 'ロ': 3,
    'ワ': 2, 'ヲ': 3, 'ン': 2,
    '一': 1, '二': 2, '三': 3, '四': 5, '五': 4,
    '六': 4, '七': 2, '八': 2, '九': 2, '十': 2,
    '日': 4, '月': 4, '火': 4, '水': 4, '木': 4,
    '金': 8, '土': 3, '年': 6, '人': 2, '大': 3,
    '小': 3, '山': 3, '川': 3, '田': 5, '学': 8,
    '先': 6, '生': 5, '何': 7, '時': 10, '分': 4,
  };

  
  static List<String> _decomposeMoras(String hiragana) {
    final morae = <String>[];
    final chars = hiragana.runes.toList();
    for (int i = 0; i < chars.length; i++) {
      final ch = String.fromCharCode(chars[i]);
      
      if (i + 1 < chars.length) {
        final next = String.fromCharCode(chars[i + 1]);
        if ('ゃゅょャュョぁぃぅぇぉァィゥェォ'.contains(next)) {
          morae.add(ch + next);
          i++;
          continue;
        }
      }
      morae.add(ch);
    }
    return morae;
  }

  
  static PracticeCheckResult evaluatePronunciation({
    required VocabularyWord word,
    required String recognizedText,
  }) {
    final base = _evaluate(
      word: word,
      recognizedText: recognizedText,
      baseThreshold: 0.56,
      emptyFeedback:
          'AI chưa nghe rõ giọng đọc. Hãy nói gần micro hơn, đọc chậm và tách âm rõ từng mora rồi thử lại.',
      successPrefix: 'Phát âm đạt yêu cầu',
      failPrefix: 'Phát âm chưa đủ khớp',
    );

    final suggestions = _buildPronunciationSuggestions(
      word: word,
      recognizedText: base.recognizedText,
      matchedTarget: base.matchedTarget,
      isCorrect: base.isCorrect,
      score: base.score,
    );

    final encouragement = _pronunciationEncouragement(base.isCorrect, base.score);

    return PracticeCheckResult(
      isCorrect: base.isCorrect,
      score: base.score,
      recognizedText: base.recognizedText,
      matchedTarget: base.matchedTarget,
      feedback: base.feedback,
      suggestions: suggestions,
      encouragement: encouragement,
    );
  }

  static PracticeCheckResult evaluateWriting({
    required VocabularyWord word,
    required String recognizedText,
  }) {
    final base = _evaluate(
      word: word,
      recognizedText: recognizedText,
      baseThreshold: 0.50,
      emptyFeedback:
          'AI chưa nhận ra nét chữ. Hãy viết to hơn, đậm hơn, giữ các nét tách bạch và thử lại.',
      successPrefix: 'Chữ viết đạt yêu cầu',
      failPrefix: 'Chữ viết chưa đủ khớp',
    );

    final suggestions = _buildWritingSuggestions(
      word: word,
      recognizedText: base.recognizedText,
      matchedTarget: base.matchedTarget,
      isCorrect: base.isCorrect,
      score: base.score,
    );

    final encouragement = _writingEncouragement(base.isCorrect, base.score);

    return PracticeCheckResult(
      isCorrect: base.isCorrect,
      score: base.score,
      recognizedText: base.recognizedText,
      matchedTarget: base.matchedTarget,
      feedback: base.feedback,
      suggestions: suggestions,
      encouragement: encouragement,
    );
  }

  
  static List<String> _buildPronunciationSuggestions({
    required VocabularyWord word,
    required String recognizedText,
    required String matchedTarget,
    required bool isCorrect,
    required double score,
  }) {
    final tips = <String>[];
    final target = word.hiragana.isNotEmpty ? word.hiragana : word.japanese;
    final morae = _decomposeMoras(target);
    final percent = (score * 100).round();

    if (isCorrect) {
      if (morae.isNotEmpty) {
        tips.add('✅ Âm vị đúng: ${morae.join(' · ')}');
      }
      if (word.romaji.isNotEmpty) {
        tips.add('🔤 Romaji tham khảo: ${word.romaji}');
      }
      tips.add('🎯 Thử đọc nhanh hơn và tự nhiên hơn để nâng cấp!');
    } else {
      
      if (morae.length >= 2) {
        final hint = morae.asMap().entries.map((e) {
          return 'âm ${e.key + 1} "${e.value}"';
        }).join(', ');
        tips.add('🔊 Từ "$target" gồm ${morae.length} âm: $hint. Hãy tách từng âm khi đọc.');
      } else if (morae.isNotEmpty) {
        tips.add('🔊 Phát âm rõ: "${morae.join()}"');
      }

      
      if (target.contains('が') || target.contains('を') || target.contains('は')) {
        tips.add('📢 Các trợ từ は(wa), を(o), が(ga) cần phát âm nhẹ, không nhấn mạnh.');
      }

      
      if (recognizedText.isNotEmpty) {
        final normInput = _normalizeJapanese(recognizedText);
        final normTarget = _normalizeJapanese(target);
        if (normInput.isNotEmpty && normTarget.isNotEmpty && normInput[0] != normTarget[0]) {
          tips.add('⚠️ Âm đầu tiên "${morae.isNotEmpty ? morae[0] : target[0]}" chưa đúng – hãy đọc mạnh hơn ở âm này.');
        }
      }

      if (percent < 40) {
        tips.add('🎙️ Micro chưa nhận rõ giọng. Hãy: (1) nói gần micro, (2) đọc chậm 50%, (3) tách âm rõ ràng.');
      } else if (percent < 60) {
        tips.add('💡 Gợi ý: luyện từng mora riêng lẻ trước, sau đó ghép lại toàn từ.');
      }

      if (word.romaji.isNotEmpty) {
        tips.add('🔤 Đọc theo romaji: "${word.romaji}" – mỗi nguyên âm đọc riêng biệt (a, i, u, e, o).');
      }

      tips.add('🔁 Bấm nút loa 🔊 để nghe mẫu và so sánh với giọng của bạn.');
    }

    return tips;
  }

  
  static List<String> _buildWritingSuggestions({
    required VocabularyWord word,
    required String recognizedText,
    required String matchedTarget,
    required bool isCorrect,
    required double score,
    }) {
    final tips = <String>[];
    final target = word.hiragana.isNotEmpty ? word.hiragana : word.japanese;
    final percent = (score * 100).round();

    if (isCorrect) {
      tips.add('✅ Chữ viết được nhận dạng thành công!');
      
      final strokeInfo = <String>[];
      for (final ch in target.split('')) {
        final s = _strokeCounts[ch];
        if (s != null) strokeInfo.add('"$ch" $s nét');
      }
      if (strokeInfo.isNotEmpty) {
        tips.add('✍️ Số nét: ${strokeInfo.join(', ')}. Luyện thêm để viết nhanh hơn!');
      }
    } else {
      
      for (int i = 0; i < target.length && i < 4; i++) {
        final ch = target[i];
        final strokes = _strokeCounts[ch];
        if (strokes != null) {
          tips.add('✍️ Ký tự "$ch": $strokes nét – viết đúng thứ tự nét từ trên-xuống, trái-phải.');
        }
      }

      if (percent < 40) {
        tips.add('📝 Nét chữ quá nhỏ hoặc mờ. Hãy: (1) viết to hơn 2x, (2) dùng đầu bút đậm, (3) giữ nét thẳng.');
        tips.add('🖊️ Mỗi ký tự nên chiếm ít nhất 1/3 khung vẽ, không chồng nét.');
      } else if (percent < 60) {
        tips.add('💡 Kiểm tra lại: thứ tự nét sai sẽ làm chữ biến dạng. Viết chậm và theo đúng thứ tự.');
      }

      
      if (target.contains('し') && (recognizedText.contains('つ') || recognizedText.contains('つ'))) {
        tips.add('⚠️ Dễ nhầm "し" với "つ": "し" là 1 nét cong, "つ" là 1 nét uốn ngắn hơn.');
      }
      if (target.contains('ぬ') && recognizedText.contains('め')) {
        tips.add('⚠️ Dễ nhầm "ぬ" với "め": "ぬ" có vòng kín nhỏ ở cuối, "め" thì không.');
      }
      if (target.contains('わ') && recognizedText.contains('れ')) {
        tips.add('⚠️ Dễ nhầm "わ" với "れ": "わ" không có đuôi xuống, "れ" có.');
      }

      tips.add('🔍 AI nhận ra: "${recognizedText.isEmpty ? "(trắng)" : recognizedText}" – mục tiêu là "$target".');
    }

    return tips;
  }

  
  static String _pronunciationEncouragement(bool isCorrect, double score) {
    if (isCorrect) {
      final msgs = [
        '素晴らしい！ (Tuyệt vời!) 🎉',
        'よくできました！ (Làm tốt lắm!) 🌟',
        '完璧です！ (Hoàn hảo!) ✨',
        'その調子！ (Cứ tiếp tục thế!) 🔥',
      ];
      return msgs[(score * 10).round() % msgs.length];
    } else {
      final msgs = [
        'もう一度！ (Thử lại nhé!) 💪',
        'がんばれ！ (Cố lên!) 🌸',
        '練習あるのみ！ (Chỉ có luyện tập thôi!) 📚',
        '諦めないで！ (Đừng bỏ cuộc!) ⭐',
      ];
      final idx = ((1 - score) * 4).floor().clamp(0, msgs.length - 1);
      return msgs[idx];
    }
  }

  static String _writingEncouragement(bool isCorrect, double score) {
    if (isCorrect) {
      final msgs = [
        '上手に書けました！ (Viết đẹp lắm!) ✍️🎉',
        'きれいな字ですね！ (Chữ đẹp quá!) 🌟',
        '完璧な字！ (Chữ hoàn hảo!) ✨',
      ];
      return msgs[(score * 10).round() % msgs.length];
    } else {
      final msgs = [
        '書き直してみて！ (Thử viết lại nhé!) 💪',
        '練習しましょう！ (Hãy luyện tập!) 🖊️',
        'もう少し！ (Chút nữa thôi!) 🌸',
      ];
      final idx = ((1 - score) * 3).floor().clamp(0, msgs.length - 1);
      return msgs[idx];
    }
  }

  
  static PracticeCheckResult _evaluate({
    required VocabularyWord word,
    required String recognizedText,
    required double baseThreshold,
    required String emptyFeedback,
    required String successPrefix,
    required String failPrefix,
  }) {
    final cleanedText = _cleanupRawText(recognizedText);
    if (cleanedText.isEmpty) {
      return PracticeCheckResult(
        isCorrect: false,
        score: 0,
        recognizedText: recognizedText.trim(),
        matchedTarget: word.hiragana.isNotEmpty ? word.hiragana : word.japanese,
        feedback: emptyFeedback,
      );
    }

    final candidates = _buildCandidates(word);
    final normalizedInputJa = _normalizeJapanese(cleanedText);
    final normalizedInputRomaji = _normalizeRomaji(cleanedText);

    double bestScore = 0;
    String matchedTarget = candidates.first;

    for (final candidate in candidates) {
      final candidateJa = _normalizeJapanese(candidate);
      final candidateRomaji = _normalizeRomaji(candidate);

      final scoreJa = _scoreUsingSignals(normalizedInputJa, candidateJa);
      final scoreRomaji = _scoreUsingSignals(normalizedInputRomaji, candidateRomaji);
      final score = _maxOf([scoreJa, scoreRomaji]);

      if (score > bestScore) {
        bestScore = score;
        matchedTarget = candidate;
      }
    }

    final effectiveThreshold = _thresholdFor(
      baseThreshold: baseThreshold,
      matchedTarget: matchedTarget,
      recognizedText: cleanedText,
    );
    final isCorrect = bestScore >= effectiveThreshold;
    final percent = (bestScore * 100).round();

    final feedback = isCorrect
        ? '$successPrefix (${percent}%). AI nhận diện gần nhất: $matchedTarget.'
        : '$failPrefix (${percent}%). AI nhận diện: "$cleanedText" → mục tiêu: "$matchedTarget". Hãy thử lại!';

    return PracticeCheckResult(
      isCorrect: isCorrect,
      score: bestScore,
      recognizedText: cleanedText,
      matchedTarget: matchedTarget,
      feedback: feedback,
    );
  }

  static List<String> _buildCandidates(VocabularyWord word) {
    final raw = <String>{
      word.japanese,
      word.hiragana,
      word.romaji,
      ..._splitJapaneseTokens(word.japanese),
      ..._splitJapaneseTokens(word.hiragana),
      ..._splitJapaneseTokens(word.romaji),
    };

    final expanded = <String>{};
    for (final value in raw) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      expanded.add(trimmed);
      expanded.add(_stripLongVowels(trimmed));
      expanded.add(_normalizeParticleReading(trimmed));
    }

    return expanded.where((e) => e.trim().isNotEmpty).toList(growable: false);
  }

  static double _thresholdFor({
    required double baseThreshold,
    required String matchedTarget,
    required String recognizedText,
  }) {
    final length = _normalizeJapanese(matchedTarget).length;
    final inputLength = _normalizeJapanese(recognizedText).length;
    var threshold = baseThreshold;

    if (length <= 1) threshold = math.max(0.38, threshold - 0.18);
    if (length == 2) threshold = math.max(0.44, threshold - 0.10);
    if (length <= 4) threshold = math.max(0.48, threshold - 0.04);
    if (inputLength >= length + 3) threshold -= 0.02;

    return threshold.clamp(0.38, 0.78).toDouble();
  }

  static List<String> _splitJapaneseTokens(String input) {
    return input
        .split(RegExp(r'[、。・\s]+'))
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  static double _scoreUsingSignals(String input, String candidate) {
    if (input.isEmpty || candidate.isEmpty) return 0;
    if (input == candidate) return 1;

    final containment = _containmentScore(input, candidate);
    final levenshtein = _levenshteinScore(input, candidate);
    final overlap = _characterOverlapScore(input, candidate);
    final ordered = _orderedCharacterScore(input, candidate);
    final ngram = _ngramScore(input, candidate);
    final prefix = _prefixBonus(input, candidate);

    final blended = ((levenshtein * 0.34) +
            (overlap * 0.18) +
            (ordered * 0.18) +
            (ngram * 0.18) +
            (prefix * 0.12))
        .clamp(0.0, 1.0)
        .toDouble();

    return _maxOf([containment, blended]);
  }

  static double _containmentScore(String input, String candidate) {
    if (input.contains(candidate) || candidate.contains(input)) {
      final shorter = math.min(input.length, candidate.length);
      final longer = math.max(input.length, candidate.length);
      final ratio = longer == 0 ? 0 : shorter / longer;
      return (0.84 + (ratio * 0.16)).clamp(0.0, 1.0).toDouble();
    }
    return 0;
  }

  static double _prefixBonus(String input, String candidate) {
    final maxLen = math.min(input.length, candidate.length);
    if (maxLen == 0) return 0;
    var samePrefix = 0;
    for (int i = 0; i < maxLen; i++) {
      if (input[i] != candidate[i]) break;
      samePrefix++;
    }
    return (samePrefix / maxLen).clamp(0.0, 1.0).toDouble();
  }

  static double _levenshteinScore(String input, String candidate) {
    final distance = _levenshtein(input, candidate);
    final maxLen = math.max(input.length, candidate.length);
    if (maxLen == 0) return 0;
    return (1 - (distance / maxLen)).clamp(0.0, 1.0).toDouble();
  }

  static double _characterOverlapScore(String input, String candidate) {
    final inputCounts = <String, int>{};
    final candidateCounts = <String, int>{};

    for (final char in input.split('')) {
      inputCounts.update(char, (value) => value + 1, ifAbsent: () => 1);
    }
    for (final char in candidate.split('')) {
      candidateCounts.update(char, (value) => value + 1, ifAbsent: () => 1);
    }

    int common = 0;
    int total = 0;
    final allKeys = <String>{...inputCounts.keys, ...candidateCounts.keys};
    for (final key in allKeys) {
      final a = inputCounts[key] ?? 0;
      final b = candidateCounts[key] ?? 0;
      common += math.min(a, b);
      total += math.max(a, b);
    }

    if (total == 0) return 0;
    return (common / total).clamp(0.0, 1.0).toDouble();
  }

  static double _orderedCharacterScore(String input, String candidate) {
    if (input.isEmpty || candidate.isEmpty) return 0;
    int matched = 0;
    int pointer = 0;

    for (final char in input.split('')) {
      while (pointer < candidate.length && candidate[pointer] != char) {
        pointer++;
      }
      if (pointer < candidate.length && candidate[pointer] == char) {
        matched++;
        pointer++;
      }
    }

    final denominator = math.max(input.length, candidate.length);
    if (denominator == 0) return 0;
    return (matched / denominator).clamp(0.0, 1.0).toDouble();
  }

  static double _ngramScore(String input, String candidate) {
    final inputGrams = _ngrams(input, 2);
    final candidateGrams = _ngrams(candidate, 2);
    if (inputGrams.isEmpty || candidateGrams.isEmpty) return 0;

    final overlap = inputGrams.intersection(candidateGrams).length;
    final union = inputGrams.union(candidateGrams).length;
    if (union == 0) return 0;
    return (overlap / union).clamp(0.0, 1.0).toDouble();
  }

  static Set<String> _ngrams(String text, int size) {
    final value = text.trim();
    if (value.length < size) {
      return value.isEmpty ? <String>{} : {value};
    }
    final grams = <String>{};
    for (int i = 0; i <= value.length - size; i++) {
      grams.add(value.substring(i, i + size));
    }
    return grams;
  }

  static double _maxOf(List<double> values) {
    var result = 0.0;
    for (final value in values) {
      if (value > result) result = value;
    }
    return result;
  }

  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final costs = List<int>.generate(b.length + 1, (i) => i);

    for (int i = 1; i <= a.length; i++) {
      int previous = costs[0];
      costs[0] = i;
      for (int j = 1; j <= b.length; j++) {
        final temp = costs[j];
        final substitution = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        costs[j] = [
          costs[j] + 1,
          costs[j - 1] + 1,
          previous + substitution,
        ].reduce((x, y) => x < y ? x : y);
        previous = temp;
      }
    }

    return costs[b.length];
  }

  static String _cleanupRawText(String input) {
    return input
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[|｜]+'), '')
        .replaceAll(RegExp('[\'"]'), '')
        .trim();
  }

  static String _normalizeJapanese(String input) {
    final lowered = input.toLowerCase().trim();
    final buffer = StringBuffer();

    for (final rune in lowered.runes) {
      if (_isIgnoredRune(rune)) continue;
      if (rune >= 0x30A1 && rune <= 0x30F6) {
        buffer.writeCharCode(rune - 0x60);
      } else if (rune == 0x30FC) {
        continue;
      } else {
        buffer.writeCharCode(rune);
      }
    }

    final normalized = buffer.toString();
    return _normalizeParticleReading(_stripLongVowels(normalized));
  }

  static String _normalizeRomaji(String input) {
    return input
        .toLowerCase()
        .replaceAll('ā', 'a')
        .replaceAll('ī', 'i')
        .replaceAll('ū', 'u')
        .replaceAll('ē', 'e')
        .replaceAll('ō', 'o')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static String _stripLongVowels(String input) {
    return input
        .replaceAll('ー', '')
        .replaceAll('ou', 'o')
        .replaceAll('oo', 'o')
        .replaceAll('uu', 'u');
  }

  static String _normalizeParticleReading(String input) {
    return input.replaceAll('は', 'わ').replaceAll('へ', 'え').replaceAll('を', 'お');
  }

  static bool _isIgnoredRune(int rune) {
    return rune == 0x20 ||
        rune == 0x3000 ||
        rune == 0x3001 ||
        rune == 0x3002 ||
        rune == 0x30FB ||
        rune == 0xFF0C ||
        rune == 0xFF0E ||
        rune == 0xFF1F ||
        rune == 0xFF01 ||
        rune == 0xFF5C;
  }
}
