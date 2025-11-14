import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/goals/goals_input_screen.dart';
import 'screens/goals/prioritization_screen.dart';
import 'screens/goals/lockdown_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
  AppScreen _currentScreen = AppScreen.onboarding;
  List<String> _userGoals = [];
  List<String> _rankedGoals = [];

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

  void _onPrioritizationComplete(List<String> rankedGoals) {
    setState(() {
      _rankedGoals = rankedGoals;
      _currentScreen = AppScreen.lockdown;
    });
  }

  void _onLockdownComplete() {
    setState(() {
      _currentScreen = AppScreen.dashboard;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentScreen) {
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
  onboarding,
  goalsInput,
  prioritization,
  lockdown,
  dashboard,
}
