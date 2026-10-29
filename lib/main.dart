import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'repositories/auth_repository.dart';
import 'repositories/fake_auth_repository.dart';
import 'repositories/fake_study_repository.dart';
import 'repositories/firebase_auth_repository.dart';
import 'repositories/firebase_study_repository.dart';
import 'repositories/study_repository.dart';
import 'state/auth_state.dart';
import 'state/study_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    } catch (_) {
      // Persistence setting warning on specific platforms
    }
    isFirebaseReady = true;
  } catch (e) {
    debugPrint(
      'Firebase initialization fallback: Running with local repositories. '
      'Run "flutterfire configure" to connect to your live project.\nDetails: $e',
    );
  }

  // Use Firebase implementations if ready; fallback to in-memory fake repositories
  final AuthRepository authRepository = isFirebaseReady
      ? FirebaseAuthRepository()
      : FakeAuthRepository();

  final StudyRepository studyRepository = isFirebaseReady
      ? FirebaseStudyRepository()
      : FakeStudyRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<StudyRepository>.value(value: studyRepository),
        ChangeNotifierProvider<AuthState>(
          create: (_) => AuthState(authRepository: authRepository),
        ),
        ChangeNotifierProxyProvider<AuthState, StudyState>(
          create: (context) => StudyState(
            repository: studyRepository,
            uid: context.read<AuthState>().user?.uid,
            initialUser: context.read<AuthState>().user,
          ),
          update: (context, authState, studyState) {
            if (studyState == null) {
              return StudyState(
                repository: studyRepository,
                uid: authState.user?.uid,
                initialUser: authState.user,
              );
            }
            if (studyState.uid != authState.user?.uid) {
              studyState.setUser(authState.user);
            }
            return studyState;
          },
        ),
      ],
      child: const BibleStudyApp(),
    ),
  );
}
