import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import 'ot_state.dart';
import 'team_state.dart';

/// Key used in [SharedPreferences] to store preferred language ('am' or 'en').
const String kPrefLanguageKey = 'preferred_language';

/// Manages application-wide language/locale selection, persistence,
/// and re-scheduling of notifications.
class LocaleState extends ChangeNotifier {
  Locale _locale = const Locale('am');
  bool _initialized = false;

  LocaleState() {
    _loadFromPrefs();
  }

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isAmharic => _locale.languageCode == 'am';
  bool get isInitialized => _initialized;

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(kPrefLanguageKey);
      if (saved == 'en' || saved == 'am') {
        _locale = Locale(saved!);
      } else {
        _locale = const Locale('am');
      }
    } catch (_) {
      _locale = const Locale('am');
    }
    _initialized = true;
    notifyListeners();
  }

  /// Syncs with the user's remote profile language preference if available.
  void syncWithUser(AppUser? user) {
    if (user != null && user.language.isNotEmpty) {
      if (user.language != _locale.languageCode &&
          (user.language == 'am' || user.language == 'en')) {
        _locale = Locale(user.language);
        notifyListeners();
        SharedPreferences.getInstance().then((p) {
          p.setString(kPrefLanguageKey, user.language);
        });
      }
    }
  }

  /// Changes language to [code] ('am' or 'en').
  /// Applies immediately, saves to device [SharedPreferences],
  /// updates Firestore if signed in, and re-schedules active notifications.
  Future<void> setLanguage(
    String code, {
    AppUser? user,
    AuthRepository? authRepo,
    TeamState? teamState,
    OtState? otState,
  }) async {
    if (code != 'am' && code != 'en') return;
    if (_locale.languageCode == code) return;

    _locale = Locale(code);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kPrefLanguageKey, code);
    } catch (e) {
      debugPrint('[LocaleState] Error saving to prefs: $e');
    }

    if (user != null && authRepo != null) {
      try {
        await authRepo.updateLanguage(code);
      } catch (e) {
        debugPrint('[LocaleState] Error updating user profile: $e');
      }
    }

    if (teamState != null) {
      await teamState.setLanguageCode(code);
    }
    if (otState != null) {
      await otState.setLanguageCode(code);
    }
  }
}
