import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import '../l10n/translations.dart';

class SettingsProvider extends ChangeNotifier {
  bool _loading = false;
  bool _notifikasiEnabled = false;
  String _bahasa = 'id';
  ThemeMode _themeMode = ThemeMode.dark;

  bool _keuanganNotifEnabled = false;
  bool _kesehatanNotifEnabled = false;
  bool _tugasNotifEnabled = false;

  String? _keuanganNotifTime;
  String? _kesehatanNotifTime;
  String? _tugasNotifTime;

  bool get loading => _loading;
  bool get notifikasiEnabled => _notifikasiEnabled;
  String get bahasa => _bahasa;
  ThemeMode get themeMode => _themeMode;

  bool get keuanganNotifEnabled => _keuanganNotifEnabled;
  bool get kesehatanNotifEnabled => _kesehatanNotifEnabled;
  bool get tugasNotifEnabled => _tugasNotifEnabled;

  String? get keuanganNotifTime => _keuanganNotifTime;
  String? get kesehatanNotifTime => _kesehatanNotifTime;
  String? get tugasNotifTime => _tugasNotifTime;

  String t(String key) => AppTranslations.t(key, _bahasa);

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  Future<void> loadSettings(String userId) async {
    _loading = true;
    notifyListeners();

    try {
      final data = await SupabaseService.fetchUserSettings(userId);
      if (data != null) {
        _notifikasiEnabled = data['notifikasi_enabled'] ?? false;
        _bahasa = data['bahasa'] ?? 'id';
        final themeStr = data['theme'] ?? 'dark';
        _themeMode = themeStr == 'light' ? ThemeMode.light : ThemeMode.dark;
        _keuanganNotifEnabled = data['keuangan_notif_enabled'] ?? false;
        _kesehatanNotifEnabled = data['kesehatan_notif_enabled'] ?? false;
        _tugasNotifEnabled = data['tugas_notif_enabled'] ?? false;
        _keuanganNotifTime = data['keuangan_notif_time'];
        _kesehatanNotifTime = data['kesehatan_notif_time'];
        _tugasNotifTime = data['tugas_notif_time'];
      } else {
        await SupabaseService.updateUserSettings(userId, {
          'notifikasi_enabled': false,
          'bahasa': 'id',
          'theme': 'dark',
          'keuangan_notif_enabled': false,
          'kesehatan_notif_enabled': false,
          'tugas_notif_enabled': false,
        });
        _notifikasiEnabled = false;
        _bahasa = 'id';
        _themeMode = ThemeMode.dark;
        _keuanganNotifEnabled = false;
        _kesehatanNotifEnabled = false;
        _tugasNotifEnabled = false;
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> updateNotifikasi(String userId, bool value) async {
    _notifikasiEnabled = value;
    notifyListeners();
    try {
      await SupabaseService.updateUserSettings(userId, {'notifikasi_enabled': value});
    } catch (e) {
      debugPrint('Error updating notifikasi: $e');
      _notifikasiEnabled = !value; 
      notifyListeners();
    }
  }

  Future<void> updateKeuanganNotifikasi(String userId, bool enabled, {String? time}) async {
    _keuanganNotifEnabled = enabled;
    if (time != null) _keuanganNotifTime = time;
    notifyListeners();

    try {
      final Map<String, dynamic> updates = {'keuangan_notif_enabled': enabled};
      if (time != null) updates['keuangan_notif_time'] = time;
      
      await SupabaseService.updateUserSettings(userId, updates);
      
      if (enabled && _keuanganNotifTime != null) {
        final timeParts = _keuanganNotifTime!.split(':');
        await NotificationService.scheduleDailyNotification(
          id: 1,
          title: 'Pengingat Keuangan',
          body: 'Jangan lupa catat pemasukan dan pengeluaran hari ini! 💰',
          time: TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1])),
        );
      } else {
        await NotificationService.cancelNotification(1);
      }
    } catch (e) {
      debugPrint('Error updating keuangan notif: $e');
      _keuanganNotifEnabled = !enabled;
      notifyListeners();
    }
  }

  Future<void> updateKesehatanNotifikasi(String userId, bool enabled, {String? time}) async {
    _kesehatanNotifEnabled = enabled;
    if (time != null) _kesehatanNotifTime = time;
    notifyListeners();

    try {
      final Map<String, dynamic> updates = {'kesehatan_notif_enabled': enabled};
      if (time != null) updates['kesehatan_notif_time'] = time;
      
      await SupabaseService.updateUserSettings(userId, updates);
      
      if (enabled && _kesehatanNotifTime != null) {
        final timeParts = _kesehatanNotifTime!.split(':');
        await NotificationService.scheduleDailyNotification(
          id: 2,
          title: 'Pengingat Kesehatan',
          body: 'Sudah catat data kesehatan hari ini? 💪',
          time: TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1])),
        );
      } else {
        await NotificationService.cancelNotification(2);
      }
    } catch (e) {
      debugPrint('Error updating kesehatan notif: $e');
      _kesehatanNotifEnabled = !enabled;
      notifyListeners();
    }
  }

  Future<void> updateTugasNotifikasi(String userId, bool enabled, {String? time}) async {
    _tugasNotifEnabled = enabled;
    if (time != null) _tugasNotifTime = time;
    notifyListeners();

    try {
      final Map<String, dynamic> updates = {'tugas_notif_enabled': enabled};
      if (time != null) updates['tugas_notif_time'] = time;
      
      await SupabaseService.updateUserSettings(userId, updates);
      
      if (enabled && _tugasNotifTime != null) {
        final timeParts = _tugasNotifTime!.split(':');
        await NotificationService.scheduleDailyNotification(
          id: 3,
          title: 'Pengingat Tugas',
          body: 'Cek daftar tugas Anda hari ini! ✅',
          time: TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1])),
        );
      } else {
        await NotificationService.cancelNotification(3);
      }
    } catch (e) {
      debugPrint('Error updating tugas notif: $e');
      _tugasNotifEnabled = !enabled;
      notifyListeners();
    }
  }

  Future<void> updateBahasa(String userId, String value) async {
    final oldBahasa = _bahasa;
    _bahasa = value;
    notifyListeners();
    try {
      await SupabaseService.updateUserSettings(userId, {'bahasa': value});
    } catch (e) {
      debugPrint('Error updating bahasa: $e');
      _bahasa = oldBahasa; 
      notifyListeners();
    }
  }

  Future<void> updateTheme(String userId) async {
    try {
      await SupabaseService.updateUserSettings(userId, {'theme': _themeMode == ThemeMode.dark ? 'dark' : 'light'});
    } catch (e) {
      debugPrint('Error updating theme: $e');
    }
  }
}
