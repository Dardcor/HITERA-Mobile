import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/keuangan_provider.dart';
import '../../providers/kesehatan_provider.dart';
import '../../providers/tugas_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/utils.dart';
import '../pengaturan/notifikasi_screen.dart';
import 'riwayat_notifikasi_screen.dart';
import '../../services/supabase_service.dart';
import '../../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KeuanganProvider>().fetch();
      context.read<KesehatanProvider>().fetch();
      context.read<TugasProvider>().fetch().then((_) {
        _checkNotifications();
      });
    });
  }

  Future<void> _checkNotifications() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    
    final data = await SupabaseService.fetchUserSettings(user.id);
    if (data == null) return;
    
    final tasks = context.read<TugasProvider>().tugas;
    final activeTasks = tasks.where((t) => t.status == 'aktif').toList();
    
    await NotificationService.generateDailyHistoryAndSpam(user.id, data, activeTasks);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final keuangan = context.watch<KeuanganProvider>();
    final kesehatan = context.watch<KesehatanProvider>();
    final tugas = context.watch<TugasProvider>();
    final settings = context.watch<SettingsProvider>();
    final tgl = hariIni();

    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatTanggalID(tgl),
              style: const TextStyle(
                color: HiteraColors.accentBlue,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '${getGreeting(settings)}, ${auth.userName}',
              style: const TextStyle(
                color: HiteraColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: HiteraColors.textPrimary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatNotifikasiScreen())),
          ),
          const SizedBox(width: 8),
        ],
        
      ),
      body: RefreshIndicator(
        color: HiteraColors.accentBlue,
        onRefresh: () async {
          await Future.wait([
            keuangan.fetch(),
            kesehatan.fetch(),
            tugas.fetch(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            
            _buildSummaryCard(
              icon: Icons.account_balance_wallet_rounded,
              iconBg: HiteraColors.accentBlueDim,
              iconColor: HiteraColors.accentBlue,
              title: settings.t('balance_now').toUpperCase(),
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    keuangan.loading ? '...' : formatRupiah(keuangan.totalSaldo),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: keuangan.totalSaldo >= 0
                          ? HiteraColors.accentGreen
                          : HiteraColors.accentRed,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: HiteraColors.border),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(settings.t('income').toUpperCase(),
                                style: const TextStyle(fontSize: 9, color: HiteraColors.textMuted, letterSpacing: 1)),
                            Text(
                              '+${keuangan.loading ? "..." : formatRupiah(keuangan.totalPemasukan)}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: HiteraColors.accentGreen),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(settings.t('expense').toUpperCase(),
                                style: const TextStyle(fontSize: 9, color: HiteraColors.textMuted, letterSpacing: 1)),
                            Text(
                              '-${keuangan.loading ? "..." : formatRupiah(keuangan.totalPengeluaran)}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: HiteraColors.accentRed),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (keuangan.trendSaldo.isNotEmpty && !keuangan.loading) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 80,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineTouchData: const LineTouchData(enabled: false),
                          minX: 0,
                          maxX: 6,
                          minY: keuangan.trendSaldo.map((e) => e['saldo'] as double).reduce((a, b) => a < b ? a : b),
                          maxY: keuangan.trendSaldo.map((e) => e['saldo'] as double).reduce((a, b) => a > b ? a : b),
                          lineBarsData: [
                            LineChartBarData(
                              spots: keuangan.trendSaldo.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), e.value['saldo'] as double);
                              }).toList(),
                              isCurved: true,
                              color: HiteraColors.accentBlue,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                checkToShowDot: (spot, barData) {
                                  return spot.x == 0 || spot.x == 6;
                                },
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 3,
                                    color: HiteraColors.accentBlue,
                                    strokeWidth: 0,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: HiteraColors.accentBlueDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            
            _buildSummaryCard(
              icon: Icons.favorite_rounded,
              iconBg: HiteraColors.accentGreenDim,
              iconColor: HiteraColors.accentGreen,
              title: settings.t('health_today').toUpperCase(),
              onTap: () {},
              child: kesehatan.loading
                  ? const Text('...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: HiteraColors.textPrimary))
                  : kesehatan.data != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('💧 ${kesehatan.data!.airMinum ?? '-'} ${settings.t('glasses').toLowerCase()}',
                                    style: const TextStyle(fontSize: 14, color: HiteraColors.textPrimary, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 16),
                                Text('😴 ${kesehatan.data!.jamTidur ?? '-'} ${settings.t('hours').toLowerCase()}',
                                    style: const TextStyle(fontSize: 14, color: HiteraColors.textPrimary, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text('🏃 ${kesehatan.data!.olahragaJam ?? 0}${settings.t('hour_short')} ${kesehatan.data!.olahragaMenit ?? 0}${settings.t('minute_short')}',
                                    style: const TextStyle(fontSize: 14, color: HiteraColors.textPrimary, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            if (kesehatan.data!.catatan != null && kesehatan.data!.catatan!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(kesehatan.data!.catatan!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: HiteraColors.textSecondary, fontStyle: FontStyle.italic)),
                            ],
                          ],
                        )
                      : const Text('Data belum diisi',
                          style: TextStyle(fontSize: 14, color: HiteraColors.textSecondary, fontStyle: FontStyle.italic)),
            ),
            const SizedBox(height: 12),

            
            _buildSummaryCard(
              icon: Icons.check_box_rounded,
              iconBg: HiteraColors.accentRedDim,
              iconColor: HiteraColors.accentRed,
              title: settings.t('tasks_today').toUpperCase(),
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tugas.loading ? '...' : '${tugas.tugasSelesai.length}/${tugas.tugas.length} ${settings.t('tasks')}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: HiteraColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text('Selesai ${tugas.progress}%',
                      style: const TextStyle(fontSize: 9, color: HiteraColors.textMuted, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: tugas.progress / 100,
                      backgroundColor: HiteraColors.bgSecondary,
                      valueColor: const AlwaysStoppedAnimation(HiteraColors.accentRed),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tugas.tugasAktif.isNotEmpty
                        ? '${tugas.tugasAktif.length} ${settings.t('tasks').toLowerCase()} ${settings.t('filter_active').toLowerCase()}'
                        : '${settings.t('all_tasks_done')} 🙌',
                    style: const TextStyle(fontSize: 12, color: HiteraColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionCard(
              title: settings.t('main_tasks'),
              actionLabel: settings.t('see_all'),
              onAction: () {},
              child: tugas.tugasAktif.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(settings.t('no_active_tasks'),
                            style: const TextStyle(color: HiteraColors.textMuted, fontSize: 14, fontStyle: FontStyle.italic)),
                      ),
                    )
                  : Column(
                      children: tugas.tugasAktif.take(5).map((t) {
                        final prioritasColor = t.prioritas == 'tinggi'
                            ? HiteraColors.accentRed
                            : t.prioritas == 'sedang'
                                ? HiteraColors.accentYellow
                                : HiteraColors.accentBlue;
                        final prioritasBg = t.prioritas == 'tinggi'
                            ? HiteraColors.accentRedDim
                            : t.prioritas == 'sedang'
                                ? HiteraColors.accentYellowDim
                                : HiteraColors.accentBlueDim;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: HiteraColors.border.withValues(alpha: 0.5))),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 16, height: 16,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: HiteraColors.border),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(t.judul,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: HiteraColors.textPrimary)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: prioritasBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  t.prioritas == 'tinggi' ? settings.t('priority_high').toUpperCase() :
                                  t.prioritas == 'sedang' ? settings.t('priority_medium').toUpperCase() :
                                  settings.t('priority_low').toUpperCase(),
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: prioritasColor, letterSpacing: 0.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HiteraColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HiteraColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              GestureDetector(
                onTap: onTap,
                child: Icon(Icons.arrow_outward_rounded, color: HiteraColors.textMuted, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: HiteraColors.textMuted, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: HiteraColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HiteraColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: HiteraColors.bgSecondary.withValues(alpha: 0.3),
              border: Border(bottom: BorderSide(color: HiteraColors.border)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
                GestureDetector(
                  onTap: onAction,
                  child: Text(actionLabel, style: const TextStyle(fontSize: 12, color: HiteraColors.accentBlue)),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
