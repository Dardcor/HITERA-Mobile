import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<SettingsProvider>().loadSettings(user.id);
      }
    });
  }

  Future<void> _selectTime(BuildContext context, String current, Function(String) onSelected) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (current.isNotEmpty) {
      final parts = current.split(':');
      if (parts.length == 2) {
        initialTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
      }
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: HiteraColors.accentBlue,
              onPrimary: HiteraColors.bgPrimary,
              surface: HiteraColors.bgCard,
              onSurface: HiteraColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onSelected(formattedTime);
    }
  }

  Widget _buildNotificationCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isEnabled,
    required String? time,
    required Function(bool) onToggle,
    required Function(String) onTimeSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: HiteraColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HiteraColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 28, color: HiteraColors.textPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: HiteraColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: HiteraColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: HiteraColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aktifkan',
                  style: TextStyle(fontSize: 14, color: HiteraColors.textPrimary),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: onToggle,
                  activeThumbColor: HiteraColors.accentBlue,
                ),
              ],
            ),
          ),
          if (isEnabled) ...[
            const Divider(height: 1, color: HiteraColors.border),
            InkWell(
              onTap: () => _selectTime(context, time ?? '08:00', onTimeSelected),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Jam Notifikasi',
                      style: TextStyle(fontSize: 14, color: HiteraColors.textPrimary),
                    ),
                    Row(
                      children: [
                        Text(
                          time ?? '08:00',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: HiteraColors.accentBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 16, color: HiteraColors.textMuted),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: HiteraColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifikasi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
      ),
      body: settings.loading
          ? const Center(child: CircularProgressIndicator(color: HiteraColors.accentBlue))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildNotificationCard(
                  title: 'Keuangan',
                  description: 'Pengingat untuk mencatat keuangan harian',
                  icon: Icons.account_balance_wallet_rounded,
                  isEnabled: settings.keuanganNotifEnabled,
                  time: settings.keuanganNotifTime,
                  onToggle: (val) {
                    if (user != null) {
                      settings.updateKeuanganNotifikasi(user.id, val, time: settings.keuanganNotifTime ?? '08:00');
                    }
                  },
                  onTimeSelected: (time) {
                    if (user != null) {
                      settings.updateKeuanganNotifikasi(user.id, settings.keuanganNotifEnabled, time: time);
                    }
                  },
                ),
                _buildNotificationCard(
                  title: 'Kesehatan',
                  description: 'Pengingat untuk mencatat kesehatan harian',
                  icon: Icons.favorite_rounded,
                  isEnabled: settings.kesehatanNotifEnabled,
                  time: settings.kesehatanNotifTime,
                  onToggle: (val) {
                    if (user != null) {
                      settings.updateKesehatanNotifikasi(user.id, val, time: settings.kesehatanNotifTime ?? '09:00');
                    }
                  },
                  onTimeSelected: (time) {
                    if (user != null) {
                      settings.updateKesehatanNotifikasi(user.id, settings.kesehatanNotifEnabled, time: time);
                    }
                  },
                ),
                _buildNotificationCard(
                  title: 'Tugas',
                  description: 'Pengingat untuk mengecek daftar tugas',
                  icon: Icons.check_box_rounded,
                  isEnabled: settings.tugasNotifEnabled,
                  time: settings.tugasNotifTime,
                  onToggle: (val) {
                    if (user != null) {
                      settings.updateTugasNotifikasi(user.id, val, time: settings.tugasNotifTime ?? '07:00');
                    }
                  },
                  onTimeSelected: (time) {
                    if (user != null) {
                      settings.updateTugasNotifikasi(user.id, settings.tugasNotifEnabled, time: time);
                    }
                  },
                ),
              ],
            ),
    );
  }
}