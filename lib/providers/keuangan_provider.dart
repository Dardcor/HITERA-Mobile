import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../utils/utils.dart';

class KeuanganProvider extends ChangeNotifier {
  List<Transaksi> _transaksi = [];
  bool _loading = true;
  String _tanggal = hariIni();

  double _totalSaldo = 0;
  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;

  List<Map<String, dynamic>> _trendSaldo = [];

  List<Transaksi> get transaksi => _transaksi;
  bool get loading => _loading;
  String get tanggal => _tanggal;
  double get totalSaldo => _totalSaldo;
  double get totalPemasukan => _totalPemasukan;
  double get totalPengeluaran => _totalPengeluaran;
  List<Map<String, dynamic>> get trendSaldo => _trendSaldo;

  double get saldoBersih => _totalPemasukan - _totalPengeluaran;

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
      
      final allData = await SupabaseService.client
          .from('transaksi')
          .select('jenis, jumlah, tanggal')
          .eq('user_id', user.id);
      
      double pemasukan = 0;
      double pengeluaran = 0;
      Map<String, double> dailyChange = {};

      for (var t in allData as List) {
        double amt = (t['jumlah'] as num).toDouble();
        String date = t['tanggal'].toString();

        if (t['jenis'] == 'pemasukan') {
          pemasukan += amt;
          dailyChange[date] = (dailyChange[date] ?? 0) + amt;
        } else {
          pengeluaran += amt;
          dailyChange[date] = (dailyChange[date] ?? 0) - amt;
        }
      }
      _totalPemasukan = pemasukan;
      _totalPengeluaran = pengeluaran;
      _totalSaldo = pemasukan - pengeluaran;

      
      List<Map<String, dynamic>> trend = [];
      String today = hariIni();
      double currentBalance = _totalSaldo;
      
      for (int i = 0; i < 7; i++) {
        String currentDate = tambahHari(today, -i);
        trend.insert(0, {
          'tanggal': currentDate,
          'saldo': currentBalance,
        });
        double changeToday = dailyChange[currentDate] ?? 0;
        currentBalance -= changeToday;
      }
      _trendSaldo = trend;

      _transaksi = await SupabaseService.fetchTransaksi(user.id, _tanggal);
    } catch (_) {
      _transaksi = [];
      _trendSaldo = [];
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
