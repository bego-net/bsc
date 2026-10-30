import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/material_item.dart';
import '../models/member_overview_item.dart';
import '../models/question.dart';
import '../models/study_week.dart';
import 'team_repository.dart';

/// Firebase Firestore implementation of [TeamRepository].
class FirebaseTeamRepository implements TeamRepository {
  final FirebaseFirestore _firestore;

  FirebaseTeamRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<StudyWeek?> getCurrentWeek() async {
    final configDoc = await _firestore.collection('config').doc('currentWeek').get();
    if (!configDoc.exists || configDoc.data() == null) {
      return null;
    }

    final weekId = configDoc.data()?['weekId'] as String?;
    if (weekId == null || weekId.isEmpty) {
      return null;
    }

    final weekDoc = await _firestore.collection('weeks').doc(weekId).get();
    if (!weekDoc.exists || weekDoc.data() == null) {
      return null;
    }

    return StudyWeek.fromMap(weekDoc.id, weekDoc.data()!);
  }

  @override
  Future<List<Question>> getQuestions(
    String weekId, {
    required bool onlyPublished,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('weeks')
        .doc(weekId)
        .collection('questions');

    if (onlyPublished) {
      query = query.where('published', isEqualTo: true);
    }

    final snapshot = await query.get();
    final list = snapshot.docs
        .map((doc) => Question.fromMap(doc.id, doc.data()))
        .toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  @override
  Future<List<MaterialItem>> getMaterials(
    String weekId, {
    required bool onlyPublished,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('weeks')
        .doc(weekId)
        .collection('materials');

    if (onlyPublished) {
      query = query.where('published', isEqualTo: true);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => MaterialItem.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<bool> isUserPrepared({
    required String weekId,
    required String uid,
  }) async {
    final doc = await _firestore
        .collection('weeks')
        .doc(weekId)
        .collection('prepared')
        .doc(uid)
        .get();

    if (!doc.exists || doc.data() == null) {
      return false;
    }
    return doc.data()?['prepared'] as bool? ?? false;
  }

  @override
  Future<void> setUserPrepared({
    required String weekId,
    required String uid,
    required bool prepared,
  }) async {
    await _firestore
        .collection('weeks')
        .doc(weekId)
        .collection('prepared')
        .doc(uid)
        .set({
      'prepared': prepared,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<StudyWeek> publishWeek(
    StudyWeek week, {
    required String updatedBy,
    bool isNewWeek = false,
  }) async {
    // Check current week
    final currentWeek = await getCurrentWeek();
    final passageChanged = currentWeek != null &&
        (currentWeek.book != week.book ||
            currentWeek.chapter != week.chapter ||
            currentWeek.verseFrom != week.verseFrom ||
            currentWeek.verseTo != week.verseTo);

    final DocumentReference<Map<String, dynamic>> weekRef;
    if (isNewWeek || passageChanged || week.id.isEmpty) {
      weekRef = _firestore.collection('weeks').doc();
    } else {
      weekRef = _firestore.collection('weeks').doc(week.id);
    }

    final toSave = week.copyWith(
      id: weekRef.id,
      publishedAt: DateTime.now(),
      updatedBy: updatedBy,
    );

    await weekRef.set(toSave.toMap(), SetOptions(merge: true));

    // Update config/currentWeek
    await _firestore.collection('config').doc('currentWeek').set({
      'weekId': weekRef.id,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return toSave;
  }

  @override
  Future<Question> saveQuestion(String weekId, Question question) async {
    final collection = _firestore
        .collection('weeks')
        .doc(weekId)
        .collection('questions');

    final DocumentReference<Map<String, dynamic>> docRef;
    if (question.id.isEmpty) {
      docRef = collection.doc();
    } else {
      docRef = collection.doc(question.id);
    }

    final toSave = question.copyWith(id: docRef.id);
    await docRef.set(toSave.toMap(), SetOptions(merge: true));
    return toSave;
  }

  @override
  Future<void> deleteQuestion(String weekId, String questionId) async {
    await _firestore
        .collection('weeks')
        .doc(weekId)
        .collection('questions')
        .doc(questionId)
        .delete();
  }

  @override
  Future<void> reorderQuestions(String weekId, List<Question> questions) async {
    final batch = _firestore.batch();
    for (int i = 0; i < questions.length; i++) {
      final docRef = _firestore
          .collection('weeks')
          .doc(weekId)
          .collection('questions')
          .doc(questions[i].id);
      batch.update(docRef, {'order': i + 1});
    }
    await batch.commit();
  }

  @override
  Future<MaterialItem> saveMaterial(String weekId, MaterialItem material) async {
    final collection = _firestore
        .collection('weeks')
        .doc(weekId)
        .collection('materials');

    final DocumentReference<Map<String, dynamic>> docRef;
    if (material.id.isEmpty) {
      docRef = collection.doc();
    } else {
      docRef = collection.doc(material.id);
    }

    final toSave = material.copyWith(id: docRef.id);
    await docRef.set(toSave.toMap(), SetOptions(merge: true));
    return toSave;
  }

  @override
  Future<void> deleteMaterial(String weekId, String materialId) async {
    await _firestore
        .collection('weeks')
        .doc(weekId)
        .collection('materials')
        .doc(materialId)
        .delete();
  }

  @override
  Future<List<MemberOverviewItem>> getMemberOverview(String weekId) async {
    // 1. Get all members
    final usersSnapshot = await _firestore.collection('users').get();

    // 2. Get all prepared records for week
    final prepSnapshot = await _firestore
        .collection('weeks')
        .doc(weekId)
        .collection('prepared')
        .get();

    final prepMap = <String, bool>{};
    for (final doc in prepSnapshot.docs) {
      prepMap[doc.id] = doc.data()['prepared'] as bool? ?? false;
    }

    final list = <MemberOverviewItem>[];
    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      final uid = doc.id;
      final name = data['name'] as String? ?? '';
      final email = data['email'] as String? ?? '';
      final isPrepared = prepMap[uid] ?? false;

      // Find user's last reading date if available
      String? lastReading;
      try {
        final readingsSnap = await _firestore
            .collection('users')
            .doc(uid)
            .collection('readings')
            .orderBy('date', descending: true)
            .limit(1)
            .get();
        if (readingsSnap.docs.isNotEmpty) {
          lastReading = readingsSnap.docs.first.id;
        }
      } catch (_) {}

      list.add(
        MemberOverviewItem(
          uid: uid,
          name: name.isNotEmpty ? name : (email.isNotEmpty ? email : uid),
          email: email,
          lastReadingDate: lastReading,
          isPrepared: isPrepared,
        ),
      );
    }

    return list;
  }
}
