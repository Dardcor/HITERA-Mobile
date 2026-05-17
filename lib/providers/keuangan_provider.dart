import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../services/local_db_service.dart';
import '../services/sync_service.dart';
import '../utils/utils.dart';

class KeuanganProvider extends ChangeNotifier {
  List<Transaksi> _transaksi = [];
  bool _loading = true;
  String _tanggal = hariIni();
  final _uuid = const Uuid();
  StreamSubscription? _streamSubscription;

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

  Future<void> fetch({bool skipLoading = false}) async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    
    if (_streamSubscription == null) {
      _streamSubscription = SupabaseService.client
          .from('transaksi')
          .stream(primaryKey: ['id'])
          .eq('user_id', user.id)
          .listen((_) {
        fetch(skipLoading: true);
      });
    }

    if (!skipLoading) {
      _loading = true;
      notifyListeners();
    }
    
    try {
      // Fetch dari lokal sebagai backup cepat
      final db = await LocalDbService.database;
      final localAllData = await db.query('keuangan', where: 'user_id = ?', whereArgs: [user.id]);
      
      _hitungTrend(localAllData);
      
      final localTransaksi = await db.query('keuangan', where: 'user_id = ? AND tanggal = ?', whereArgs: [user.id, _tanggal]);
      _transaksi = localTransaksi.map((e) => Transaksi(
        id: e['id'] as String,
        userId: e['user_id'] as String,
        jenis: e['jenis'] as String,
        jumlah: (e['jumlah'] as num).toDouble(),
        kategori: e['kategori'] as String,
        deskripsi: e['deskripsi'] as String?,
        tanggal: e['tanggal'] as String,
        createdAt: e['created_at'] as String,
      )).toList();
      notifyListeners();

      // Sinkronisasi dari Supabase
      final allData = await SupabaseService.client
          .from('transaksi')
          .select('id, user_id, jenis, jumlah, kategori, deskripsi, tanggal, created_at')
          .eq('user_id', user.id);
      
      // Update lokal dengan data Supabase
      final batch = db.batch();
      await db.delete('keuangan', where: 'user_id = ?', whereArgs: [user.id]);
      for (var t in allData as List) {
        batch.insert('keuangan', t);
      }
      await batch.commit(noResult: true);

      _hitungTrend(allData);
      _transaksi = await SupabaseService.fetchTransaksi(user.id, _tanggal);
    } catch (_) {
      // Fallback ke data lokal yang sudah dihitung
    }
    
    _loading = false;
    notifyListeners();
  }

  void _hitungTrend(List<dynamic> allData) {
    double pemasukan = 0;
    double pengeluaran = 0;
    Map<String, double> dailyChange = {};

    for (var t in allData) {
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
      final id = _uuid.v4();
      final nowStr = DateTime.now().toUtc().toIso8601String();
      
      final payload = {
        'id': id,
        'user_id': user.id,
        'jenis': jenis,
        'jumlah': jumlah,
        'kategori': kategori,
        'deskripsi': deskripsi,
        'tanggal': tanggal,
        'created_at': nowStr,
      };

      // Simpan lokal
      final db = await LocalDbService.database;
      await db.insert('keuangan', payload);
      
      // Sync Queue
      await SyncService.enqueueSync('transaksi', 'INSERT', id, payload);

      await fetch();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> hapus(String id) async {
    if (id.trim().isEmpty || id == 'null' || id == 'undefined') {
      return 'ID transaksi tidak valid';
    }
    try {
      // Simpan lokal
      final db = await LocalDbService.database;
      await db.delete('keuangan', where: 'id = ?', whereArgs: [id]);
      
      // Sync Queue
      await SyncService.enqueueSync('transaksi', 'DELETE', id, null);

      await fetch();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
