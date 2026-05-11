import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/tugas_provider.dart';
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

  void _showAddModal() {
    final judulCtrl = TextEditingController();
    final deskripsiCtrl = TextEditingController();
    String prioritas = 'sedang';
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
                    const Text('Tambah Tugas Baru',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close, color: HiteraColors.textMuted, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _label('Judul Tugas'),
                const SizedBox(height: 6),
                TextField(
                  controller: judulCtrl,
                  style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'Contoh: Beli susu'),
                ),
                const SizedBox(height: 16),
                _label('Deskripsi (Opsional)'),
                const SizedBox(height: 6),
                TextField(
                  controller: deskripsiCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'Tambahkan detail...'),
                ),
                const SizedBox(height: 16),
                _label('Prioritas'),
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
                                p[0].toUpperCase() + p.substring(1),
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
                        if (judulCtrl.text.trim().isEmpty) return;
                        setModalState(() => isSubmitting = true);
                        final err = await context.read<TugasProvider>().tambah(
                          judul: judulCtrl.text.trim(),
                          deskripsi: deskripsiCtrl.text.isNotEmpty ? deskripsiCtrl.text : null,
                          prioritas: prioritas,
                        );
                        if (ctx.mounted) {
                          setModalState(() => isSubmitting = false);
                          Navigator.pop(ctx);
                        }
                        if (mounted) {
                          if (err == null) {
                            HiteraToast.success(context, 'Tugas berhasil ditambahkan.');
                          } else {
                            HiteraToast.error(context, 'Gagal menambahkan tugas.');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HiteraColors.accentBlue,
                        foregroundColor: HiteraColors.bgPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Tambah Tugas', style: TextStyle(fontWeight: FontWeight.w600)),
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

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TugasProvider>();

    final displayTugas = _filter == 'semua'
        ? prov.tugas
        : _filter == 'aktif'
            ? prov.tugasAktif
            : prov.tugasSelesai;

    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daftar Tugas',
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
            icon: const Icon(Icons.add_rounded, color: HiteraColors.accentBlue),
            onPressed: _showAddModal,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: HiteraColors.accentBlue,
        onRefresh: prov.fetch,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Progress card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: HiteraColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: HiteraColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('PROGRESS HARI INI',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: HiteraColors.textMuted, letterSpacing: 1.5)),
                      Text('${prov.progress}% Selesai',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: HiteraColors.accentBlue)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: HiteraColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: prov.progress / 100,
                          backgroundColor: HiteraColors.bgSecondary,
                          valueColor: const AlwaysStoppedAnimation(HiteraColors.accentBlue),
                          minHeight: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${prov.tugasSelesai.length} dari ${prov.tugas.length} tugas berhasil diselesaikan',
                    style: const TextStyle(fontSize: 12, color: HiteraColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filter tabs + history link
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      return GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? HiteraColors.bgCard : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: isSelected
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
                                : null,
                          ),
                          child: Text(
                            f[0].toUpperCase() + f.substring(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? HiteraColors.accentBlue : HiteraColors.textMuted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/tugas-history'),
                  child: const Text('History Tugas',
                      style: TextStyle(fontSize: 12, color: HiteraColors.accentBlue, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Task list
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
                    const Text('Tidak ada tugas dalam kategori ini.',
                        style: TextStyle(color: HiteraColors.textMuted, fontStyle: FontStyle.italic)),
                  ],
                ),
              )
            else
              ...displayTugas.map((t) {
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
                    border: Border.all(
                      color: isSelesai ? HiteraColors.border : HiteraColors.border,
                    ),
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
                              HiteraToast.error(context, 'Gagal memperbarui status tugas.');
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
                              if (t.deskripsi != null && t.deskripsi!.isNotEmpty)
                                Text(
                                  t.deskripsi!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10, color: HiteraColors.textMuted),
                                ),
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
                                title: const Text('Hapus tugas ini?',
                                    style: TextStyle(color: HiteraColors.textPrimary)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                                  TextButton(
                                      onPressed: () => Navigator.pop(c, true),
                                      child: const Text('Hapus', style: TextStyle(color: HiteraColors.accentRed))),
                                ],
                              ),
                            );
                            if (confirm != true || !mounted) return;
                            final err = await prov.hapus(t.id);
                            if (!mounted) return;
                            if (err == null) {
                              HiteraToast.success(context, 'Tugas berhasil dihapus.');
                            } else {
                              HiteraToast.error(context, 'Gagal menghapus tugas.');
                            }
                          },
                          child: const Icon(Icons.delete_outline, color: HiteraColors.textMuted, size: 18),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
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
}
