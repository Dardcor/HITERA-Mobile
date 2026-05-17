import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'supabase_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(settings: initSettings);
    await requestPermissions();
  }

  static Future<void> requestPermissions() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(time),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'hitera_reminders',
          'Pengingat Hitera',
          channelDescription: 'Notifikasi pengingat harian aplikasi Hitera',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> scheduleRepeatingSpam(int id, String title, String body) async {
    await _notificationsPlugin.periodicallyShow(
      id: id,
      title: title,
      body: body,
      repeatInterval: RepeatInterval.everyMinute, 
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'hitera_spam',
          'Peringatan Deadline',
          channelDescription: 'Peringatan tugas yang hampir melewati deadline',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> stopSpam(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  static Future<void> generateDailyHistoryAndSpam(String userId, Map<String, dynamic> settings, List<dynamic> activeTasks) async {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    Future<void> checkAndInsert(String tipe, String pesan, bool enabled, String? timeStr) async {
      if (!enabled || timeStr == null) return;
      final parts = timeStr.split(':');
      if (parts.length != 2) return;
      final hour = int.tryParse(parts[0]) ?? 0;
      final min = int.tryParse(parts[1]) ?? 0;
      
      if (now.hour > hour || (now.hour == hour && now.minute >= min)) {
        
        try {
          final res = await SupabaseService.client
              .from('notifikasi_history')
              .select('id')
              .eq('user_id', userId)
              .eq('tipe', tipe)
              .gte('created_at', '${todayStr}T00:00:00Z')
              .maybeSingle();
          
          if (res == null) {
            await SupabaseService.client.from('notifikasi_history').insert({
              'user_id': userId,
              'tipe': tipe,
              'pesan': pesan,
            });
          }
        } catch (_) {}
      }
    }

    await checkAndInsert('keuangan', 'Apakah anda sudah mencatat pengeluaran atau pemasukkan hari ini?', settings['keuangan_notif_enabled'] ?? false, settings['keuangan_notif_time']);
    await checkAndInsert('kesehatan', 'Apakah anda sudah mencatat kesehatan anda hari ini?', settings['kesehatan_notif_enabled'] ?? false, settings['kesehatan_notif_time']);
    await checkAndInsert('tugas', 'Apakah hari ini ada tugas?', settings['tugas_notif_enabled'] ?? false, settings['tugas_notif_time']);

    
    for (var task in activeTasks) {
      if (task.deadline == todayStr) {
        bool isMendekati = false;
        if (task.waktuDeadline != null) {
          final parts = task.waktuDeadline!.split(':');
          if (parts.length == 2) {
            final h = int.tryParse(parts[0]) ?? 0;
            final m = int.tryParse(parts[1]) ?? 0;
            final taskTime = DateTime(now.year, now.month, now.day, h, m);
            final diff = taskTime.difference(now);
            if (diff.inMinutes <= 60 && diff.inMinutes >= -60) {
              isMendekati = true;
            }
          }
        } else {
          isMendekati = true;
        }

        if (isMendekati) {
          final spamId = 9999 + task.id.hashCode % 10000;
          
          try {
            final res = await SupabaseService.client
                .from('notifikasi_history')
                .select('id')
                .eq('user_id', userId)
                .eq('tipe', 'deadline')
                .like('pesan', '%${task.judul}%')
                .gte('created_at', '${todayStr}T00:00:00Z')
                .maybeSingle();
                
            if (res == null) {
              await SupabaseService.client.from('notifikasi_history').insert({
                'user_id': userId,
                'tipe': 'deadline',
                'pesan': 'Tugas "${task.judul}" harus selesai hari ini! Segera kerjakan.',
              });
              await scheduleRepeatingSpam(spamId, 'Deadline Tugas!', 'Tugas "${task.judul}" deadline hari ini${task.waktuDeadline != null ? ' jam ${task.waktuDeadline}' : ''}!');
            }
          } catch (_) {}
        }
      }
    }
  }
}
