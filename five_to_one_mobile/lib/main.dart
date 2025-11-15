import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/goals/goals_input_screen.dart';
import 'screens/goals/prioritization_screen.dart';
import 'screens/goals/lockdown_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'services/supabase_service.dart';
import 'services/items_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    await SupabaseService.initialize();
  } catch (e) {
    print('Supabase initialization error: $e');
    print('Make sure to configure lib/config/supabase_config.dart');
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const FiveToOneApp());
  });
}

class FiveToOneApp extends StatelessWidget {
  const FiveToOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Five to One',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppFlowManager(),
    );
  }
}

// Manages the entire app flow
class AppFlowManager extends StatefulWidget {
  const AppFlowManager({super.key});

  @override
  State<AppFlowManager> createState() => _AppFlowManagerState();
}

class _AppFlowManagerState extends State<AppFlowManager> {
  AppScreen _currentScreen = AppScreen.loading;
  List<String> _userGoals = [];
  List<String> _rankedGoals = [];
  final _itemsService = ItemsService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
  }

  Future<void> _checkAuthAndLoadData() async {
    // Check if user is logged in
    if (!SupabaseService.isLoggedIn) {
      setState(() {
        _currentScreen = AppScreen.auth;
      });
      return;
    }

    // User is logged in - check if they have goals
    try {
      final goals = await _itemsService.getTopFiveGoals();

      if (goals.isEmpty) {
        // No goals yet - show onboarding
        setState(() {
          _currentScreen = AppScreen.onboarding;
        });
      } else {
        // Has goals - show dashboard
        setState(() {
          _rankedGoals = goals.map((g) => g.title).toList();
          _currentScreen = AppScreen.dashboard;
        });
      }
    } catch (e) {
      print('Error loading goals: $e');
      // If error, assume no goals and show onboarding
      setState(() {
        _currentScreen = AppScreen.onboarding;
      });
    }
  }

  void _onAuthenticated() {
    _checkAuthAndLoadData();
  }

  void _onOnboardingComplete() {
    setState(() {
      _currentScreen = AppScreen.goalsInput;
    });
  }

  void _onGoalsInputComplete(List<String> goals) {
    setState(() {
      _userGoals = goals;
      _currentScreen = AppScreen.prioritization;
    });
  }

  Future<void> _onPrioritizationComplete(List<String> rankedGoals) async {
    setState(() {
      _rankedGoals = rankedGoals;
      _currentScreen = AppScreen.lockdown;
    });

    // Save goals to Supabase
    try {
      await _itemsService.saveGoals(rankedGoals);
    } catch (e) {
      print('Error saving goals: $e');
    }
  }

  void _onLockdownComplete() {
    setState(() {
      _currentScreen = AppScreen.dashboard;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentScreen) {
      case AppScreen.loading:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );

      case AppScreen.auth:
        return AuthScreen(onAuthenticated: _onAuthenticated);

      case AppScreen.onboarding:
        return OnboardingFlow(onComplete: _onOnboardingComplete);

      case AppScreen.goalsInput:
        return GoalsInputScreen(onComplete: _onGoalsInputComplete);

      case AppScreen.prioritization:
        return PrioritizationScreen(
          goals: _userGoals,
          onComplete: _onPrioritizationComplete,
        );

      case AppScreen.lockdown:
        final topFive = _rankedGoals.take(5).toList();
        final avoidList = _rankedGoals.length > 5
            ? _rankedGoals.skip(5).toList()
            : <String>[];

        return LockdownScreen(
          topFive: topFive,
          avoidList: avoidList,
          onComplete: _onLockdownComplete,
        );

      case AppScreen.dashboard:
        final topFive = _rankedGoals.take(5).toList();
        return DashboardScreen(topFiveGoals: topFive);
    }
  }
}

enum AppScreen {
  loading,
  auth,
  onboarding,
  goalsInput,
  prioritization,
  lockdown,
  dashboard,
}
