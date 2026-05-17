import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/tugas_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/utils.dart';
import '../../widgets/toast.dart';

class TugasScreen extends StatefulWidget {
  const TugasScreen({super.key});

  @override
  State<TugasScreen> createState() => _TugasScreenState();
}

class _TugasScreenState extends State<TugasScreen> {
  String _filter = 'semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TugasProvider>().fetch();
    });
  }

  void _showAddModal(SettingsProvider settings) {
    final judulCtrl = TextEditingController();
    final deskripsiCtrl = TextEditingController();
    String prioritas = 'sedang';
    String? deadline;
    String? waktuDeadline;
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
                    Text(settings.t('add_task'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close, color: HiteraColors.textMuted, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _label(settings.t('task_title')),
                const SizedBox(height: 6),
                TextField(
                  controller: judulCtrl,
                  style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'Contoh: Beli susu'),
                ),
                const SizedBox(height: 16),
                _label(settings.t('description_optional')),
                const SizedBox(height: 6),
                TextField(
                  controller: deskripsiCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'Tambahkan detail...'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label(settings.t('deadline_optional')),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: deadline != null ? DateTime.parse(deadline!) : nowWIB(),
                                firstDate: nowWIB(),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  deadline = picked.toIso8601String().split('T').first;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: HiteraColors.bgSecondary,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: HiteraColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      deadline != null ? formatTanggalID(deadline!) : 'Pilih tanggal',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: deadline != null ? HiteraColors.textPrimary : HiteraColors.textMuted,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (deadline != null)
                                    GestureDetector(
                                      onTap: () => setModalState(() => deadline = null),
                                      child: const Icon(Icons.close, color: HiteraColors.textMuted, size: 18),
                                    )
                                  else
                                    const Icon(Icons.calendar_today, color: HiteraColors.textMuted, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Jam Deadline'),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: waktuDeadline != null 
                                  ? TimeOfDay(hour: int.parse(waktuDeadline!.split(':')[0]), minute: int.parse(waktuDeadline!.split(':')[1]))
                                  : TimeOfDay.now(),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  waktuDeadline = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: HiteraColors.bgSecondary,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: HiteraColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      waktuDeadline ?? 'Pilih jam',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: waktuDeadline != null ? HiteraColors.textPrimary : HiteraColors.textMuted,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (waktuDeadline != null)
                                    GestureDetector(
                                      onTap: () => setModalState(() => waktuDeadline = null),
                                      child: const Icon(Icons.close, color: HiteraColors.textMuted, size: 18),
                                    )
                                  else
                                    const Icon(Icons.access_time, color: HiteraColors.textMuted, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _label(settings.t('priority')),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: HiteraColors.bgSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: HiteraColors.border),
                  ),
                  child: Row(
                    children: ['rendah', 'sedang', 'tinggi'].map((p) {
                      final isSelected = prioritas == p;
                      final color = p == 'tinggi'
                          ? HiteraColors.accentRed
                          : p == 'sedang'
                              ? HiteraColors.accentYellow
                              : HiteraColors.accentBlue;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => prioritas = p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? color : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                p == 'tinggi' ? settings.t('priority_high') :
                                p == 'sedang' ? settings.t('priority_medium') :
                                settings.t('priority_low'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? (p == 'tinggi' ? Colors.white : HiteraColors.bgPrimary)
                                      : HiteraColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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
                        child: Text(settings.t('cancel')),
                      ),
                    const SizedBox(width: 12),
                    isSubmitting
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: HiteraColors.accentBlue.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text('${settings.t('loading')}...', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                            ],
                          ),
                        )
                      : ElevatedButton(
                      onPressed: () async {
                        if (judulCtrl.text.trim().isEmpty) return;
                        setModalState(() => isSubmitting = true);
                        final err = await context.read<TugasProvider>().tambah(
                          judul: judulCtrl.text.trim(),
                          deskripsi: deskripsiCtrl.text.isNotEmpty ? deskripsiCtrl.text : null,
                          prioritas: prioritas,
                          deadline: deadline,
                          waktuDeadline: waktuDeadline,
                        );
                        if (ctx.mounted) {
                          setModalState(() => isSubmitting = false);
                          Navigator.pop(ctx);
                        }
                        if (mounted) {
                            if (err == null) {
                              HiteraToast.success(context, settings.t('task_added'));
                            } else {
                              HiteraToast.error(context, settings.t('error'));
                            }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HiteraColors.accentBlue,
                        foregroundColor: HiteraColors.bgPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(settings.t('add_task'), style: const TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(text, style: const TextStyle(color: HiteraColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  
  Map<String, List<dynamic>> _groupByTanggal(List displayTugas) {
    final Map<String, List<dynamic>> grouped = {};
    for (final t in displayTugas) {
      final key = t.tanggalTarget;
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(t);
    }
    
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (var k in sortedKeys) k: grouped[k]!};
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TugasProvider>();
    final settings = context.watch<SettingsProvider>();

    final displayTugas = _filter == 'semua'
        ? prov.tugas
        : _filter == 'aktif'
            ? prov.tugasAktif
            : prov.tugasSelesai;

    final grouped = _groupByTanggal(displayTugas);

    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      appBar: AppBar(
        title: Text(settings.t('tasks'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: HiteraColors.accentBlue),
            onPressed: () => _showAddModal(settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: HiteraColors.accentBlue,
        onRefresh: prov.fetch,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: HiteraColors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: HiteraColors.border),
              ),
              child: Row(
                children: ['semua', 'aktif', 'selesai'].map((f) {
                  final isSelected = _filter == f;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? HiteraColors.bgCard : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            f == 'semua' ? settings.t('filter_all') :
                            f == 'aktif' ? settings.t('filter_active') :
                            settings.t('filter_done'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? HiteraColors.accentBlue : HiteraColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            
            if (prov.loading)
              ...List.generate(3, (_) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(color: HiteraColors.bgCardHover, borderRadius: BorderRadius.circular(12)),
                ),
              ))
            else if (displayTugas.isEmpty)
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
                      width: 64, height: 64,
                      decoration: BoxDecoration(color: HiteraColors.bgSecondary, shape: BoxShape.circle),
                      child: const Icon(Icons.list_alt, color: HiteraColors.textMuted, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(settings.t('no_tasks'),
                        style: const TextStyle(color: HiteraColors.textMuted, fontStyle: FontStyle.italic)),
                  ],
                ),
              )
            else
              ...grouped.entries.expand((entry) {
                final tanggal = entry.key;
                final items = entry.value;
                return [
                  
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    child: Text(
                      formatTanggalID(tanggal),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: HiteraColors.accentBlue,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  
                  ...items.map((t) {
                    final isSelesai = t.status == 'selesai';
                    final prioritasColor = t.prioritas == 'tinggi'
                        ? HiteraColors.accentRed
                        : t.prioritas == 'sedang'
                            ? HiteraColors.accentYellow
                            : HiteraColors.accentBlue;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: HiteraColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: HiteraColors.border),
                      ),
                      child: Opacity(
                        opacity: isSelesai ? 0.6 : 1,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final err = await prov.toggleSelesai(t.id, t.status);
                                if (err != null && mounted) {
                                  if (!context.mounted) return;
                                  HiteraToast.error(context, context.read<SettingsProvider>().t('failed_update_status'));
                                }
                              },
                              child: Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: isSelesai ? HiteraColors.accentGreen : Colors.transparent,
                                  border: Border.all(
                                    color: isSelesai ? HiteraColors.accentGreen : HiteraColors.border,
                                  ),
                                ),
                                child: isSelesai
                                    ? const Icon(Icons.check, size: 14, color: HiteraColors.bgPrimary)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.judul,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: HiteraColors.textPrimary,
                                      decoration: isSelesai ? TextDecoration.lineThrough : null,
                                      decorationColor: HiteraColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule, size: 10, color: HiteraColors.textMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Dibuat: ${formatWaktu(t.createdAt)}',
                                        style: const TextStyle(fontSize: 10, color: HiteraColors.textMuted, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  if (t.deskripsi != null && t.deskripsi!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      t.deskripsi!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 10, color: HiteraColors.textMuted),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: prioritasColor),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    backgroundColor: HiteraColors.bgCard,
                                    title: Text(settings.t('delete_task_confirm'),
                                        style: const TextStyle(color: HiteraColors.textPrimary)),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(c, false), child: Text(settings.t('cancel'))),
                                      TextButton(
                                          onPressed: () => Navigator.pop(c, true),
                                          child: Text(settings.t('delete'), style: const TextStyle(color: HiteraColors.accentRed))),
                                    ],
                                  ),
                                );
                                if (confirm != true || !mounted) return;
                                final err = await prov.hapus(t.id);
                                if (!mounted) return;
                                if (err == null) {
                                  HiteraToast.success(context, settings.t('task_deleted'));
                                } else {
                                  HiteraToast.error(context, settings.t('error'));
                                }
                              },
                              child: const Icon(Icons.delete_outline, color: HiteraColors.textMuted, size: 18),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ];
              }),
          ],
        ),
      ),
    );
  }
}
