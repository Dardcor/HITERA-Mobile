import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';
import '../../utils/utils.dart';

class KeuanganHistoryScreen extends StatefulWidget {
  const KeuanganHistoryScreen({super.key});

  @override
  State<KeuanganHistoryScreen> createState() => _KeuanganHistoryScreenState();
}

class _KeuanganHistoryScreenState extends State<KeuanganHistoryScreen> {
  List<Transaksi> _transaksi = [];
  bool _loading = true;
  String _fromDate = hariIni();
  String _toDate = hariIni();
  String _filterJenis = 'Semua';
  String _preset = 'Minggu';

  @override
  void initState() {
    super.initState();
    _applyPreset('Minggu');
  }

  void _applyPreset(String preset) {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T').first;
    String from;

    switch (preset) {
      case 'Minggu':
        from = now.subtract(const Duration(days: 7)).toIso8601String().split('T').first;
      case 'Bulan':
        from = DateTime(now.year, now.month - 1, now.day).toIso8601String().split('T').first;
      case 'Tahun':
        from = DateTime(now.year - 1, now.month, now.day).toIso8601String().split('T').first;
      default: // Semua
        from = '2020-01-01';
    }

    setState(() {
      _preset = preset;
      _fromDate = from;
      _toDate = today;
    });
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    setState(() => _loading = true);
    try {
      _transaksi = await SupabaseService.fetchTransaksiHistory(
        userId: user.id,
        fromDate: _fromDate,
        toDate: _toDate,
        jenis: _filterJenis,
      );
    } catch (_) {
      _transaksi = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(isFrom ? _fromDate : _toDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        final d = picked.toIso8601String().split('T').first;
        if (isFrom) {
          _fromDate = d;
        } else {
          _toDate = d;
        }
        _preset = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group by date
    final grouped = <String, List<Transaksi>>{};
    for (final t in _transaksi) {
      grouped.putIfAbsent(t.tanggal, () => []).add(t);
    }
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: HiteraColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Riwayat Transaksi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Preset filter chips
          Row(
            children: ['Semua', 'Minggu', 'Bulan', 'Tahun'].map((p) {
              final isSelected = _preset == p;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _applyPreset(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? HiteraColors.accentBlue : HiteraColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? HiteraColors.accentBlue : HiteraColors.border),
                    ),
                    child: Text(
                      p,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? HiteraColors.bgPrimary : HiteraColors.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Filter card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HiteraColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HiteraColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _datePicker('Dari', _fromDate, () => _pickDate(true)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _datePicker('Sampai', _toDate, () => _pickDate(false)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 2, bottom: 6),
                            child: Text('Jenis', style: TextStyle(color: HiteraColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: HiteraColors.bgSecondary,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: HiteraColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _filterJenis,
                                dropdownColor: HiteraColors.bgCard,
                                style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                                items: ['Semua', 'Pemasukan', 'Pengeluaran']
                                    .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                                    .toList(),
                                onChanged: (v) => setState(() => _filterJenis = v!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton.icon(
                        onPressed: _fetchHistory,
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('Cari'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HiteraColors.accentBlue,
                          foregroundColor: HiteraColors.bgPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_loading)
            ...List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(height: 80, decoration: BoxDecoration(color: HiteraColors.bgCardHover, borderRadius: BorderRadius.circular(12))),
            ))
          else if (dates.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: Text('Tidak ada data untuk periode ini.',
                  style: TextStyle(color: HiteraColors.textMuted, fontStyle: FontStyle.italic))),
            )
          else
            ...dates.map((date) {
              final items = grouped[date]!;
              final income = items.where((i) => i.jenis == 'pemasukan').fold<double>(0, (s, i) => s + i.jumlah);
              final expense = items.where((i) => i.jenis == 'pengeluaran').fold<double>(0, (s, i) => s + i.jumlah);

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatTanggalID(date),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: HiteraColors.textMuted, letterSpacing: 1.5)),
                        Row(
                          children: [
                            Text('+${formatRupiah(income)}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: HiteraColors.accentGreen)),
                            const SizedBox(width: 8),
                            Text('-${formatRupiah(expense)}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: HiteraColors.accentRed)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...items.map((t) {
                      final isPemasukan = t.jenis == 'pemasukan';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: HiteraColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: HiteraColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isPemasukan ? HiteraColors.accentGreen : HiteraColors.accentRed,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.kategori, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
                                  Text(t.deskripsi ?? '-', style: const TextStyle(fontSize: 10, color: HiteraColors.textMuted)),
                                ],
                              ),
                            ),
                            Text(
                              '${isPemasukan ? '+' : '-'} ${formatRupiah(t.jumlah)}',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isPemasukan ? HiteraColors.accentGreen : HiteraColors.accentRed),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _datePicker(String label, String value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(label, style: const TextStyle(color: HiteraColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: HiteraColors.bgSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: HiteraColors.border),
            ),
            child: Text(formatTanggalSingkat(value),
                style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
