import '../models/ot_day.dart';
import '../models/ot_member_overview_item.dart';
import '../models/ot_week.dart';
import 'ot_repository.dart';

/// In-memory implementation of [OtRepository] for testing and offline development.
class FakeOtRepository implements OtRepository {
  final Map<String, OtWeek> _weeks = {};
  String? _currentWeekId;
  final Map<String, Map<String, OtDay>> _days = {};
  final Map<String, Map<String, bool>> _userReadings = {}; // uid -> date -> bool
  final Map<String, bool> _remindersEnabled = {};

  final List<Map<String, String>> _mockMembers = [
    {'uid': 'user_test', 'name': 'Test Member', 'email': 'test@example.com'},
    {'uid': 'user_selam', 'name': 'Selam T.', 'email': 'selam@example.com'},
    {'uid': 'user_dawit', 'name': 'Dawit K.', 'email': 'dawit@example.com'},
  ];

  FakeOtRepository({bool seedInitialData = true}) {
    if (seedInitialData) {
      _seed();
    }
  }

  void _seed() {
    // Determine the Monday of the current week
    final now = DateTime.now();
    final daysFromMonday = (now.weekday - DateTime.monday) % 7;
    final monday = DateTime(now.year, now.month, now.day - daysFromMonday);

    String formatDate(DateTime dt) =>
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

    final mondayStr = formatDate(monday);
    const weekId = 'ot_week_seed_1';

    final week = OtWeek(
      id: weekId,
      topic: 'Faith: the journey of Abraham',
      startDate: mondayStr,
      publishedAt: now.subtract(const Duration(days: 2)),
      updatedBy: 'admin',
    );
    _weeks[weekId] = week;
    _currentWeekId = weekId;

    final seedDays = <String, OtDay>{};
    final passages = [
      ('Genesis', 12, null, null), // whole chapter
      ('Genesis', 13, null, null),
      ('Genesis', 15, 1, 6), // verse range
      ('Genesis', 17, null, null),
      ('Genesis', 22, 1, 19),
    ];

    for (int i = 0; i < 5; i++) {
      final date = formatDate(monday.add(Duration(days: i)));
      final p = passages[i];
      seedDays[date] = OtDay(
        date: date,
        book: p.$1,
        chapter: p.$2,
        verseFrom: p.$3,
        verseTo: p.$4,
      );
    }
    _days[weekId] = seedDays;

    // Seed mock completion for Selam T.
    _userReadings['user_selam'] = {};
    for (int i = 0; i < 4; i++) {
      final date = formatDate(monday.add(Duration(days: i)));
      _userReadings['user_selam']![date] = true;
    }
  }

  @override
  Future<OtWeek?> getCurrentWeek() async {
    if (_currentWeekId == null) return null;
    final week = _weeks[_currentWeekId];
    if (week == null) return null;
    final days = await getDaysForWeek(week.id);
    return week.copyWith(days: days);
  }

  @override
  Future<List<OtDay>> getDaysForWeek(String weekId) async {
    final daysMap = _days[weekId] ?? {};
    final list = daysMap.values.toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  @override
  Future<Map<String, bool>> getUserReadingsForWeek({
    required String uid,
    required String weekId,
    required List<String> dates,
  }) async {
    final userMap = _userReadings[uid] ?? {};
    final result = <String, bool>{};
    for (final d in dates) {
      result[d] = userMap[d] ?? false;
    }
    return result;
  }

  @override
  Future<void> setDayCompleted({
    required String uid,
    required String weekId,
    required String date,
    required bool completed,
  }) async {
    _userReadings.putIfAbsent(uid, () => {})[date] = completed;
  }

  @override
  Future<int> getUserStreak(String uid) async {
    final userMap = _userReadings[uid] ?? {};
    final completedDates = userMap.entries
        .where((e) => e.value)
        .map((e) => DateTime.tryParse(e.key))
        .whereType<DateTime>()
        .map((dt) => DateTime(dt.year, dt.month, dt.day))
        .toSet();

    if (completedDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    DateTime current;
    if (completedDates.contains(todayDate)) {
      current = todayDate;
    } else if (completedDates.contains(yesterdayDate)) {
      current = yesterdayDate;
    } else {
      return 0;
    }

    int streak = 0;
    while (completedDates.contains(current)) {
      streak++;
      current = current.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Future<List<OtWeek>> getWeekHistory() async {
    final list = <OtWeek>[];
    for (final w in _weeks.values) {
      final days = await getDaysForWeek(w.id);
      list.add(w.copyWith(days: days));
    }
    list.sort((a, b) => b.startDate.compareTo(a.startDate));
    return list;
  }

  @override
  Future<OtWeek> publishWeek({
    required String topic,
    required String startDate,
    required List<OtDay> days,
    required String updatedBy,
  }) async {
    final id = 'ot_week_${DateTime.now().millisecondsSinceEpoch}';
    final week = OtWeek(
      id: id,
      topic: topic,
      startDate: startDate,
      publishedAt: DateTime.now(),
      updatedBy: updatedBy,
      days: days,
    );

    _weeks[id] = week;
    _currentWeekId = id;

    final daysMap = <String, OtDay>{};
    for (final d in days) {
      daysMap[d.date] = d;
    }
    _days[id] = daysMap;

    return week;
  }

  @override
  Future<List<OtMemberOverviewItem>> getMemberOverview(
    String weekId,
    List<String> weekDates,
  ) async {
    final result = <OtMemberOverviewItem>[];
    final totalDays = weekDates.length;

    for (final m in _mockMembers) {
      final uid = m['uid']!;
      final name = m['name']!;
      final email = m['email']!;
      final userMap = _userReadings[uid] ?? {};

      int count = 0;
      for (final d in weekDates) {
        if (userMap[d] == true) count++;
      }

      result.add(
        OtMemberOverviewItem(
          uid: uid,
          name: name,
          email: email,
          completedDays: count,
          totalDays: totalDays,
        ),
      );
    }

    return result;
  }

  @override
  Future<bool> getOtRemindersEnabled(String uid) async {
    return _remindersEnabled[uid] ?? true;
  }

  @override
  Future<void> setOtRemindersEnabled({
    required String uid,
    required bool enabled,
  }) async {
    _remindersEnabled[uid] = enabled;
  }
}
