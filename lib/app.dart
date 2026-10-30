import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/individual_screen.dart';
import 'screens/login_screen.dart';
import 'screens/placeholder_screen.dart';
import 'screens/team_screen.dart';
import 'services/notification_service.dart';
import 'state/auth_state.dart';


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

    return MaterialApp(
      title: 'Bible Study',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
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
    if (_notificationService?.selectedPayload.value == 'team_bs') {
      if (mounted) {
        setState(() {
          _currentIndex = 1;
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

  final List<Widget> _screens = const [
    IndividualScreen(),
    TeamScreen(),

    PlaceholderScreen(
      title: 'Old Testament',
      icon: Icons.menu_book_outlined,
      description: 'Old Testament topic plans curated by church leaders are coming soon.',
    ),
    PlaceholderScreen(
      title: 'Leaderboard',
      icon: Icons.leaderboard_outlined,
      description: 'Community reading streaks and team participation rankings are coming soon.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Individual BS',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Team BS',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Old Testament',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
        ],
      ),
    );
  }
}
