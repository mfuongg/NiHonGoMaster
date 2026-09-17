class AppConstants {
  
  static const List<String> jlptLevels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  
  static const String modeFlashcard = 'flashcard';
  static const String modeQuiz = 'quiz';
  static const String modeTyping = 'typing';

  
  static const String keyStreak = 'streak';
  static const String keyXP = 'xp';
  static const String keyLevel = 'level';
  static const String keyLastStudy = 'last_study';
  static const String keyVocabLearned = 'vocab_learned';
  static const String keyKanjiLearned = 'kanji_learned';
  static const String keyTestScore = 'test_score';
  static const String keyDarkMode = 'dark_mode';
  static const String keyUserLevel = 'user_level';
  static const String keyOnboarded = 'onboarded';
  static const String keyDailyGoal = 'daily_goal';

  
  static const int xpVocabLearn = 10;
  static const int xpVocabQuiz = 5;
  static const int xpKanjiLearn = 15;
  static const int xpTestComplete = 50;
  static const int xpPerfectScore = 100;
  static const int xpDailyStreak = 20;

  
  static const List<Map<String, dynamic>> userLevels = [
    {'name': 'Người mới bắt đầu', 'minXP': 0, 'icon': '🌱'},
    {'name': 'Học viên cơ bản', 'minXP': 100, 'icon': '📚'},
    {'name': 'Người học chăm chỉ', 'minXP': 300, 'icon': '🎯'},
    {'name': 'Học viên tiến bộ', 'minXP': 600, 'icon': '⭐'},
    {'name': 'Chiến binh tiếng Nhật', 'minXP': 1000, 'icon': '🏯'},
    {'name': 'Samurai học tập', 'minXP': 2000, 'icon': '⚔️'},
    {'name': 'Ninja ngôn ngữ', 'minXP': 3500, 'icon': '🥷'},
    {'name': 'Đại sư tiếng Nhật', 'minXP': 5000, 'icon': '🎌'},
  ];

  
  static const List<Map<String, dynamic>> achievements = [
    {
      'id': 'first_vocab',
      'title': 'Bước đầu tiên',
      'desc': 'Học từ vựng đầu tiên',
      'icon': '🌟',
      'xp': 50,
    },
    {
      'id': 'vocab_50',
      'title': 'Học giỏi',
      'desc': 'Học 50 từ vựng',
      'icon': '📖',
      'xp': 100,
    },
    {
      'id': 'vocab_100',
      'title': 'Từ điển sống',
      'desc': 'Học 100 từ vựng',
      'icon': '📚',
      'xp': 200,
    },
    {
      'id': 'streak_7',
      'title': 'Kiên trì 7 ngày',
      'desc': '7 ngày học liên tiếp',
      'icon': '🔥',
      'xp': 150,
    },
    {
      'id': 'streak_30',
      'title': 'Tháng học bất bại',
      'desc': '30 ngày học liên tiếp',
      'icon': '💎',
      'xp': 500,
    },
    {
      'id': 'perfect_test',
      'title': 'Điểm tuyệt đối',
      'desc': 'Đạt 100% trong bài kiểm tra',
      'icon': '🏆',
      'xp': 200,
    },
    {
      'id': 'kanji_50',
      'title': 'Bậc thầy Kanji',
      'desc': 'Học 50 chữ Kanji',
      'icon': '🈶',
      'xp': 200,
    },
  ];

  
  static const Map<String, List<List<String>>> hiraganaTable = {
    'vowels': [['あ/a', 'い/i', 'う/u', 'え/e', 'お/o']],
    'k': [['か/ka', 'き/ki', 'く/ku', 'け/ke', 'こ/ko']],
    's': [['さ/sa', 'し/shi', 'す/su', 'せ/se', 'そ/so']],
    't': [['た/ta', 'ち/chi', 'つ/tsu', 'て/te', 'と/to']],
    'n': [['な/na', 'に/ni', 'ぬ/nu', 'ね/ne', 'の/no']],
    'h': [['は/ha', 'ひ/hi', 'ふ/fu', 'へ/he', 'ほ/ho']],
    'm': [['ま/ma', 'み/mi', 'む/mu', 'め/me', 'も/mo']],
    'y': [['や/ya', '', 'ゆ/yu', '', 'よ/yo']],
    'r': [['ら/ra', 'り/ri', 'る/ru', 'れ/re', 'ろ/ro']],
    'w': [['わ/wa', '', '', '', 'を/wo']],
    'special': [['ん/n']],
  };

  
  static const Map<String, List<List<String>>> katakanaTable = {
    'vowels': [['ア/a', 'イ/i', 'ウ/u', 'エ/e', 'オ/o']],
    'k': [['カ/ka', 'キ/ki', 'ク/ku', 'ケ/ke', 'コ/ko']],
    's': [['サ/sa', 'シ/shi', 'ス/su', 'セ/se', 'ソ/so']],
    't': [['タ/ta', 'チ/chi', 'ツ/tsu', 'テ/te', 'ト/to']],
    'n': [['ナ/na', 'ニ/ni', 'ヌ/nu', 'ネ/ne', 'ノ/no']],
    'h': [['ハ/ha', 'ヒ/hi', 'フ/fu', 'ヘ/he', 'ホ/ho']],
    'm': [['マ/ma', 'ミ/mi', 'ム/mu', 'メ/me', 'モ/mo']],
    'y': [['ヤ/ya', '', 'ユ/yu', '', 'ヨ/yo']],
    'r': [['ラ/ra', 'リ/ri', 'ル/ru', 'レ/re', 'ロ/ro']],
    'w': [['ワ/wa', '', '', '', 'ヲ/wo']],
    'special': [['ン/n']],
  };
}
