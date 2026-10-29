import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/reading_entry.dart';
import 'study_repository.dart';

/// Firebase implementation of [StudyRepository] using Cloud Firestore.
class FirebaseStudyRepository implements StudyRepository {
  final FirebaseFirestore _firestore;

  FirebaseStudyRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> updateCurrentStudy({
    required String uid,
    required String book,
    required int chapter,
    required int verse,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'currentBook': book,
      'currentChapter': chapter,
      'currentVerse': verse,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateReminderTime({
    required String uid,
    required String reminderTime,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'reminderTime': reminderTime,
    }, SetOptions(merge: true));
  }

  @override
  Future<ReadingEntry?> getReadingForDate({
    required String uid,
    required String date,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('readings')
        .doc(date)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return ReadingEntry.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<void> saveReading({
    required String uid,
    required ReadingEntry entry,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('readings')
        .doc(entry.date)
        .set(entry.toMap(), SetOptions(merge: true));
  }

  @override
  Future<List<ReadingEntry>> getReadingHistory({
    required String uid,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('readings')
        .get();

    final entries = snapshot.docs
        .map((doc) => ReadingEntry.fromMap(doc.id, doc.data()))
        .toList();

    // Sort newest date first
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }
}
