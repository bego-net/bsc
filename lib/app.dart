import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/admin/dashboard_screen.dart';
import 'screens/force_password_change_screen.dart';
import 'screens/individual_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/old_testament_screen.dart';
import 'screens/team_screen.dart';
import 'services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l10n/app_localizations.dart';
import 'state/auth_state.dart';
import 'state/locale_state.dart';


/// The root application widget configuring the Material 3 light theme
/// and routing based on authentication state.
class BibleStudyApp extends StatelessWidget {
  const BibleStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF2F6F5E);
    const backgroundColor = Color(0xFFF4F1EA);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ).copyWith(
      surface: backgroundColor,
    );

    final localeState = Provider.of<LocaleState?>(context);

    return MaterialApp(
      title: 'Bible Study',
      debugShowCheckedModeBanner: false,
      locale: localeState?.locale ?? const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: GoogleFonts.notoSansEthiopicTextTheme(
          ThemeData(useMaterial3: true, colorScheme: colorScheme).textTheme,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: seedColor.withValues(alpha: 0.15),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

/// Routes to LoginScreen if unauthenticated, or AppShell if signed in.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final localeState = Provider.of<LocaleState?>(context);
    if (authState.user != null && localeState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        localeState.syncWithUser(authState.user);
      });
    }

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!authState.isAuthenticated) {
      return const LoginScreen();
    }

    if (authState.mustChangePassword) {
      return const ForcePasswordChangeScreen();
    }

    return const AppShell();
  }
}

/// The main application shell hosting the bottom navigation bar with 4 tabs.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  NotificationService? _notificationService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _notificationService = context.read<NotificationService>();
        _notificationService?.selectedPayload.addListener(_handleNotificationPayload);
        _handleNotificationPayload();
      }
    });
  }

  void _handleNotificationPayload() {
    final payload = _notificationService?.selectedPayload.value;
    if (payload == 'team_bs') {
      if (mounted) {
        setState(() {
          _currentIndex = 1;
        });
      }
      _notificationService?.selectedPayload.value = null;
    } else if (payload == 'old_testament') {
      if (mounted) {
        setState(() {
          _currentIndex = 2;
        });
      }
      _notificationService?.selectedPayload.value = null;
    }
  }

  @override
  void dispose() {
    _notificationService?.selectedPayload.removeListener(_handleNotificationPayload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthState>().isAdmin;

    final screens = [
      const IndividualScreen(),
      const TeamScreen(),
      const OldTestamentScreen(),
      const LeaderboardScreen(),
      if (isAdmin) const DashboardScreen(),
    ];

    final l10n = AppLocalizations.of(context)!;
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: l10n.individualBs,
      ),
      NavigationDestination(
        icon: const Icon(Icons.group_outlined),
        selectedIcon: const Icon(Icons.group),
        label: l10n.teamBs,
      ),
      NavigationDestination(
        icon: const Icon(Icons.menu_book_outlined),
        selectedIcon: const Icon(Icons.menu_book),
        label: l10n.oldTestament,
      ),
      NavigationDestination(
        icon: const Icon(Icons.leaderboard_outlined),
        selectedIcon: const Icon(Icons.leaderboard),
        label: l10n.leaderboard,
      ),
      if (isAdmin)
        NavigationDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: const Icon(Icons.dashboard),
          label: l10n.dashboard,
        ),
    ];

    final effectiveIndex = _currentIndex >= screens.length ? 0 : _currentIndex;

    return Scaffold(
      body: IndexedStack(
        index: effectiveIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: effectiveIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: destinations,
      ),
    );
  }
}
