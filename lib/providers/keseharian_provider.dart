import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../utils/utils.dart';

class KeseharianProvider extends ChangeNotifier {
  List<KeseharianTodo> _todos = [];
  String _jurnal = '';
  bool _loading = true;
  bool _savingJurnal = false;
  String _tanggal = hariIni();
  Timer? _debounceTimer;

  List<KeseharianTodo> get todos => _todos;
  String get jurnal => _jurnal;
  bool get loading => _loading;
  bool get savingJurnal => _savingJurnal;
  String get tanggal => _tanggal;

  void setTanggal(String t) {
    _tanggal = t;
    fetch();
  }

  Future<void> fetch() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    _loading = true;
    notifyListeners();
    try {
      final todoData = await SupabaseService.fetchKeseharianTodos(user.id, _tanggal);
      _todos = todoData.map((e) => KeseharianTodo.fromJson(e)).toList();

      final jurnalContent = await SupabaseService.fetchKeseharianJurnal(user.id, _tanggal);
      _jurnal = jurnalContent ?? '';
    } catch (_) {
      _todos = [];
      _jurnal = '';
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> addTodo(String text) async {
    final user = SupabaseService.currentUser;
    if (user == null) return 'User tidak ditemukan';
    try {
      await SupabaseService.addKeseharianTodo({
        'user_id': user.id,
        'text': text,
        'date': _tanggal,
      });
      await fetch();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> toggleTodo(String id, bool currentStatus) async {
    try {
      await SupabaseService.toggleKeseharianTodo(id, currentStatus);
      await fetch();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteTodo(String id) async {
    try {
      await SupabaseService.deleteKeseharianTodo(id);
      await fetch();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Debounced journal save - matches website's 1.5s debounce
  void updateJurnal(String content) {
    _jurnal = content;
    notifyListeners();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      _saveJurnal(content);
    });
  }

  Future<void> _saveJurnal(String content) async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    _savingJurnal = true;
    notifyListeners();
    try {
      await SupabaseService.saveKeseharianJurnal(user.id, _tanggal, content);
    } catch (_) {
      // Silent fail like website
    }
    _savingJurnal = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
