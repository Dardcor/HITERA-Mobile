import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../utils/utils.dart';

class KeuanganProvider extends ChangeNotifier {
  List<Transaksi> _transaksi = [];
  bool _loading = true;
  String _tanggal = hariIni();

  double _totalSaldo = 0;

  List<Transaksi> get transaksi => _transaksi;
  bool get loading => _loading;
  String get tanggal => _tanggal;
  double get totalSaldo => _totalSaldo;

  double get totalPemasukan => _transaksi
      .where((t) => t.jenis == 'pemasukan')
      .fold(0, (sum, t) => sum + t.jumlah);

  double get totalPengeluaran => _transaksi
      .where((t) => t.jenis == 'pengeluaran')
      .fold(0, (sum, t) => sum + t.jumlah);

  double get saldoBersih => totalPemasukan - totalPengeluaran;

  void setTanggal(String t) {
    _tanggal = t;
    fetch();
  }

  void prevDay() => setTanggal(tambahHari(_tanggal, -1));
  void nextDay() => setTanggal(tambahHari(_tanggal, 1));
  void resetToToday() => setTanggal(hariIni());

  Future<void> fetch() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    _loading = true;
    notifyListeners();
    try {
      // Fetch cumulative transactions for total balance
      final allData = await SupabaseService.client
          .from('transaksi')
          .select('jenis, jumlah')
          .eq('user_id', user.id);
      
      _totalSaldo = (allData as List).fold(0.0, (sum, t) {
        return t['jenis'] == 'pemasukan' ? sum + t['jumlah'] : sum - t['jumlah'];
      });

      _transaksi = await SupabaseService.fetchTransaksi(user.id, _tanggal);
    } catch (_) {
      _transaksi = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> tambah({
    required String jenis,
    required double jumlah,
    required String kategori,
    String? deskripsi,
    required String tanggal,
  }) async {
    final user = SupabaseService.currentUser;
    if (user == null) return 'User tidak ditemukan';
    try {
      await SupabaseService.tambahTransaksi({
        'user_id': user.id,
        'jenis': jenis,
        'jumlah': jumlah,
        'kategori': kategori,
        'deskripsi': deskripsi,
        'tanggal': tanggal,
      });
      await fetch();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> hapus(String id) async {
    try {
      await SupabaseService.hapusTransaksi(id);
      await fetch();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
