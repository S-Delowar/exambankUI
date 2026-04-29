import 'package:sqflite/sqflite.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/db/local_database.dart';
import '../../../core/models/exam_paper.dart';
import '../../../core/models/question.dart';

class ExamFilters {
  final String? university;
  final String? session;
  final String? unit;
  final String? q;
  const ExamFilters({this.university, this.session, this.unit, this.q});

  Map<String, dynamic> toQuery() => {
        if (university != null && university!.isNotEmpty) 'university': university,
        if (session != null && session!.isNotEmpty) 'session': session,
        if (unit != null && unit!.isNotEmpty) 'unit': unit,
        if (q != null && q!.isNotEmpty) 'q': q,
      };
}

class ExamRepository {
  final ApiClient _api;
  ExamRepository(this._api);

  Future<List<ExamPaper>> listPapers({
    ExamFilters filters = const ExamFilters(),
    int limit = 100,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    try {
      final resp = await _api.dio.get(
        Endpoints.exams,
        queryParameters: {
          ...filters.toQuery(),
          'limit': limit,
          'offset': offset,
        },
      );
      final items = ((resp.data['items'] as List?) ?? const [])
          .map((e) => ExamPaper.fromJson(e as Map<String, dynamic>))
          .toList();
      await _cachePapers(items);
      return items;
    } catch (_) {
      return _readCachedPapers();
    }
  }

  Future<ExamPaper?> getPaper(String id) async {
    try {
      final resp = await _api.dio.get('${Endpoints.exams}/$id');
      return ExamPaper.fromJson(resp.data as Map<String, dynamic>);
    } catch (_) {
      final db = LocalDatabase.instance.db;
      final rows = await db.query(
        'exam_papers_cache',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return _paperFromRow(rows.first);
    }
  }

  Future<List<Question>> getQuestionsForPaper(String paperId) async {
    try {
      final resp = await _api.dio.get(
        Endpoints.questions,
        queryParameters: {'paper_id': paperId, 'limit': 500},
      );
      final items = ((resp.data['items'] as List?) ?? const [])
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList();
      await _cacheQuestions(paperId, items);
      return items;
    } catch (_) {
      return _readCachedQuestions(paperId);
    }
  }

  // ---- caching helpers ----

  Future<void> _cachePapers(List<ExamPaper> papers) async {
    final db = LocalDatabase.instance.db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = db.batch();
    for (final p in papers) {
      batch.insert(
        'exam_papers_cache',
        {
          'id': p.id,
          'source_filename': p.sourceFilename,
          'university_name': p.universityName,
          'exam_session': p.examSession,
          'exam_unit': p.examUnit,
          'page_count': p.pageCount,
          'question_count': p.questionCount,
          'cached_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<ExamPaper>> _readCachedPapers() async {
    final db = LocalDatabase.instance.db;
    final rows = await db.query(
      'exam_papers_cache',
      orderBy: 'university_name ASC, exam_session DESC',
    );
    return rows.map(_paperFromRow).toList();
  }

  ExamPaper _paperFromRow(Map<String, Object?> r) => ExamPaper(
        id: r['id'] as String,
        sourceFilename: r['source_filename'] as String,
        universityName: r['university_name'] as String?,
        examSession: r['exam_session'] as String?,
        examUnit: r['exam_unit'] as String?,
        pageCount: (r['page_count'] as int?) ?? 0,
        questionCount: (r['question_count'] as int?) ?? 0,
      );

  Future<void> _cacheQuestions(String paperId, List<Question> qs) async {
    final db = LocalDatabase.instance.db;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      await txn.delete(
        'questions_cache',
        where: 'paper_id = ?',
        whereArgs: [paperId],
      );
      for (final q in qs) {
        await txn.delete(
          'options_cache',
          where: 'question_id = ?',
          whereArgs: [q.id],
        );
        await txn.insert(
          'questions_cache',
          {
            'id': q.id,
            'paper_id': q.paperId,
            'question_number': q.questionNumber,
            'question_text': q.questionText,
            'subject': q.subject,
            'chapter': q.chapter,
            'correct_answer': q.correctAnswer,
            'solution': q.solution,
            'solution_status': q.solutionStatus,
            'has_image': q.hasImage ? 1 : 0,
            'cached_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        for (var i = 0; i < q.options.length; i++) {
          final o = q.options[i];
          await txn.insert(
            'options_cache',
            {
              'id': '${q.id}_$i',
              'question_id': q.id,
              'label': o.label,
              'text': o.text,
              'display_order': i,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  Future<List<Question>> _readCachedQuestions(String paperId) async {
    final db = LocalDatabase.instance.db;
    final qRows = await db.query(
      'questions_cache',
      where: 'paper_id = ?',
      whereArgs: [paperId],
      orderBy: 'question_number ASC',
    );
    if (qRows.isEmpty) return [];
    final out = <Question>[];
    for (final r in qRows) {
      final oRows = await db.query(
        'options_cache',
        where: 'question_id = ?',
        whereArgs: [r['id']],
        orderBy: 'display_order ASC',
      );
      out.add(Question(
        id: r['id'] as String,
        paperId: r['paper_id'] as String,
        questionNumber: r['question_number'] as String,
        questionText: r['question_text'] as String,
        subject: r['subject'] as String?,
        chapter: r['chapter'] as String?,
        correctAnswer: r['correct_answer'] as String?,
        solution: r['solution'] as String?,
        solutionStatus: r['solution_status'] as String? ?? 'pending',
        hasImage: (r['has_image'] as int?) == 1,
        options: oRows
            .map((o) => QuestionOption(
                  label: o['label'] as String,
                  text: o['text'] as String,
                ))
            .toList(),
      ));
    }
    return out;
  }
}

