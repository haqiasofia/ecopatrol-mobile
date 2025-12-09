import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionNotifier extends StateNotifier<bool> {
  SessionNotifier() : super(false);

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool("isLoggedIn") ?? false;
  }

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", true);
    state = true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);
    state = false;
  }
}

final sessionProvider =
StateNotifierProvider<SessionNotifier, bool>((ref) => SessionNotifier());
