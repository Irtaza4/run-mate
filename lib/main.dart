import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_shell_screen.dart';
import 'screens/onboarding_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const RunMateApp());
}

class RunMateApp extends StatefulWidget {
  const RunMateApp({super.key});

  @override
  State<RunMateApp> createState() => _RunMateAppState();
}

class _RunMateAppState extends State<RunMateApp> {
  final AppState _appState = AppState();
  bool _hasCompletedOnboarding = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, child) {
        return MaterialApp(
          title: 'RunMate',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: _hasCompletedOnboarding
              ? MainShellScreen(state: _appState)
              : OnboardingScreen(
                  onFinish: () {
                    setState(() {
                      _hasCompletedOnboarding = true;
                    });
                  },
                ),
        );
      },
    );
  }
}
