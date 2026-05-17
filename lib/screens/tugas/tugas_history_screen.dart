import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/settings_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/utils.dart';

class TugasHistoryScreen extends StatefulWidget {
  const TugasHistoryScreen({super.key});

  @override
  State<TugasHistoryScreen> createState() => _TugasHistoryScreenState();
}

class _TugasHistoryScreenState extends State<TugasHistoryScreen> {
  List<Tugas> _history = [];
  bool _loading = true;
  String _fromDate = hariIni();
  String _toDate = hariIni();
  String _filterStatus = 'Semua';
  String _preset = 'Minggu';

  @override
  void initState() {
    super.initState();
    _applyPreset('Minggu');
  }

  void _applyPreset(String preset) {
    final now = nowWIB();
    final today = hariIni();
    String from;

    switch (preset) {
      case 'Minggu':
        from = tambahHari(hariIni(), -7);
      case 'Bulan':
        from = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month - 1, now.day));
      case 'Tahun':
        from = DateFormat('yyyy-MM-dd').format(DateTime(now.year - 1, now.month, now.day));
      default: 
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
      _history = await SupabaseService.fetchTugasHistory(
        userId: user.id,
        fromDate: _fromDate,
        toDate: _toDate,
        status: _filterStatus,
      );
    } catch (_) {
      _history = [];
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
    final grouped = <String, List<Tugas>>{};
    for (final t in _history) {
      grouped.putIfAbsent(t.tanggalTarget, () => []).add(t);
    }
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: HiteraColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Riwayat Tugas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
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
                    Expanded(child: _datePicker('Dari', _fromDate, () => _pickDate(true))),
                    const SizedBox(width: 12),
                    Expanded(child: _datePicker('Sampai', _toDate, () => _pickDate(false))),
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
                            child: Text('Status', style: TextStyle(color: HiteraColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
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
                                value: _filterStatus,
                                dropdownColor: HiteraColors.bgCard,
                                style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                                items: ['Semua', 'Selesai', 'Aktif', 'Ditunda']
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                    .toList(),
                                onChanged: (v) => setState(() => _filterStatus = v!),
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
                        label: const Text('Filter'),
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
              child: Container(height: 72, decoration: BoxDecoration(color: HiteraColors.bgCardHover, borderRadius: BorderRadius.circular(12))),
            ))
          else if (dates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Center(child: Text(context.read<SettingsProvider>().t('no_task_history_period'),
                  style: const TextStyle(color: HiteraColors.textMuted, fontStyle: FontStyle.italic))),
            )
          else
            ...dates.map((date) {
              final items = grouped[date]!;
              final finishedCount = items.where((i) => i.status == 'selesai').length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatTanggalID(date),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: HiteraColors.textMuted, letterSpacing: 1.5)),
                        Text('$finishedCount/${items.length} Selesai',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: HiteraColors.accentBlue)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...items.map((t) {
                      final prioritasColor = t.prioritas == 'tinggi'
                          ? HiteraColors.accentRed
                          : t.prioritas == 'sedang'
                              ? HiteraColors.accentYellow
                              : HiteraColors.accentBlue;

                      final statusColor = t.status == 'selesai'
                          ? HiteraColors.accentGreen
                          : t.status == 'aktif'
                              ? HiteraColors.accentBlue
                              : HiteraColors.accentYellow;
                      final statusBg = t.status == 'selesai'
                          ? HiteraColors.accentGreenDim
                          : t.status == 'aktif'
                              ? HiteraColors.accentBlueDim
                              : HiteraColors.accentYellowDim;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: HiteraColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: HiteraColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: prioritasColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    t.judul,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: HiteraColors.textPrimary,
                                      decoration: t.status == 'selesai' ? TextDecoration.lineThrough : null,
                                      decorationColor: HiteraColors.textMuted,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    t.status.toUpperCase(),
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const SizedBox(width: 20),
                                const Icon(Icons.schedule, size: 12, color: HiteraColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  'Dibuat: ${formatWaktu(t.createdAt)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: HiteraColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (t.deadline != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const SizedBox(width: 20),
                                  const Icon(Icons.schedule, size: 12, color: HiteraColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Deadline: ${formatTanggalSingkat(t.deadline!)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _isOverdue(t.deadline!, t.status) ? HiteraColors.accentRed : HiteraColors.textMuted,
                                      fontWeight: _isOverdue(t.deadline!, t.status) ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

  bool _isOverdue(String deadline, String status) {
    if (status == 'selesai') return false;
    try {
      return DateTime.parse(deadline).isBefore(nowWIB());
    } catch (_) {
      return false;
    }
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
