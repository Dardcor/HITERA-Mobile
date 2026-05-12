import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../utils/utils.dart';

class TugasProvider extends ChangeNotifier {
  List<Tugas> _tugas = [];
  bool _loading = true;
  String _tanggal = hariIni();

  List<Tugas> get tugas => _tugas;
  bool get loading => _loading;
  String get tanggal => _tanggal;

  List<Tugas> get tugasAktif => _tugas.where((t) => t.status == 'aktif').toList();
  List<Tugas> get tugasSelesai => _tugas.where((t) => t.status == 'selesai').toList();

  int get progress =>
      _tugas.isEmpty ? 0 : (tugasSelesai.length * 100 ~/ _tugas.length);

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
      _tugas = await SupabaseService.fetchTugas(user.id, _tanggal);
    } catch (_) {
      _tugas = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> tambah({
    required String judul,
    String? deskripsi,
    required String prioritas,
    String? deadline,
  }) async {
    final user = SupabaseService.currentUser;
    if (user == null) return 'User tidak ditemukan';
    try {
      await SupabaseService.addTugas({
        'user_id': user.id,
        'judul': judul,
        'deskripsi': deskripsi,
        'prioritas': prioritas,
        'status': 'aktif',
        'tanggal_target': _tanggal,
        'deadline': deadline,
      });
      await fetch();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> toggleSelesai(String id, String currentStatus) async {
    try {
      await SupabaseService.toggleTugasStatus(id, currentStatus);
      await fetch();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> hapus(String id) async {
    try {
      await SupabaseService.deleteTugas(id);
      await fetch();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
