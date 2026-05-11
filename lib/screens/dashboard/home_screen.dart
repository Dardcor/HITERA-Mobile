import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/keuangan_provider.dart';
import '../../providers/kesehatan_provider.dart';
import '../../providers/tugas_provider.dart';
import '../../utils/utils.dart';

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
      context.read<TugasProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final keuangan = context.watch<KeuanganProvider>();
    final kesehatan = context.watch<KesehatanProvider>();
    final tugas = context.watch<TugasProvider>();
    final tgl = hariIni();

    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      appBar: AppBar(
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
              '${getGreeting()}, ${auth.userName}',
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
            icon: const Icon(Icons.settings_rounded, color: HiteraColors.textMuted),
            onPressed: () => Navigator.pushNamed(context, '/pengaturan'),
          ),
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
            // === KEUANGAN CARD ===
            _buildSummaryCard(
              icon: Icons.account_balance_wallet_rounded,
              iconBg: HiteraColors.accentBlueDim,
              iconColor: HiteraColors.accentBlue,
              title: 'SALDO BERSIH HARI INI',
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    keuangan.loading ? '...' : formatRupiah(keuangan.saldoBersih),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: keuangan.saldoBersih >= 0
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
                            const Text('PEMASUKAN',
                                style: TextStyle(fontSize: 9, color: HiteraColors.textMuted, letterSpacing: 1)),
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
                            const Text('PENGELUARAN',
                                style: TextStyle(fontSize: 9, color: HiteraColors.textMuted, letterSpacing: 1)),
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
                ],
              ),
            ),
            const SizedBox(height: 12),

            // === KESEHATAN CARD ===
            _buildSummaryCard(
              icon: Icons.favorite_rounded,
              iconBg: HiteraColors.accentGreenDim,
              iconColor: HiteraColors.accentGreen,
              title: 'KESEHATAN HARI INI',
              onTap: () {},
              child: kesehatan.loading
                  ? const Text('...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: HiteraColors.textPrimary))
                  : kesehatan.data != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${kesehatan.data!.beratBadan ?? '-'} kg',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: HiteraColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('💧 ${kesehatan.data!.airMinum ?? '-'} gelas',
                                    style: const TextStyle(fontSize: 12, color: HiteraColors.textSecondary, fontWeight: FontWeight.w500)),
                                const SizedBox(width: 16),
                                Text('😴 ${kesehatan.data!.jamTidur ?? '-'} jam',
                                    style: const TextStyle(fontSize: 12, color: HiteraColors.textSecondary, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        )
                      : const Text('Data belum diisi',
                          style: TextStyle(fontSize: 14, color: HiteraColors.textSecondary, fontStyle: FontStyle.italic)),
            ),
            const SizedBox(height: 12),

            // === TUGAS CARD ===
            _buildSummaryCard(
              icon: Icons.check_box_rounded,
              iconBg: HiteraColors.accentRedDim,
              iconColor: HiteraColors.accentRed,
              title: 'TUGAS HARI INI',
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tugas.loading ? '...' : '${tugas.tugasSelesai.length}/${tugas.tugas.length} Tugas',
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
                        ? '${tugas.tugasAktif.length} tugas masih aktif'
                        : 'Semua tugas selesai! 🙌',
                    style: const TextStyle(fontSize: 12, color: HiteraColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // === TUGAS UTAMA LIST ===
            _buildSectionCard(
              title: 'Tugas Utama',
              actionLabel: 'Lihat Semua',
              onAction: () {},
              child: tugas.tugasAktif.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('Tidak ada tugas aktif hari ini',
                            style: TextStyle(color: HiteraColors.textMuted, fontSize: 14, fontStyle: FontStyle.italic)),
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
                                  t.prioritas.toUpperCase(),
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
