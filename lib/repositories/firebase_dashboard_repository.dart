import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/member_summary.dart';
import '../models/reading_entry.dart';
import '../models/study_week.dart';
import 'dashboard_repository.dart';

/// Live Firestore implementation of [DashboardRepository].
/// Reads are limited to the minimum needed (7 or 30 days).
class FirebaseDashboardRepository implements DashboardRepository {
  final FirebaseFirestore _db;

  FirebaseDashboardRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  static String _fmt(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Future<StudyWeek?> getCurrentTeamWeek() async {
    final config = await _db.collection('config').doc('currentWeek').get();
    final weekId = config.data()?['weekId'] as String?;
    if (weekId == null) return null;
    final doc = await _db.collection('weeks').doc(weekId).get();
    if (!doc.exists) return null;
    return StudyWeek.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<List<MemberSummary>> getMembers({
    required String currentTeamWeekId,
    required List<String> currentOtWeekDates,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Last 7 days range (inclusive)
    final weekAgo = today.subtract(const Duration(days: 6));
    final weekAgoStr = _fmt(weekAgo);
    final todayStr = _fmt(today);

    // Fetch all users (admin-only read, enforced by Firestore rules)
    final usersSnap = await _db.collection('users').get();

    // For each user, fetch last 7 IBS readings and OT readings in parallel.
    final futures = usersSnap.docs.map((userDoc) async {
      final uid = userDoc.id;
      final data = userDoc.data();
      if (data['role'] == 'admin') return null; // skip admins

      // Fetch IBS readings for last 7 days
      final ibsSnap = await _db
          .collection('users')
          .doc(uid)
          .collection('readings')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: weekAgoStr)
          .where(FieldPath.documentId, isLessThanOrEqualTo: todayStr)
          .get();

      final ibsEntries = ibsSnap.docs
          .map((d) => ReadingEntry.fromMap(d.id, d.data()))
          .where((e) => e.completed)
          .toList();

      // Fetch OT readings for last 7 days
      final otSnap = await _db
          .collection('users')
          .doc(uid)
          .collection('otReadings')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: weekAgoStr)
          .where(FieldPath.documentId, isLessThanOrEqualTo: todayStr)
          .get();

      final otDates = otSnap.docs
          .where((d) => d.data()['completed'] == true)
          .map((d) => d.id)
          .toList();

      // Fetch prepared status for current team week
      bool prepared = false;
      if (currentTeamWeekId.isNotEmpty) {
        final prepDoc = await _db
            .collection('weeks')
            .doc(currentTeamWeekId)
            .collection('prepared')
            .doc(uid)
            .get();
        prepared = prepDoc.data()?['prepared'] == true;
      }

      // Compute lastReadDate across IBS and OT
      final allDates = [
        ...ibsEntries.map((e) => e.date),
        ...otDates,
      ]..sort((a, b) => b.compareTo(a));
      final lastReadDate = allDates.isEmpty ? null : allDates.first;

      // OT days for this week (only from assigned dates)
      final otDaysThisWeek =
          otDates.where((d) => currentOtWeekDates.contains(d)).length;

      final joinDate = _parseDate(data['createdAt']);

      return MemberSummary(
        uid: uid,
        name: data['name'] as String? ?? '',
        email: data['email'] as String? ?? '',
        role: data['role'] as String? ?? 'member',
        joinDate: joinDate,
        currentBook: data['currentBook'] as String? ?? 'John',
        currentChapter: (data['currentChapter'] as num?)?.toInt() ?? 1,
        currentVerseFrom: (data['verseFrom'] as num?)?.toInt() ?? 1,
        currentVerseTo: (data['verseTo'] as num?)?.toInt() ?? 1,
        ibsDaysThisWeek: ibsEntries.length,
        otDaysThisWeek: otDaysThisWeek,
        otTotalDaysThisWeek: currentOtWeekDates.length,
        preparedThisWeek: prepared,
        lastReadDate: lastReadDate,
      );
    });

    final results = await Future.wait(futures);
    return results.whereType<MemberSummary>().toList();
  }

  @override
  Future<List<ReadingEntry>> getMemberIbsHistory(String uid) async {
    final now = DateTime.now();
    final from = _fmt(now.subtract(const Duration(days: 29)));
    final to = _fmt(now);

    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('readings')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: from)
        .where(FieldPath.documentId, isLessThanOrEqualTo: to)
        .get();

    final list = snap.docs
        .map((d) => ReadingEntry.fromMap(d.id, d.data()))
        .where((e) => e.completed)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<List<String>> getMemberOtHistory(String uid) async {
    final now = DateTime.now();
    final from = _fmt(now.subtract(const Duration(days: 29)));
    final to = _fmt(now);

    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('otReadings')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: from)
        .where(FieldPath.documentId, isLessThanOrEqualTo: to)
        .get();

    return snap.docs
        .where((d) => d.data()['completed'] == true)
        .map((d) => d.id)
        .toList()
      ..sort((a, b) => b.compareTo(a));
  }

  @override
  Future<Map<String, bool>> getMemberTeamHistory(String uid) async {
    // Fetch last 8 published weeks and check prepared status for each
    final weeksSnap = await _db
        .collection('weeks')
        .orderBy('publishedAt', descending: true)
        .limit(8)
        .get();

    final result = <String, bool>{};
    final futures = weeksSnap.docs.map((weekDoc) async {
      final prepDoc = await _db
          .collection('weeks')
          .doc(weekDoc.id)
          .collection('prepared')
          .doc(uid)
          .get();
      result[weekDoc.id] = prepDoc.data()?['prepared'] == true;
    });
    await Future.wait(futures);
    return result;
  }

  DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
