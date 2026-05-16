import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import 'package:intl/intl.dart';

class RiwayatNotifikasiScreen extends StatefulWidget {
  const RiwayatNotifikasiScreen({super.key});

  @override
  State<RiwayatNotifikasiScreen> createState() => _RiwayatNotifikasiScreenState();
}

class _RiwayatNotifikasiScreenState extends State<RiwayatNotifikasiScreen> {
  List<dynamic> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    try {
      final response = await SupabaseService.client
          .from('notifikasi_history')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _notifications = response;
          _loading = false;
        });
      }

      final unreadIds = _notifications
          .where((n) => n['is_read'] == false)
          .map((n) => n['id'])
          .toList();

      if (unreadIds.isNotEmpty) {
        await SupabaseService.client
            .from('notifikasi_history')
            .update({'is_read': true})
            .filter('id', 'in', unreadIds);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  IconData _getIcon(String tipe) {
    switch (tipe) {
      case 'keuangan': return Icons.account_balance_wallet_rounded;
      case 'kesehatan': return Icons.favorite_rounded;
      case 'tugas': return Icons.check_box_rounded;
      case 'deadline': return Icons.access_time_filled_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String tipe, bool isRead) {
    if (isRead) return HiteraColors.textMuted;
    switch (tipe) {
      case 'deadline': return HiteraColors.accentRed;
      default: return HiteraColors.accentBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: HiteraColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Riwayat Notifikasi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
        actions: [
          if (!_loading && _notifications.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text('Semua dibaca ✓', style: TextStyle(color: HiteraColors.textMuted, fontSize: 12)),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: HiteraColors.accentBlue))
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 64, color: HiteraColors.textMuted),
                      SizedBox(height: 16),
                      Text('Belum ada notifikasi.', style: TextStyle(color: HiteraColors.textMuted)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    final isRead = notif['is_read'] as bool;
                    final tipe = notif['tipe'] as String;
                    final date = DateTime.parse(notif['created_at']).toLocal();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isRead ? HiteraColors.bgCard : HiteraColors.accentBlueDim.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isRead ? HiteraColors.border : HiteraColors.accentBlue.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(_getIcon(tipe), color: _getIconColor(tipe, isRead), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      tipe == 'deadline' ? 'Peringatan Deadline!' : tipe[0].toUpperCase() + tipe.substring(1),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: isRead ? HiteraColors.textPrimary : HiteraColors.accentBlue,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd MMM HH:mm').format(date),
                                      style: const TextStyle(fontSize: 11, color: HiteraColors.textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notif['pesan'],
                                  style: const TextStyle(fontSize: 13, color: HiteraColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
