import '../models/app_user.dart';
import '../models/material_item.dart';
import '../models/member_overview_item.dart';
import '../models/question.dart';
import '../models/study_week.dart';
import 'team_repository.dart';

/// In-memory mock implementation of [TeamRepository] for offline development and testing.
class FakeTeamRepository implements TeamRepository {
  final Map<String, StudyWeek> _weeks = {};
  String? _currentWeekId;

  final Map<String, Map<String, Question>> _questions = {};
  final Map<String, Map<String, MaterialItem>> _materials = {};
  final Map<String, Map<String, bool>> _prepared = {};
  final List<AppUser> _members = [];

  FakeTeamRepository({bool seedInitialData = true}) {
    if (seedInitialData) {
      _seed();
    }
  }

  void _seed() {
    final now = DateTime.now();
    const initialWeekId = 'week_initial_seed';
    final initialWeek = StudyWeek(
      id: initialWeekId,
      book: 'Matthew',
      chapter: 5,
      verseFrom: 1,
      verseTo: 8,
      sessionDay: 'Friday',
      sessionTime: '6:00 PM',
      place: 'Church hall, Room 2',
      thursdayReminderTime: '18:00',
      publishedAt: now,
      updatedBy: 'admin',
    );

    _weeks[initialWeekId] = initialWeek;
    _currentWeekId = initialWeekId;

    _questions[initialWeekId] = {
      'q1': const Question(
        id: 'q1',
        text: 'What does it mean to be "poor in spirit" in Matthew 5:3?',
        order: 1,
        published: true,
      ),
      'q2': const Question(
        id: 'q2',
        text: 'How does mourning lead to true comfort according to verse 4?',
        order: 2,
        published: true,
      ),
      'q3': const Question(
        id: 'q3',
        text: 'Draft question: How do we apply meekness at work or school?',
        order: 3,
        published: false, // Unpublished draft
      ),
    };

    _materials[initialWeekId] = {
      'm1': const MaterialItem(
        id: 'm1',
        title: 'Historical Background of the Sermon on the Mount',
        body: 'Jesus spoke to His disciples and the multitudes on a hillside near the Sea of Galilee. The Beatitudes describe the inward character of citizens in God\'s Kingdom.',
        url: 'https://bibleproject.com',
        published: true,
      ),
      'm2': const MaterialItem(
        id: 'm2',
        title: 'Leader Study Notes (Draft)',
        body: 'Key Greek terms: Makarios (blessed/flourishing).',
        url: null,
        published: false, // Unpublished draft
      ),
    };

    _members.addAll([
      AppUser(
        uid: 'user_1',
        name: 'Sarah Chen',
        email: 'sarah@example.com',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      AppUser(
        uid: 'user_2',
        name: 'Michael Davis',
        email: 'michael@example.com',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      AppUser(
        uid: 'user_3',
        name: 'Grace Kim',
        email: 'grace@example.com',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ]);

    _prepared[initialWeekId] = {
      'user_1': true,
      'user_2': true,
      'user_3': false,
    };
  }

  void addMember(AppUser member) {
    if (!_members.any((m) => m.uid == member.uid)) {
      _members.add(member);
    }
  }

  @override
  Future<StudyWeek?> getCurrentWeek() async {
    if (_currentWeekId == null) return null;
    return _weeks[_currentWeekId];
  }

  @override
  Future<List<Question>> getQuestions(
    String weekId, {
    required bool onlyPublished,
  }) async {
    final list = _questions[weekId]?.values.toList() ?? [];
    final filtered = onlyPublished ? list.where((q) => q.published).toList() : list;
    filtered.sort((a, b) => a.order.compareTo(b.order));
    return filtered;
  }

  @override
  Future<List<MaterialItem>> getMaterials(
    String weekId, {
    required bool onlyPublished,
  }) async {
    final list = _materials[weekId]?.values.toList() ?? [];
    final filtered = onlyPublished ? list.where((m) => m.published).toList() : list;
    return filtered;
  }

  @override
  Future<bool> isUserPrepared({
    required String weekId,
    required String uid,
  }) async {
    return _prepared[weekId]?[uid] ?? false;
  }

  @override
  Future<void> setUserPrepared({
    required String weekId,
    required String uid,
    required bool prepared,
  }) async {
    final map = _prepared.putIfAbsent(weekId, () => {});
    map[uid] = prepared;
  }

  @override
  Future<StudyWeek> publishWeek(
    StudyWeek week, {
    required String updatedBy,
    bool isNewWeek = false,
  }) async {
    final current = _currentWeekId != null ? _weeks[_currentWeekId] : null;
    final passageChanged = current != null &&
        (current.book != week.book ||
            current.chapter != week.chapter ||
            current.verseFrom != week.verseFrom ||
            current.verseTo != week.verseTo);

    final String finalId;
    if (isNewWeek || passageChanged || week.id.isEmpty) {
      finalId = 'week_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      finalId = week.id;
    }

    final published = week.copyWith(
      id: finalId,
      publishedAt: DateTime.now(),
      updatedBy: updatedBy,
    );

    _weeks[finalId] = published;
    _currentWeekId = finalId;
    return published;
  }

  @override
  Future<Question> saveQuestion(String weekId, Question question) async {
    final weekQuestions = _questions.putIfAbsent(weekId, () => {});
    final id = question.id.isEmpty
        ? 'q_${DateTime.now().millisecondsSinceEpoch}'
        : question.id;
    final saved = question.copyWith(id: id);
    weekQuestions[id] = saved;
    return saved;
  }

  @override
  Future<void> deleteQuestion(String weekId, String questionId) async {
    _questions[weekId]?.remove(questionId);
  }

  @override
  Future<void> reorderQuestions(String weekId, List<Question> questions) async {
    final map = _questions.putIfAbsent(weekId, () => {});
    for (int i = 0; i < questions.length; i++) {
      final updated = questions[i].copyWith(order: i + 1);
      map[updated.id] = updated;
    }
  }

  @override
  Future<MaterialItem> saveMaterial(String weekId, MaterialItem material) async {
    final weekMaterials = _materials.putIfAbsent(weekId, () => {});
    final id = material.id.isEmpty
        ? 'm_${DateTime.now().millisecondsSinceEpoch}'
        : material.id;
    final saved = material.copyWith(id: id);
    weekMaterials[id] = saved;
    return saved;
  }

  @override
  Future<void> deleteMaterial(String weekId, String materialId) async {
    _materials[weekId]?.remove(materialId);
  }

  @override
  Future<List<MemberOverviewItem>> getMemberOverview(String weekId) async {
    final weekPrep = _prepared[weekId] ?? {};
    final list = <MemberOverviewItem>[];

    for (final member in _members) {
      final isPrep = weekPrep[member.uid] ?? false;
      list.add(
        MemberOverviewItem(
          uid: member.uid,
          name: member.name.isNotEmpty ? member.name : member.email,
          email: member.email,
          lastReadingDate: member.currentBook.isNotEmpty
              ? '${member.currentBook} ${member.currentChapter}'
              : null,
          isPrepared: isPrep,
        ),
      );
    }

    return list;
  }
}
