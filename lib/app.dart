import 'dart:async';
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
import 'ui/ui.dart';

/// The root application widget configuring the Material 3 light theme
/// and routing based on authentication state.
class BibleStudyApp extends StatelessWidget {
  const BibleStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = AppColors.accent;
    const backgroundColor = AppColors.background;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ).copyWith(
      surface: backgroundColor,
      onSurface: AppColors.textPrimary,
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      surfaceContainer: Colors.white,
      error: AppColors.error,
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
        ).apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: AppTextStyles.title(),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.accent,
          labelStyle: AppTextStyles.caption(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: const BorderSide(color: AppColors.border),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: backgroundColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: AppTextStyles.button(),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accent,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.textPrimary,
          contentTextStyle: AppTextStyles.body(color: Colors.white),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          titleTextStyle: AppTextStyles.title(),
          contentTextStyle: AppTextStyles.body(),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.accentLight,
          elevation: 0,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.label(
                  color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 12);
            }
            return AppTextStyles.label(
                color: AppColors.textMuted, fontWeight: FontWeight.w500, fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.accent, size: 24);
            }
            return const IconThemeData(color: AppColors.textMuted, size: 24);
          }),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

/// Routes to SplashScreen at startup, then fades into LoginScreen, ForcePasswordChangeScreen, or AppShell.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _splashVisible = true;
  bool _minTimeElapsed = false;
  bool _hasTimedOut = false;
  Timer? _minTimer;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _startTimers();
  }

  void _startTimers() {
    _minTimer?.cancel();
    _timeoutTimer?.cancel();
    _minTimeElapsed = false;
    _hasTimedOut = false;

    _minTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _minTimeElapsed = true;
        });
      }
    });

    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && _splashVisible) {
        setState(() {
          _hasTimedOut = true;
        });
      }
    });
  }

  void _handleRetry() {
    setState(() {
      _hasTimedOut = false;
    });
    _startTimers();
    context.read<AuthState>().retryInit();
  }

  @override
  void dispose() {
    _minTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final localeState = Provider.of<LocaleState?>(context);
    if (authState.user != null && localeState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        localeState.syncWithUser(authState.user);
      });
    }

    if (_splashVisible && _minTimeElapsed && !authState.isLoading) {
      _splashVisible = false;
      _timeoutTimer?.cancel();
    }

    final Widget activeScreen;
    if (_splashVisible) {
      activeScreen = SplashScreen(
        key: const ValueKey('splash_screen'),
        showRetry: _hasTimedOut || (authState.errorMessage != null && !authState.isAuthenticated),
        errorMessage: _hasTimedOut ? authState.errorMessage : null,
        onRetry: _handleRetry,
      );
    } else if (authState.isLoading) {
      activeScreen = const Scaffold(
        key: ValueKey('auth_loading'),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    } else if (!authState.isAuthenticated) {
      activeScreen = const LoginScreen(key: ValueKey('login_screen'));
    } else if (authState.mustChangePassword) {
      activeScreen = const ForcePasswordChangeScreen(key: ValueKey('force_pw_screen'));
    } else {
      activeScreen = const AppShell(key: ValueKey('app_shell_screen'));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: activeScreen,
    );
  }
}

/// The main application shell hosting the bottom navigation bar with tabs.
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
      AppNavItem(
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        label: l10n.individualBs,
      ),
      AppNavItem(
        icon: Icons.group_outlined,
        selectedIcon: Icons.group,
        label: l10n.teamBs,
      ),
      AppNavItem(
        icon: Icons.menu_book_outlined,
        selectedIcon: Icons.menu_book,
        label: l10n.oldTestament,
      ),
      AppNavItem(
        icon: Icons.leaderboard_outlined,
        selectedIcon: Icons.leaderboard,
        label: l10n.leaderboard,
      ),
      if (isAdmin)
        AppNavItem(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: l10n.dashboard,
        ),
    ];

    final effectiveIndex = _currentIndex >= screens.length ? 0 : _currentIndex;

    return Scaffold(
      body: IndexedStack(
        index: effectiveIndex,
        children: screens,
      ),
      bottomNavigationBar: AppNavBar(
        selectedIndex: effectiveIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: destinations,
      ),
    );
  }
}
