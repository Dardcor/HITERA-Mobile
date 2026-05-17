import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'local_db_service.dart';
import 'supabase_service.dart';

class SyncService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static bool _isSyncing = false;

  static Future<void> enqueueSync(String tableName, String operation, String dataId, Map<String, dynamic>? dataPayload) async {
    final db = await LocalDbService.database;
    await db.insert('sync_queue', {
      'table_name': tableName,
      'operation': operation,
      'data_id': dataId,
      'data_payload': dataPayload != null ? jsonEncode(dataPayload) : null,
    });
    
    // Attempt sync immediately
    syncNow();
  }

  static void _showSyncToast(String message) {
    if (scaffoldMessengerKey.currentState != null) {
      scaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(message),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<void> syncNow() async {
    if (_isSyncing) return;
    
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) return; // Offline

    final db = await LocalDbService.database;
    final queue = await db.query('sync_queue', orderBy: 'created_at ASC');
    
    if (queue.isEmpty) return;

    _isSyncing = true;
    _showSyncToast('Sedang sinkronisasi...');

    for (var item in queue) {
      try {
        final id = item['id'] as int;
        final tableName = item['table_name'] as String;
        final operation = item['operation'] as String;
        final dataId = item['data_id'] as String;
        final dataPayloadStr = item['data_payload'] as String?;
        final dataPayload = dataPayloadStr != null ? jsonDecode(dataPayloadStr) as Map<String, dynamic> : null;

        if (dataId.trim().isEmpty || dataId == 'null' || dataId == 'undefined') {
          // Safety guard: skip invalid sync operations and delete from queue
          await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
          continue;
        }

        if (operation == 'INSERT' || operation == 'UPDATE') {
          // Check if exists
          final existing = await SupabaseService.client.from(tableName).select('id').eq('id', dataId).maybeSingle();
          if (existing == null && dataPayload != null) {
            await SupabaseService.client.from(tableName).insert(dataPayload);
          } else if (existing != null && dataPayload != null) {
            await SupabaseService.client.from(tableName).update(dataPayload).eq('id', dataId);
          }
        } else if (operation == 'DELETE') {
          await SupabaseService.client.from(tableName).delete().eq('id', dataId);
        }

        // Remove from queue after success
        await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
      } catch (e) {
        // Stop syncing on error, retry later
        break;
      }
    }

    _isSyncing = false;
  }
}
