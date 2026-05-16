import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../utils/utils.dart';

class KeseharianProvider extends ChangeNotifier {
  List<KeseharianTodo> _todos = [];
  bool _loading = true;
  String _tanggal = hariIni();

  List<KeseharianTodo> get todos => _todos;
  bool get loading => _loading;
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
    } catch (_) {
      _todos = [];
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


}
