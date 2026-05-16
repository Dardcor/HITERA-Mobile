import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../utils/utils.dart';

class KesehatanProvider extends ChangeNotifier {
  DataKesehatan? _data;
  bool _loading = true;
  String _tanggal = hariIni();

  DataKesehatan? get data => _data;
  bool get loading => _loading;
  String get tanggal => _tanggal;

  void setTanggal(String t) {
    _tanggal = t;
    fetch();
  }

  void prevDay() => setTanggal(tambahHari(_tanggal, -1));
  void nextDay() => setTanggal(tambahHari(_tanggal, 1));

  Future<void> fetch() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    _loading = true;
    notifyListeners();
    try {
      _data = await SupabaseService.fetchKesehatan(user.id, _tanggal);
    } catch (_) {
      _data = null;
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> simpan({
    required int? airMinum,
    required double? jamTidur,
    required String? catatan,
    int? olahragaJam,
    int? olahragaMenit,
  }) async {
    final user = SupabaseService.currentUser;
    if (user == null) return 'User tidak ditemukan';
    try {
      await SupabaseService.simpanKesehatan({
        'user_id': user.id,
        'tanggal': _tanggal,
        'air_minum': airMinum,
        'jam_tidur': jamTidur,
        'catatan': catatan,
        'olahraga_jam': olahragaJam ?? 0,
        'olahraga_menit': olahragaMenit ?? 0,
      });
      await fetch();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
