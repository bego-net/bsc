import '../models/material_item.dart';
import '../models/member_overview_item.dart';
import '../models/question.dart';
import '../models/study_week.dart';

/// Abstract repository for Team Bible Study data, discussions, and member preparation.
abstract class TeamRepository {
  /// Fetches the currently active [StudyWeek] configured for the group.
  Future<StudyWeek?> getCurrentWeek();

  /// Fetches discussion questions for [weekId].
  /// When [onlyPublished] is true, only questions with `published == true` are returned.
  Future<List<Question>> getQuestions(
    String weekId, {
    required bool onlyPublished,
  });

  /// Fetches study materials for [weekId].
  /// When [onlyPublished] is true, only materials with `published == true` are returned.
  Future<List<MaterialItem>> getMaterials(
    String weekId, {
    required bool onlyPublished,
  });

  /// Checks if [uid] has marked themselves prepared for [weekId].
  Future<bool> isUserPrepared({
    required String weekId,
    required String uid,
  });

  /// Sets [uid]'s preparation status for [weekId].
  Future<void> setUserPrepared({
    required String weekId,
    required String uid,
    required bool prepared,
  });

  /// Publishes a study week.
  /// If the passage differs or [isNewWeek] is true, creates a new week document
  /// and updates `config/currentWeek`.
  Future<StudyWeek> publishWeek(
    StudyWeek week, {
    required String updatedBy,
    bool isNewWeek = false,
  });

  /// Adds or updates a question for [weekId].
  Future<Question> saveQuestion(String weekId, Question question);

  /// Deletes a question from [weekId].
  Future<void> deleteQuestion(String weekId, String questionId);

  /// Reorders questions for [weekId].
  Future<void> reorderQuestions(String weekId, List<Question> questions);

  /// Adds or updates a material item for [weekId].
  Future<MaterialItem> saveMaterial(String weekId, MaterialItem material);

  /// Deletes a material item from [weekId].
  Future<void> deleteMaterial(String weekId, String materialId);

  /// Fetches overview of all members and their preparation status for [weekId].
  Future<List<MemberOverviewItem>> getMemberOverview(String weekId);
}
