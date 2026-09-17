import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/flashcard_progress.dart';
import '../models/study_history.dart';
import '../models/vocabulary.dart';

class LocalDatabaseService {
  LocalDatabaseService._();
  static final LocalDatabaseService instance = LocalDatabaseService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      p.join(dbPath, 'nihongo_master.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vocabulary_cache (
            id TEXT PRIMARY KEY,
            japanese TEXT,
            hiragana TEXT,
            romaji TEXT,
            vietnamese TEXT,
            english TEXT,
            jlptLevel TEXT,
            category TEXT,
            exampleSentences TEXT,
            exampleTranslations TEXT,
            isLearned INTEGER,
            isFavorite INTEGER,
            correctCount INTEGER,
            wrongCount INTEGER,
            lastStudied TEXT,
            srsInterval INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE flashcard_progress (
            vocabId TEXT PRIMARY KEY,
            userId TEXT,
            interval INTEGER,
            easeFactor REAL,
            repetition INTEGER,
            nextReview TEXT,
            correctCount INTEGER,
            wrongCount INTEGER,
            lastReviewed TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE test_history (
            id TEXT PRIMARY KEY,
            userId TEXT,
            testId TEXT,
            title TEXT,
            jlptLevel TEXT,
            totalQuestions INTEGER,
            correctAnswers INTEGER,
            wrongAnswers INTEGER,
            scorePercent REAL,
            timeTakenSeconds INTEGER,
            completedAt TEXT
          )
        ''');
      },
    );
    return _database!;
  }

  Future<void> cacheVocabulary(List<VocabularyWord> words) async {
    final db = await database;
    final batch = db.batch();
    for (final word in words) {
      batch.insert(
        'vocabulary_cache',
        {
          'id': word.id,
          'japanese': word.japanese,
          'hiragana': word.hiragana,
          'romaji': word.romaji,
          'vietnamese': word.vietnamese,
          'english': word.english,
          'jlptLevel': word.jlptLevel,
          'category': word.category,
          'exampleSentences': jsonEncode(word.exampleSentences),
          'exampleTranslations': jsonEncode(word.exampleTranslations),
          'isLearned': word.isLearned ? 1 : 0,
          'isFavorite': word.isFavorite ? 1 : 0,
          'correctCount': word.correctCount,
          'wrongCount': word.wrongCount,
          'lastStudied': word.lastStudied?.toIso8601String(),
          'srsInterval': word.srsInterval,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<VocabularyWord>> getCachedVocabulary() async {
    final db = await database;
    final rows = await db.query('vocabulary_cache');
    return rows.map((map) {
      return VocabularyWord(
        id: map['id'] as String,
        japanese: map['japanese'] as String,
        hiragana: map['hiragana'] as String,
        romaji: map['romaji'] as String,
        vietnamese: map['vietnamese'] as String,
        english: map['english'] as String,
        jlptLevel: map['jlptLevel'] as String,
        category: map['category'] as String,
        exampleSentences: List<String>.from(jsonDecode(map['exampleSentences'] as String? ?? '[]')),
        exampleTranslations: List<String>.from(jsonDecode(map['exampleTranslations'] as String? ?? '[]')),
        isLearned: (map['isLearned'] as int? ?? 0) == 1,
        isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
        correctCount: map['correctCount'] as int? ?? 0,
        wrongCount: map['wrongCount'] as int? ?? 0,
        lastStudied: map['lastStudied'] == null ? null : DateTime.tryParse(map['lastStudied'] as String),
        srsInterval: map['srsInterval'] as int? ?? 1,
      );
    }).toList();
  }

  Future<void> upsertFlashcardProgress(FlashcardProgress progress) async {
    final db = await database;
    await db.insert(
      'flashcard_progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, FlashcardProgress>> getAllFlashcardProgress({String? userId}) async {
    final db = await database;
    final rows = await db.query(
      'flashcard_progress',
      where: userId == null ? null : 'userId = ?',
      whereArgs: userId == null ? null : [userId],
    );
    return {for (final row in rows) (row['vocabId'] as String): FlashcardProgress.fromMap(row)};
  }

  Future<void> upsertStudyHistory(StudyHistory history) async {
    final db = await database;
    await db.insert(
      'test_history',
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StudyHistory>> getStudyHistories({String? userId}) async {
    final db = await database;
    final rows = await db.query(
      'test_history',
      where: userId == null ? null : 'userId = ?',
      whereArgs: userId == null ? null : [userId],
      orderBy: 'completedAt DESC',
    );
    return rows.map(StudyHistory.fromMap).toList();
  }
}
