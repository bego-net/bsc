import 'package:flutter/foundation.dart';

import '../models/material_item.dart';
import '../models/question.dart';
import '../models/study_week.dart';
import '../repositories/team_repository.dart';
import '../services/notification_service.dart';

/// State management for the Team BS tab.
///
/// Holds the current week, questions, materials, and prepared status.
/// Admins see all content (published + drafts); members see published only.
class TeamState extends ChangeNotifier {
  final TeamRepository _repo;
  final String? _uid;
  final bool _isAdmin;
  final NotificationService _notificationService;

  StudyWeek? _currentWeek;
  List<Question> _questions = [];
  List<MaterialItem> _materials = [];
  bool _isPrepared = false;
  String _languageCode = 'am';
  bool _isLoading = false;
  String? _errorMessage;

  bool _disposed = false;

  TeamState({
    required TeamRepository repository,
    required this._uid,
    required this._isAdmin,
    required this._notificationService,
  }) : _repo = repository;

  // ── Getters ─────────────────────────────────────────────────────────────────

  StudyWeek? get currentWeek => _currentWeek;
  List<Question> get questions => List.unmodifiable(_questions);
  List<MaterialItem> get materials => List.unmodifiable(_materials);
  bool get isPrepared => _isPrepared;
  String get languageCode => _languageCode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _isAdmin;
  String? get uid => _uid;

  // ── Data Loading ─────────────────────────────────────────────────────────────

  /// Loads all Team BS data for the current user.
  Future<void> loadData() async {
    if (_disposed) return;
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();

    try {
      _currentWeek = await _repo.getCurrentWeek();

      final week = _currentWeek;
      if (week != null) {
        _questions = await _repo.getQuestions(
          week.id,
          onlyPublished: !_isAdmin,
        );
        _materials = await _repo.getMaterials(
          week.id,
          onlyPublished: !_isAdmin,
        );

        if (_uid != null) {
          _isPrepared = await _repo.isUserPrepared(
            weekId: week.id,
            uid: _uid,
          );
        }

        // Schedule Thursday reminder on each data load.
        await _notificationService.scheduleThursdayReminder(week, _languageCode);
      } else {
        _questions = [];
        _materials = [];
        _isPrepared = false;
      }
    } catch (e) {
      _errorMessage = 'Could not load Team BS data. Please try again.';
      debugPrint('[TeamState] loadData error: $e');
    }

    if (_disposed) return;
    _isLoading = false;
    _safeNotify();
  }

  // ── Member Actions ────────────────────────────────────────────────────────────

  Future<void> setLanguageCode(String code) async {
    _languageCode = code;
    if (_currentWeek != null) {
      await _notificationService.scheduleThursdayReminder(_currentWeek!, _languageCode);
    }
    _safeNotify();
  }

  /// Toggles the "prepared" status for the current user.
  Future<void> togglePrepared() async {
    if (_currentWeek == null || _uid == null) return;
    final next = !_isPrepared;
    _isPrepared = next;
    _safeNotify();
    try {
      await _repo.setUserPrepared(
        weekId: _currentWeek!.id,
        uid: _uid,
        prepared: next,
      );
    } catch (e) {
      // Rollback on error
      _isPrepared = !next;
      _errorMessage = 'Could not update preparation status.';
      _safeNotify();
      debugPrint('[TeamState] togglePrepared error: $e');
    }
  }

  // ── Admin Actions ─────────────────────────────────────────────────────────────

  /// Publishes (or updates) the study week. Admin only.
  Future<StudyWeek?> publishWeek(
    StudyWeek week, {
    bool isNewWeek = false,
  }) async {
    if (!_isAdmin || _uid == null) return null;
    try {
      final published = await _repo.publishWeek(
        week,
        updatedBy: _uid,
        isNewWeek: isNewWeek,
      );
      _currentWeek = published;
      // Reload questions and materials for new week.
      _questions = await _repo.getQuestions(
        published.id,
        onlyPublished: false,
      );
      _materials = await _repo.getMaterials(
        published.id,
        onlyPublished: false,
      );
      await _notificationService.scheduleThursdayReminder(published);
      _safeNotify();
      return published;
    } catch (e) {
      _errorMessage = 'Could not publish week.';
      _safeNotify();
      debugPrint('[TeamState] publishWeek error: $e');
      return null;
    }
  }

  /// Adds or updates a question. Admin only.
  Future<void> saveQuestion(Question question) async {
    if (!_isAdmin || _currentWeek == null) return;
    try {
      final saved = await _repo.saveQuestion(_currentWeek!.id, question);
      final idx = _questions.indexWhere((q) => q.id == saved.id);
      if (idx >= 0) {
        _questions[idx] = saved;
      } else {
        _questions = [..._questions, saved];
      }
      _safeNotify();
    } catch (e) {
      _errorMessage = 'Could not save question.';
      _safeNotify();
      debugPrint('[TeamState] saveQuestion error: $e');
    }
  }

  /// Deletes a question. Admin only.
  Future<void> deleteQuestion(String questionId) async {
    if (!_isAdmin || _currentWeek == null) return;
    try {
      await _repo.deleteQuestion(_currentWeek!.id, questionId);
      _questions = _questions.where((q) => q.id != questionId).toList();
      _safeNotify();
    } catch (e) {
      _errorMessage = 'Could not delete question.';
      _safeNotify();
      debugPrint('[TeamState] deleteQuestion error: $e');
    }
  }

  /// Reorders questions. Admin only.
  Future<void> reorderQuestions(int oldIndex, int newIndex) async {
    if (!_isAdmin || _currentWeek == null) return;
    if (oldIndex < 0 || oldIndex >= _questions.length) return;
    final list = [..._questions];
    final item = list.removeAt(oldIndex);
    final targetIndex = newIndex.clamp(0, list.length);
    list.insert(targetIndex, item);
    _questions = list;
    _safeNotify();
    try {
      await _repo.reorderQuestions(_currentWeek!.id, list);
    } catch (e) {
      debugPrint('[TeamState] reorderQuestions error: $e');
    }
  }

  /// Adds or updates a material item. Admin only.
  Future<void> saveMaterial(MaterialItem material) async {
    if (!_isAdmin || _currentWeek == null) return;
    try {
      final saved = await _repo.saveMaterial(_currentWeek!.id, material);
      final idx = _materials.indexWhere((m) => m.id == saved.id);
      if (idx >= 0) {
        _materials[idx] = saved;
      } else {
        _materials = [..._materials, saved];
      }
      _safeNotify();
    } catch (e) {
      _errorMessage = 'Could not save material.';
      _safeNotify();
      debugPrint('[TeamState] saveMaterial error: $e');
    }
  }

  /// Deletes a material item. Admin only.
  Future<void> deleteMaterial(String materialId) async {
    if (!_isAdmin || _currentWeek == null) return;
    try {
      await _repo.deleteMaterial(_currentWeek!.id, materialId);
      _materials = _materials.where((m) => m.id != materialId).toList();
      _safeNotify();
    } catch (e) {
      _errorMessage = 'Could not delete material.';
      _safeNotify();
      debugPrint('[TeamState] deleteMaterial error: $e');
    }
  }

  /// Sends a test notification to verify device notifications work. Admin only.
  Future<void> sendTestNotification() async {
    if (!_isAdmin) return;
    final week = _currentWeek;
    await _notificationService.sendTestNotification(
      title: 'Test: Thursday Reminder',
      body: week != null
          ? 'Friday study tomorrow: ${week.passageText} at ${week.sessionTime}, ${week.place}.'
          : 'Team BS notification test.',
    );
  }

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    _safeNotify();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
