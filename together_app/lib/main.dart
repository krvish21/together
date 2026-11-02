import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'providers/together_state.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = TogetherState();
  await state.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<TogetherState>.value(value: state),
      ],
      child: const TogetherApp(),
    ),
  );
}

class TogetherApp extends StatelessWidget {
  const TogetherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TogetherState>(context);

    return MaterialApp(
      title: 'Together',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: state.isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryRose),
              ),
            )
          : (state.couple != null ? const MainScreen() : const WelcomeScreen()),
    );
  }
}
