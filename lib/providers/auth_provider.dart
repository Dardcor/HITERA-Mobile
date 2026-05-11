import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  Session? _session;
  bool _loading = true;
  StreamSubscription<AuthState>? _authSubscription;

  User? get user => _user;
  Session? get session => _session;
  bool get loading => _loading;
  bool get isAuthenticated => _user != null;

  String get userName {
    final meta = _user?.userMetadata;
    if (meta != null && meta['nama'] != null) return meta['nama'] as String;
    final email = _user?.email ?? '';
    return email.split('@').first;
  }

  AuthProvider() {
    _init();
  }

  void _init() {
    final client = SupabaseService.client;
    final currentSession = client.auth.currentSession;
    _session = currentSession;
    _user = currentSession?.user;
    _loading = false;
    notifyListeners();

    _authSubscription = client.auth.onAuthStateChange.listen((data) {
      _session = data.session;
      _user = data.session?.user;
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    _user = null;
    _session = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
