import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentUser => client.auth.currentUser;

  // === AUTH ===
  static Future<AuthResponse> signIn(String email, String password) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> signUp(String email, String password, String nama) {
    return client.auth.signUp(
      email: email,
      password: password,
      data: {'nama': nama},
    );
  }

  static Future<void> resetPassword(String email) {
    return client.auth.resetPasswordForEmail(email);
  }

  static Future<void> signOut() => client.auth.signOut();

  // === KEUANGAN ===
  static Future<List<Transaksi>> fetchTransaksi(String userId, String tanggal) async {
    final data = await client
        .from('transaksi')
        .select()
        .eq('user_id', userId)
        .eq('tanggal', tanggal)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Transaksi.fromJson(e)).toList();
  }

  static Future<List<Transaksi>> fetchTransaksiHistory({
    required String userId,
    required String fromDate,
    required String toDate,
    String? jenis,
  }) async {
    var query = client
        .from('transaksi')
        .select()
        .eq('user_id', userId)
        .gte('tanggal', fromDate)
        .lte('tanggal', toDate)
        .order('tanggal', ascending: false)
        .order('created_at', ascending: false);

    if (jenis != null && jenis != 'Semua') {
      query = client
          .from('transaksi')
          .select()
          .eq('user_id', userId)
          .gte('tanggal', fromDate)
          .lte('tanggal', toDate)
          .eq('jenis', jenis.toLowerCase())
          .order('tanggal', ascending: false)
          .order('created_at', ascending: false);
    }

    final data = await query;
    return (data as List).map((e) => Transaksi.fromJson(e)).toList();
  }

  static Future<void> tambahTransaksi(Map<String, dynamic> data) {
    return client.from('transaksi').insert(data);
  }

  static Future<void> hapusTransaksi(String id) {
    return client.from('transaksi').delete().eq('id', id);
  }

  // === KESEHATAN ===
  static Future<DataKesehatan?> fetchKesehatan(String userId, String tanggal) async {
    try {
      final data = await client
          .from('kesehatan')
          .select()
          .eq('user_id', userId)
          .eq('tanggal', tanggal)
          .maybeSingle();
      if (data == null) return null;
      return DataKesehatan.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  static Future<List<DataKesehatan>> fetchKesehatanHistory({
    required String userId,
    required String fromDate,
    required String toDate,
  }) async {
    final data = await client
        .from('kesehatan')
        .select()
        .eq('user_id', userId)
        .gte('tanggal', fromDate)
        .lte('tanggal', toDate)
        .order('tanggal', ascending: false);
    return (data as List).map((e) => DataKesehatan.fromJson(e)).toList();
  }

  static Future<void> simpanKesehatan(Map<String, dynamic> data) {
    return client.from('kesehatan').upsert(data, onConflict: 'user_id,tanggal');
  }

  // === TUGAS ===
  static Future<List<Tugas>> fetchTugas(String userId, String tanggal) async {
    final data = await client
        .from('tugas')
        .select()
        .eq('user_id', userId)
        .eq('tanggal_target', tanggal)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Tugas.fromJson(e)).toList();
  }

  static Future<List<Tugas>> fetchTugasHistory({
    required String userId,
    required String fromDate,
    required String toDate,
    String? status,
  }) async {
    var query = client
        .from('tugas')
        .select()
        .eq('user_id', userId)
        .gte('tanggal_target', fromDate)
        .lte('tanggal_target', toDate)
        .order('tanggal_target', ascending: false);

    if (status != null && status != 'Semua') {
      query = client
          .from('tugas')
          .select()
          .eq('user_id', userId)
          .gte('tanggal_target', fromDate)
          .lte('tanggal_target', toDate)
          .eq('status', status.toLowerCase())
          .order('tanggal_target', ascending: false);
    }

    final data = await query;
    return (data as List).map((e) => Tugas.fromJson(e)).toList();
  }

  static Future<void> addTugas(Map<String, dynamic> data) {
    return client.from('tugas').insert(data);
  }

  static Future<void> toggleTugasStatus(String id, String currentStatus) {
    final newStatus = currentStatus == 'selesai' ? 'aktif' : 'selesai';
    return client.from('tugas').update({
      'status': newStatus,
      'tanggal_selesai': newStatus == 'selesai' ? DateTime.now().toIso8601String() : null,
    }).eq('id', id);
  }

  static Future<void> deleteTugas(String id) {
    return client.from('tugas').delete().eq('id', id);
  }

  // === KESEHARIAN TODOS ===
  static Future<List<Map<String, dynamic>>> fetchKeseharianTodos(String userId, String date) async {
    final data = await client
        .from('keseharian_todos')
        .select()
        .eq('user_id', userId)
        .eq('date', date)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data as List);
  }

  static Future<void> addKeseharianTodo(Map<String, dynamic> data) {
    return client.from('keseharian_todos').insert(data);
  }

  static Future<void> toggleKeseharianTodo(String id, bool currentStatus) {
    return client.from('keseharian_todos').update({'is_done': !currentStatus}).eq('id', id);
  }

  static Future<void> deleteKeseharianTodo(String id) {
    return client.from('keseharian_todos').delete().eq('id', id);
  }

  // === KESEHARIAN JURNAL ===
  static Future<String?> fetchKeseharianJurnal(String userId, String date) async {
    try {
      final data = await client
          .from('keseharian_jurnal')
          .select('content')
          .eq('user_id', userId)
          .eq('date', date)
          .maybeSingle();
      if (data == null) return null;
      return data['content'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveKeseharianJurnal(String userId, String date, String content) {
    return client.from('keseharian_jurnal').upsert({
      'user_id': userId,
      'date': date,
      'content': content,
    }, onConflict: 'user_id, date');
  }

  // === PROFILE ===
  static Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    try {
      final data = await client
          .from('profiles')
          .select('username, full_name')
          .eq('id', userId)
          .maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateProfile(String userId, String username, String fullName) {
    return client.from('profiles').upsert({
      'id': userId,
      'username': username,
      'full_name': fullName,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> changePassword(String newPassword) {
    return client.auth.updateUser(UserAttributes(password: newPassword));
  }
}
