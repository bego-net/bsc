import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ot_day.dart';
import '../models/ot_member_overview_item.dart';
import '../models/ot_week.dart';
import 'ot_repository.dart';

/// Firebase Firestore implementation of [OtRepository].
class FirebaseOtRepository implements OtRepository {
  final FirebaseFirestore _firestore;

  FirebaseOtRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<OtWeek?> getCurrentWeek() async {
    final configDoc =
        await _firestore.collection('config').doc('currentOtWeek').get();
    if (!configDoc.exists || configDoc.data() == null) {
      return null;
    }

    final weekId = configDoc.data()?['weekId'] as String?;
    if (weekId == null || weekId.isEmpty) {
      return null;
    }

    final weekDoc = await _firestore.collection('otWeeks').doc(weekId).get();
    if (!weekDoc.exists || weekDoc.data() == null) {
      return null;
    }

    final data = weekDoc.data()!;
    final book = data['book'] as String?;
    List<OtDay> days = const [];
    if (book == null || book.isEmpty) {
      days = await getDaysForWeek(weekId);
    }
    return OtWeek.fromMap(weekDoc.id, data, days: days);
  }

  @override
  Future<List<OtDay>> getDaysForWeek(String weekId) async {
    final doc = await _firestore.collection('otWeeks').doc(weekId).get();
    if (doc.exists && doc.data() != null) {
      final book = doc.data()?['book'] as String?;
      if (book != null && book.isNotEmpty) {
        final startChapter = (doc.data()?['startChapter'] as num?)?.toInt() ?? 1;
        final startDate = doc.data()?['startDate'] as String? ?? '';
        return computeOtDaysForWeek(
          book: book,
          startChapter: startChapter,
          startDate: startDate,
        );
      }
    }

    final snap = await _firestore
        .collection('otWeeks')
        .doc(weekId)
        .collection('days')
        .get();

    final list = snap.docs
        .map((doc) => OtDay.fromMap(doc.id, doc.data()))
        .toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  @override
  Future<Map<String, bool>> getUserReadingsForWeek({
    required String uid,
    required String weekId,
    required List<String> dates,
  }) async {
    final result = <String, bool>{};
    for (final d in dates) {
      result[d] = false;
    }

    // Read the user's readings documents for the specified dates
    for (final date in dates) {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('otReadings')
          .doc(date)
          .get();

      if (doc.exists && doc.data() != null) {
        result[date] = doc.data()?['completed'] as bool? ?? false;
      }
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
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('otReadings')
        .doc(date)
        .set({
      'weekId': weekId,
      'completed': completed,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<int> getUserStreak(String uid) async {
    try {
      final snap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('otReadings')
          .where('completed', isEqualTo: true)
          .get();

      final completedDates = snap.docs
          .map((d) => DateTime.tryParse(d.id))
          .whereType<DateTime>()
          .map((dt) => DateTime(dt.year, dt.month, dt.day))
          .toSet();

      if (completedDates.isEmpty) return 0;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      DateTime current;
      if (completedDates.contains(today)) {
        current = today;
      } else if (completedDates.contains(yesterday)) {
        current = yesterday;
      } else {
        return 0;
      }

      final currentPlan = await getCurrentWeek();
      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      int streak = 0;
      while (completedDates.contains(current)) {
        if (currentPlan != null && currentPlan.isChapterPerDay) {
          final day = currentPlan.getDayForDate(fmt(current));
          if (day == null) {
            break;
          }
        }
        streak++;
        current = current.subtract(const Duration(days: 1));
      }
      return streak;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<List<OtWeek>> getWeekHistory() async {
    final snap = await _firestore
        .collection('otWeeks')
        .orderBy('startDate', descending: true)
        .get();

    final weeks = <OtWeek>[];
    for (final doc in snap.docs) {
      final days = await getDaysForWeek(doc.id);
      weeks.add(OtWeek.fromMap(doc.id, doc.data(), days: days));
    }
    return weeks;
  }

  @override
  Future<OtWeek> publishWeek({
    String topic = '',
    required String startDate,
    List<OtDay> days = const [],
    required String updatedBy,
    String? book,
    int? startChapter,
  }) async {
    final docRef = _firestore.collection('otWeeks').doc();
    final isChapterPerDay = book != null && book.isNotEmpty;

    final week = OtWeek(
      id: docRef.id,
      topic: topic,
      startDate: startDate,
      publishedAt: DateTime.now(),
      updatedBy: updatedBy,
      days: isChapterPerDay
          ? computeOtDaysForWeek(
              book: book,
              startChapter: startChapter ?? 1,
              startDate: startDate,
            )
          : days,
      book: book,
      startChapter: startChapter,
    );

    // Save one plan document
    await docRef.set(week.toMap());

    // Only save days subcollection for legacy plans without a book ("No per-day documents")
    if (!isChapterPerDay && days.isNotEmpty) {
      final batch = _firestore.batch();
      for (final day in days) {
        final dayRef = docRef.collection('days').doc(day.date);
        batch.set(dayRef, day.toMap());
      }
      await batch.commit();
    }

    // Update config/currentOtWeek
    await _firestore.collection('config').doc('currentOtWeek').set({
      'weekId': docRef.id,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return week;
  }

  @override
  Future<List<OtMemberOverviewItem>> getMemberOverview(
    String weekId,
    List<String> weekDates,
  ) async {
    final usersSnap = await _firestore.collection('users').get();
    final result = <OtMemberOverviewItem>[];

    for (final userDoc in usersSnap.docs) {
      final uid = userDoc.id;
      final data = userDoc.data();
      final name = data['name'] as String? ?? '';
      final email = data['email'] as String? ?? '';

      int count = 0;
      for (final date in weekDates) {
        final rDoc = await _firestore
            .collection('users')
            .doc(uid)
            .collection('otReadings')
            .doc(date)
            .get();
        if (rDoc.exists && rDoc.data()?['completed'] == true) {
          count++;
        }
      }

      result.add(
        OtMemberOverviewItem(
          uid: uid,
          name: name.isNotEmpty ? name : (email.isNotEmpty ? email : uid),
          email: email,
          completedDays: count,
          totalDays: weekDates.length,
        ),
      );
    }

    return result;
  }

  @override
  Future<bool> getOtRemindersEnabled(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return true;
    return doc.data()?['otRemindersEnabled'] as bool? ?? true;
  }

  @override
  Future<void> setOtRemindersEnabled({
    required String uid,
    required bool enabled,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'otRemindersEnabled': enabled,
    }, SetOptions(merge: true));
  }
}
