import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/session_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: EcoPatrolApp()));
}

class EcoPatrolApp extends ConsumerStatefulWidget {
  const EcoPatrolApp({super.key});

  @override
  ConsumerState<EcoPatrolApp> createState() => _EcoPatrolAppState();
}

class _EcoPatrolAppState extends ConsumerState<EcoPatrolApp> {
  @override
  void initState() {
    super.initState();
    ref.read(sessionProvider.notifier).loadSession();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(sessionProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoPatrol',
      theme: ThemeData(primarySwatch: Colors.green),
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
