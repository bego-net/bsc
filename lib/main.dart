import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'repositories/auth_repository.dart';
import 'repositories/fake_auth_repository.dart';
import 'repositories/fake_study_repository.dart';
import 'repositories/fake_team_repository.dart';
import 'repositories/firebase_auth_repository.dart';
import 'repositories/firebase_study_repository.dart';
import 'repositories/firebase_team_repository.dart';
import 'repositories/study_repository.dart';
import 'repositories/team_repository.dart';
import 'services/fake_notification_service.dart';
import 'services/local_notification_service.dart';
import 'services/notification_service.dart';
import 'state/auth_state.dart';
import 'state/study_state.dart';
import 'state/team_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseReady = false;
  if (DefaultFirebaseOptions.isConfigured) {
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
  } else {
    debugPrint(
      'Notice: Running in offline development mode with mock repositories.\n'
      'Run "flutterfire configure" to connect to your live Firebase project.',
    );
  }

  // Use Firebase implementations if ready; fallback to in-memory fake repositories
  final AuthRepository authRepository;
  if (isFirebaseReady) {
    authRepository = FirebaseAuthRepository();
  } else {
    final fakeAuth = FakeAuthRepository();
    fakeAuth.seedUser(
      name: 'Test Member',
      email: 'test@example.com',
      password: 'password123',
    );
    authRepository = fakeAuth;
  }

  final StudyRepository studyRepository = isFirebaseReady
      ? FirebaseStudyRepository()
      : FakeStudyRepository();

  final TeamRepository teamRepository = isFirebaseReady
      ? FirebaseTeamRepository()
      : FakeTeamRepository();

  // Initialize notification service.
  // NOTE: flutter_local_notifications does NOT work on web (Chrome).
  // FakeNotificationService is used in offline mode or tests.
  final NotificationService notificationService;
  if (isFirebaseReady) {
    notificationService = LocalNotificationService();
    await notificationService.initialize();
  } else {
    notificationService = FakeNotificationService();
    await notificationService.initialize();
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<StudyRepository>.value(value: studyRepository),
        Provider<TeamRepository>.value(value: teamRepository),
        Provider<NotificationService>.value(value: notificationService),
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
        ChangeNotifierProxyProvider<AuthState, TeamState>(
          create: (context) {
            final auth = context.read<AuthState>();
            return TeamState(
              repository: teamRepository,
              uid: auth.user?.uid,
              isAdmin: auth.isAdmin,
              notificationService: notificationService,
            );
          },
          update: (context, authState, teamState) {
            if (teamState == null) {
              return TeamState(
                repository: teamRepository,
                uid: authState.user?.uid,
                isAdmin: authState.isAdmin,
                notificationService: notificationService,
              );
            }
            // If user changes (login/logout), return a fresh TeamState.
            if (teamState.uid != authState.user?.uid) {
              return TeamState(
                repository: teamRepository,
                uid: authState.user?.uid,
                isAdmin: authState.isAdmin,
                notificationService: notificationService,
              );
            }
            return teamState;
          },
        ),
      ],
      child: const BibleStudyApp(),
    ),
  );
}
