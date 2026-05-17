import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../services/local_db_service.dart';
import '../services/sync_service.dart';
import '../utils/utils.dart';

class KesehatanProvider extends ChangeNotifier {
  DataKesehatan? _data;
  bool _loading = true;
  String _tanggal = hariIni();
  final _uuid = const Uuid();
  StreamSubscription? _streamSubscription;

  DataKesehatan? get data => _data;
  bool get loading => _loading;
  String get tanggal => _tanggal;

  void setTanggal(String t) {
    _tanggal = t;
    fetch();
  }

  void prevDay() => setTanggal(tambahHari(_tanggal, -1));
  void nextDay() => setTanggal(tambahHari(_tanggal, 1));

  Future<void> fetch({bool skipLoading = false}) async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    
    if (_streamSubscription == null) {
      _streamSubscription = SupabaseService.client
          .from('kesehatan')
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
      final localData = await db.query('kesehatan', where: 'user_id = ? AND tanggal = ?', whereArgs: [user.id, _tanggal]);
      if (localData.isNotEmpty) {
        final e = localData.first;
        _data = DataKesehatan(
          id: e['id'] as String,
          userId: e['user_id'] as String,
          tanggal: e['tanggal'] as String,
          airMinum: e['air_minum'] as int?,
          jamTidur: (e['jam_tidur'] as num?)?.toDouble(),
          catatan: e['catatan'] as String?,
          olahragaJam: e['olahraga_jam'] as int?,
          olahragaMenit: e['olahraga_menit'] as int?,
          createdAt: e['created_at'] as String,
        );
        notifyListeners();
      } else {
        _data = null;
      }

      // 2. Fetch from Supabase
      final remoteData = await SupabaseService.fetchKesehatan(user.id, _tanggal);
      
      // 3. Sync local DB with remote data
      if (remoteData != null) {
        final batch = db.batch();
        await db.delete('kesehatan', where: 'user_id = ? AND tanggal = ?', whereArgs: [user.id, _tanggal]);
        batch.insert('kesehatan', {
          'id': remoteData.id,
          'user_id': remoteData.userId,
          'tanggal': remoteData.tanggal,
          'air_minum': remoteData.airMinum,
          'jam_tidur': remoteData.jamTidur,
          'catatan': remoteData.catatan,
          'olahraga_jam': remoteData.olahragaJam,
          'olahraga_menit': remoteData.olahragaMenit,
          'created_at': remoteData.createdAt,
        });
        await batch.commit(noResult: true);
        _data = remoteData;
      }
    } catch (_) {
      // If offline, Supabase fails, but we already loaded localData.
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
      final payload = {
        'user_id': user.id,
        'tanggal': _tanggal,
        'air_minum': airMinum,
        'jam_tidur': jamTidur,
        'catatan': catatan,
        'olahraga_jam': olahragaJam ?? 0,
        'olahraga_menit': olahragaMenit ?? 0,
      };

      final db = await LocalDbService.database;
      final existing = await db.query('kesehatan', where: 'user_id = ? AND tanggal = ?', whereArgs: [user.id, _tanggal]);
      
      String targetId;
      if (existing.isNotEmpty) {
        targetId = existing.first['id'] as String;
        await db.update('kesehatan', payload, where: 'id = ?', whereArgs: [targetId]);
        await SyncService.enqueueSync('kesehatan', 'UPDATE', targetId, payload);
      } else {
        targetId = _uuid.v4();
        payload['id'] = targetId;
        payload['created_at'] = DateTime.now().toUtc().toIso8601String();
        await db.insert('kesehatan', payload);
        await SyncService.enqueueSync('kesehatan', 'INSERT', targetId, payload);
      }

      await fetch();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
