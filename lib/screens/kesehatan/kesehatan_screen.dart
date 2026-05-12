import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/kesehatan_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/utils.dart';
import '../../widgets/toast.dart';

class KesehatanScreen extends StatefulWidget {
  const KesehatanScreen({super.key});

  @override
  State<KesehatanScreen> createState() => _KesehatanScreenState();
}

class _KesehatanScreenState extends State<KesehatanScreen> {
  List<DataKesehatan> _recentHistory = [];
  bool _historyLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KesehatanProvider>().fetch();
      _fetchRecentHistory();
    });
  }

  Future<void> _fetchRecentHistory() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    setState(() => _historyLoading = true);
    try {
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 7));
      _recentHistory = await SupabaseService.fetchKesehatanHistory(
        userId: user.id,
        fromDate: from.toIso8601String().split('T').first,
        toDate: now.toIso8601String().split('T').first,
      );
    } catch (_) {
      _recentHistory = [];
    }
    if (mounted) setState(() => _historyLoading = false);
  }

  void _showFormModal() {
    final prov = context.read<KesehatanProvider>();
    final data = prov.data;

    final jamTidurCtrl = TextEditingController(text: data?.jamTidur?.toString() ?? '');
    final catatanCtrl = TextEditingController(text: data?.catatan ?? '');
    int airMinum = data?.airMinum ?? 0;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HiteraColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data != null ? 'Edit Data Kesehatan' : 'Isi Data Kesehatan',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close, color: HiteraColors.textMuted, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _label('Air Minum (Gelas 250ml)'),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: HiteraColors.bgSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: HiteraColors.border),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: HiteraColors.textSecondary),
                        onPressed: () => setModalState(() => airMinum = (airMinum - 1).clamp(0, 99)),
                      ),
                      Expanded(
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: '$airMinum ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
                                const TextSpan(text: 'Gelas', style: TextStyle(fontSize: 12, color: HiteraColors.textMuted)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: HiteraColors.textSecondary),
                        onPressed: () => setModalState(() => airMinum++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _field('Jam Tidur (jam)', jamTidurCtrl, 'number', '7.5'),
                const SizedBox(height: 16),
                _label('Catatan Hari Ini'),
                const SizedBox(height: 6),
                TextField(
                  controller: catatanCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'Bagaimana perasaanmu hari ini?'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HiteraColors.textSecondary,
                        side: const BorderSide(color: HiteraColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 12),
                    isSubmitting
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: HiteraColors.accentBlue.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              SizedBox(width: 8),
                              Text('Menyimpan...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                            ],
                          ),
                        )
                      : ElevatedButton(
                      onPressed: () async {
                        setModalState(() => isSubmitting = true);
                        final err = await prov.simpan(
                          airMinum: airMinum,
                          jamTidur: double.tryParse(jamTidurCtrl.text),
                          catatan: catatanCtrl.text.isNotEmpty ? catatanCtrl.text : null,
                        );
                        if (ctx.mounted) {
                          setModalState(() => isSubmitting = false);
                          Navigator.pop(ctx);
                        }
                        if (mounted) {
                          if (err == null) {
                            HiteraToast.success(context, 'Data kesehatan berhasil disimpan.');
                            _fetchRecentHistory();
                          } else {
                            HiteraToast.error(context, 'Gagal menyimpan data kesehatan.');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HiteraColors.accentBlue,
                        foregroundColor: HiteraColors.bgPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Simpan Data', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String type, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type == 'number' ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(text, style: const TextStyle(color: HiteraColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<KesehatanProvider>();

    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kesehatan Harian',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
            const SizedBox(height: 4),
            Row(
              children: [
                _navButton(Icons.chevron_left, prov.prevDay),
                const SizedBox(width: 8),
                Text(formatTanggalID(prov.tanggal),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: HiteraColors.accentBlue)),
                const SizedBox(width: 8),
                _navButton(Icons.chevron_right, prov.nextDay),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(prov.data != null ? Icons.edit : Icons.add_rounded, color: HiteraColors.accentBlue),
            onPressed: _showFormModal,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: HiteraColors.accentBlue,
        onRefresh: () async {
          await prov.fetch();
          await _fetchRecentHistory();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!prov.loading && prov.data == null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 60),
                decoration: BoxDecoration(
                  color: HiteraColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: HiteraColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(color: HiteraColors.bgSecondary, shape: BoxShape.circle),
                      child: const Icon(Icons.favorite_rounded, color: HiteraColors.accentBlue, size: 36),
                    ),
                    const SizedBox(height: 20),
                    const Text('Data Belum Diisi',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
                    const SizedBox(height: 8),
                    const Text('Catat perkembangan kesehatan Anda hari ini.',
                        style: TextStyle(fontSize: 14, color: HiteraColors.textSecondary)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _showFormModal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HiteraColors.accentBlue,
                        foregroundColor: HiteraColors.bgPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      ),
                      child: const Text('Isi Data Kesehatan', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              )
            else ...[
              // Metrics grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: [
                  _metrikCard(Icons.water_drop, Colors.cyan, 'Air Minum', '${prov.data?.airMinum ?? '-'}', 'gelas'),
                  _metrikCard(Icons.nightlight_round, Colors.indigo, 'Jam Tidur', '${prov.data?.jamTidur ?? '-'}', 'jam'),
                  _catatanCard(prov.data?.catatan),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RIWAYAT 7 HARI TERAKHIR',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary, letterSpacing: 1.5)),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/kesehatan-history'),
                  child: const Text('Lihat Semua',
                      style: TextStyle(fontSize: 12, color: HiteraColors.accentBlue, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_historyLoading)
              ...List.generate(3, (_) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(height: 80, decoration: BoxDecoration(color: HiteraColors.bgCardHover, borderRadius: BorderRadius.circular(12))),
              ))
            else if (_recentHistory.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: HiteraColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: HiteraColors.border),
                ),
                child: const Text(
                  'Belum ada riwayat kesehatan.',
                  style: TextStyle(fontSize: 14, color: HiteraColors.textMuted, fontStyle: FontStyle.italic),
                ),
              )
            else
              ..._recentHistory.map((h) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: HiteraColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: HiteraColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatTanggalID(h.tanggal),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: HiteraColors.accentBlue)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      children: [
                        _stat('Air', '${h.airMinum ?? '-'} gls'),
                        _stat('Tidur', '${h.jamTidur ?? '-'} jam'),
                      ],
                    ),
                    if (h.catatan != null && h.catatan!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.only(top: 12),
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: HiteraColors.border))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CATATAN', style: TextStyle(fontSize: 9, color: HiteraColors.textMuted, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text(h.catatan!, maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: HiteraColors.textSecondary, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: HiteraColors.textMuted, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
      ],
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: HiteraColors.border),
        ),
        child: Icon(icon, size: 16, color: HiteraColors.textPrimary),
      ),
    );
  }

  Widget _metrikCard(IconData icon, Color color, String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HiteraColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HiteraColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 9, color: HiteraColors.textMuted, fontWeight: FontWeight.w700, letterSpacing: 1)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: HiteraColors.textPrimary)),
                  const SizedBox(width: 4),
                  Text(unit, style: const TextStyle(fontSize: 9, color: HiteraColors.textMuted)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _catatanCard(String? catatan) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HiteraColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HiteraColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.note, color: Colors.amber, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CATATAN', style: TextStyle(fontSize: 9, color: HiteraColors.textMuted, fontWeight: FontWeight.w700, letterSpacing: 1)),
              Text(catatan ?? '-',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: HiteraColors.textSecondary, fontStyle: FontStyle.italic)),
            ],
          ),
        ],
      ),
    );
  }
}
