import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';
import '../../utils/utils.dart';

class KesehatanHistoryScreen extends StatefulWidget {
  const KesehatanHistoryScreen({super.key});

  @override
  State<KesehatanHistoryScreen> createState() => _KesehatanHistoryScreenState();
}

class _KesehatanHistoryScreenState extends State<KesehatanHistoryScreen> {
  List<DataKesehatan> _history = [];
  bool _loading = true;
  String _fromDate = hariIni();
  String _toDate = hariIni();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    setState(() => _loading = true);
    try {
      _history = await SupabaseService.fetchKesehatanHistory(
        userId: user.id, fromDate: _fromDate, toDate: _toDate,
      );
    } catch (_) {
      _history = [];
    }
    setState(() => _loading = false);
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
      });
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
        title: const Text('Riwayat Kesehatan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HiteraColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HiteraColors.border),
            ),
            child: Row(
              children: [
                Expanded(child: _datePicker('Dari', _fromDate, () => _pickDate(true))),
                const SizedBox(width: 12),
                Expanded(child: _datePicker('Sampai', _toDate, () => _pickDate(false))),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_loading)
            ...List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(height: 120, decoration: BoxDecoration(color: HiteraColors.bgCardHover, borderRadius: BorderRadius.circular(12))),
            ))
          else if (_history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: Text('Tidak ada riwayat kesehatan untuk periode ini.',
                  style: TextStyle(color: HiteraColors.textMuted, fontStyle: FontStyle.italic))),
            )
          else
            ..._history.map((h) => Container(
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
                      _stat('Berat', '${h.beratBadan ?? '-'} kg'),
                      _stat('Air', '${h.airMinum ?? '-'} gls'),
                      _stat('Tidur', '${h.jamTidur ?? '-'} jam'),
                      _stat('Langkah', '${h.langkahKaki ?? '-'}'),
                      _stat('T. Darah', h.tekananDarah ?? '-'),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: HiteraColors.bgSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: HiteraColors.border),
            ),
            child: Text(formatTanggalSingkat(value),
                style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 13)),
          ),
        ),
      ],
    );
  }
}
