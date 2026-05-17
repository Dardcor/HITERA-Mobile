import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../services/local_db_service.dart';
import '../services/sync_service.dart';
import '../utils/utils.dart';

class TugasProvider extends ChangeNotifier {
  List<Tugas> _tugas = [];
  bool _loading = true;
  final _uuid = const Uuid();
  StreamSubscription? _streamSubscription;

  List<Tugas> get tugas => _tugas;
  bool get loading => _loading;

  List<Tugas> get tugasAktif => _tugas.where((t) => t.status == 'aktif').toList();
  List<Tugas> get tugasSelesai => _tugas.where((t) => t.status == 'selesai').toList();

  int get progress =>
      _tugas.isEmpty ? 0 : (tugasSelesai.length * 100 ~/ _tugas.length);

  Future<void> fetch({bool skipLoading = false}) async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    
    if (_streamSubscription == null) {
      _streamSubscription = SupabaseService.client
          .from('tugas')
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
      // 1. Fetch from Local DB first
      final db = await LocalDbService.database;
      final localData = await db.query('tugas', where: 'user_id = ?', whereArgs: [user.id]);
      _tugas = localData.map((e) => Tugas(
        id: e['id'] as String,
        userId: e['user_id'] as String,
        judul: e['judul'] as String,
        deskripsi: e['deskripsi'] as String?,
        prioritas: e['prioritas'] as String,
        status: e['status'] as String,
        tanggalTarget: e['tanggal_target'] as String,
        deadline: e['deadline'] as String?,
        waktuDeadline: e['waktu_deadline'] as String?,
        tanggalSelesai: e['tanggal_selesai'] as String?,
        createdAt: e['created_at'] as String,
      )).toList();
      notifyListeners();

      // 2. Fetch from Supabase
      final remoteData = await SupabaseService.fetchAllTugas(user.id);
      
      // 3. Sync local DB with remote data
      final batch = db.batch();
      await db.delete('tugas', where: 'user_id = ?', whereArgs: [user.id]); // Clear local
      for (var t in remoteData) {
        batch.insert('tugas', {
          'id': t.id,
          'user_id': t.userId,
          'judul': t.judul,
          'deskripsi': t.deskripsi,
          'prioritas': t.prioritas,
          'status': t.status,
          'tanggal_target': t.tanggalTarget,
          'deadline': t.deadline,
          'waktu_deadline': t.waktuDeadline,
          'tanggal_selesai': t.tanggalSelesai,
          'created_at': t.createdAt,
        });
      }
      await batch.commit(noResult: true);
      
      _tugas = remoteData;
    } catch (_) {
      // If offline, Supabase fails, but we already loaded localData.
    }
    
    _loading = false;
    notifyListeners();
  }

  Future<String?> tambah({
    required String judul,
    String? deskripsi,
    required String prioritas,
    String? deadline,
    String? waktuDeadline,
  }) async {
    final user = SupabaseService.currentUser;
    if (user == null) return 'User tidak ditemukan';
    
    try {
      final id = _uuid.v4();
      final nowStr = DateTime.now().toUtc().toIso8601String();
      
      final payload = {
        'id': id,
        'user_id': user.id,
        'judul': judul,
        'deskripsi': deskripsi,
        'prioritas': prioritas,
        'status': 'aktif',
        'tanggal_target': hariIni(),
        'deadline': deadline,
        'waktu_deadline': waktuDeadline,
        'created_at': nowStr,
      };

      // Simpan lokal
      final db = await LocalDbService.database;
      await db.insert('tugas', payload);
      
      // Sync Queue
      await SyncService.enqueueSync('tugas', 'INSERT', id, payload);

      await fetch();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> toggleSelesai(String id, String currentStatus) async {
    if (id.trim().isEmpty || id == 'null' || id == 'undefined') {
      return 'ID tugas tidak valid';
    }
    try {
      final newStatus = currentStatus == 'aktif' ? 'selesai' : 'aktif';
      final payload = {'status': newStatus};
      
      // Simpan lokal
      final db = await LocalDbService.database;
      await db.update('tugas', payload, where: 'id = ?', whereArgs: [id]);
      
      // Sync Queue
      await SyncService.enqueueSync('tugas', 'UPDATE', id, payload);

      await fetch();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> hapus(String id) async {
    if (id.trim().isEmpty || id == 'null' || id == 'undefined') {
      return 'ID tugas tidak valid';
    }
    try {
      // Simpan lokal
      final db = await LocalDbService.database;
      await db.delete('tugas', where: 'id = ?', whereArgs: [id]);
      
      // Sync Queue
      await SyncService.enqueueSync('tugas', 'DELETE', id, null);

      await fetch();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
