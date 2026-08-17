import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'store.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UnApp());
}

class UnApp extends StatelessWidget {
  const UnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Un ishlab chiqarish texnologiyasi',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const _Bootstrap(),
    );
  }
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late final Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = appState.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashScreen();
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Ma’lumotlarni yuklashda xatolik:\n${snapshot.error}'),
              ),
            ),
          );
        }
        return AnimatedBuilder(
          animation: appState,
          builder: (context, _) {
            if (appState.name.isEmpty || !appState.diagnosticDone) {
              return const OnboardingScreen();
            }
            return const HomeShell();
          },
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grain, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'UN ISHLAB CHIQARISH\nTEXNOLOGIYASI',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.4,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 28),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
