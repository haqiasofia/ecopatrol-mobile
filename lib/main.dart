import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/session_provider.dart';
import 'screens/login_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/add_report_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: EcoPatrolApp()));
}

class EcoPatrolApp extends ConsumerWidget {
  const EcoPatrolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(sessionProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoPatrol',
      theme: ThemeData(primarySwatch: Colors.green),
      home: isLoggedIn ? const SettingsScreen() : const LoginScreen(),

    );
  }
}
