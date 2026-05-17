import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class LokasiScreen extends StatefulWidget {
  const LokasiScreen({super.key});

  @override
  State<LokasiScreen> createState() => _LokasiScreenState();
}

class _LokasiScreenState extends State<LokasiScreen> {
  String _currentLocation = 'Belum terdeteksi';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<SettingsProvider>().loadSettings(user.id);
      }
      _checkLocation();
    });
  }

  Future<void> _checkLocation() async {
    final settings = context.read<SettingsProvider>();
    if (!settings.lokasiEnabled) return;

    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }

    if (status.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        if (mounted) {
          setState(() {
            _currentLocation = '${position.latitude}, ${position.longitude}';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _currentLocation = 'Gagal mengambil lokasi';
          });
        }
      }
    }
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
        title: const Text('Lokasi',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: HiteraColors.textPrimary)),
      ),
      body: settings.loading
          ? const Center(
              child: CircularProgressIndicator(color: HiteraColors.accentBlue))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
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
                            const Icon(Icons.location_on,
                                size: 28, color: HiteraColors.accentBlue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Deteksi Lokasi Realtime',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: HiteraColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Izinkan aplikasi untuk mendeteksi lokasi Anda saat mencatat transaksi dan aktivitas.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: HiteraColors.textMuted,
                                    ),
                                  ),
                                  if (settings.lokasiEnabled) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      'Lokasi saat ini: $_currentLocation',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: HiteraColors.success,
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: HiteraColors.border),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Aktifkan Lokasi',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: HiteraColors.textPrimary),
                            ),
                            Switch(
                              value: settings.lokasiEnabled,
                              onChanged: (val) async {
                                if (user != null) {
                                  if (val) {
                                    var status = await Permission
                                        .locationWhenInUse.status;
                                    if (status.isDenied) {
                                      status = await Permission
                                          .locationWhenInUse
                                          .request();
                                    }
                                    if (status.isGranted) {
                                      settings.updateLokasi(user.id, true);
                                      _checkLocation();
                                    }
                                  } else {
                                    settings.updateLokasi(user.id, false);
                                  }
                                }
                              },
                              activeThumbColor: HiteraColors.accentBlue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
