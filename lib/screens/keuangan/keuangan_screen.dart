import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/keuangan_provider.dart';
import '../../utils/utils.dart';
import '../../widgets/toast.dart';

class KeuanganScreen extends StatefulWidget {
  const KeuanganScreen({super.key});

  @override
  State<KeuanganScreen> createState() => _KeuanganScreenState();
}

class _KeuanganScreenState extends State<KeuanganScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KeuanganProvider>().fetch();
    });
  }

  void _showAddModal() {
    String jenis = 'pengeluaran';
    final jumlahCtrl = TextEditingController();
    String kategori = '';
    final deskripsiCtrl = TextEditingController();
    String tanggal = context.read<KeuanganProvider>().tanggal;
    bool isSubmitting = false;

    const kategoriPemasukan = ['Gaji', 'Freelance', 'Investasi', 'Hadiah', 'Lainnya'];
    const kategoriPengeluaran = ['Makanan', 'Transport', 'Belanja', 'Tagihan', 'Kesehatan', 'Hiburan', 'Pendidikan', 'Lainnya'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HiteraColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final kategoriList = jenis == 'pemasukan' ? kategoriPemasukan : kategoriPengeluaran;
          if (kategori.isEmpty || !kategoriList.contains(kategori)) {
            kategori = kategoriList.first;
          }

          return Padding(
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
                      const Text('Tambah Transaksi',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close, color: HiteraColors.textMuted, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: HiteraColors.bgSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: HiteraColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => jenis = 'pemasukan'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: jenis == 'pemasukan' ? HiteraColors.accentGreen : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text('Pemasukan',
                                    style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w700,
                                      color: jenis == 'pemasukan' ? HiteraColors.bgPrimary : HiteraColors.textMuted,
                                    )),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => jenis = 'pengeluaran'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: jenis == 'pengeluaran' ? HiteraColors.accentRed : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text('Pengeluaran',
                                    style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w700,
                                      color: jenis == 'pengeluaran' ? Colors.white : HiteraColors.textMuted,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Jumlah (Rp)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: jumlahCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(hintText: '0'),
                  ),
                  const SizedBox(height: 16),
                  _label('Kategori'),
                  const SizedBox(height: 6),
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
                        value: kategori,
                        dropdownColor: HiteraColors.bgCard,
                        style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                        items: kategoriList.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                        onChanged: (v) => setModalState(() => kategori = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Tanggal'),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.parse(tanggal),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setModalState(() {
                          tanggal = picked.toIso8601String().split('T').first;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: HiteraColors.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: HiteraColors.border),
                      ),
                      child: Text(formatTanggalID(tanggal),
                          style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Deskripsi (Opsional)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: deskripsiCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(hintText: 'Contoh: Makan siang di kantor'),
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
                          final jumlah = double.tryParse(jumlahCtrl.text);
                          if (jumlah == null || jumlah <= 0) return;
                          setModalState(() => isSubmitting = true);
                          final err = await context.read<KeuanganProvider>().tambah(
                            jenis: jenis,
                            jumlah: jumlah,
                            kategori: kategori,
                            deskripsi: deskripsiCtrl.text.isNotEmpty ? deskripsiCtrl.text : null,
                            tanggal: tanggal,
                          );
                          if (ctx.mounted) {
                            setModalState(() => isSubmitting = false);
                            Navigator.pop(ctx);
                          }
                          if (mounted) {
                            if (err == null) {
                              HiteraToast.success(context, 'Transaksi berhasil ditambahkan.');
                            } else {
                              HiteraToast.error(context, 'Gagal menambahkan transaksi.');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HiteraColors.accentBlue,
                          foregroundColor: HiteraColors.bgPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(text,
          style: const TextStyle(color: HiteraColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<KeuanganProvider>();

    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Keuangan Harian',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
            const SizedBox(height: 4),
            Row(
              children: [
                _navButton(Icons.chevron_left, prov.prevDay),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: prov.resetToToday,
                  child: Text(
                    formatTanggalID(prov.tanggal),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: HiteraColors.accentBlue),
                  ),
                ),
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
            // Summary cards
            Row(
              children: [
                Expanded(child: _summaryTile('TOTAL PEMASUKAN', prov.totalPemasukan, HiteraColors.accentGreen, Icons.trending_up, prov.loading)),
                const SizedBox(width: 8),
                Expanded(child: _summaryTile('TOTAL PENGELUARAN', prov.totalPengeluaran, HiteraColors.accentRed, Icons.trending_down, prov.loading)),
              ],
            ),
            const SizedBox(height: 8),
            _summaryTile('SALDO BERSIH', prov.saldoBersih, HiteraColors.accentBlue, Icons.account_balance_wallet, prov.loading),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TRANSAKSI HARI INI',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary, letterSpacing: 1.5)),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/keuangan-history'),
                  child: const Text('Lihat Semua History',
                      style: TextStyle(fontSize: 12, color: HiteraColors.accentBlue, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (prov.loading)
              ...List.generate(3, (_) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: HiteraColors.bgCardHover,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ))
            else if (prov.transaksi.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                decoration: BoxDecoration(
                  color: HiteraColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: HiteraColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: HiteraColors.bgSecondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: HiteraColors.textMuted, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text('Tidak ada transaksi pada tanggal ini.',
                        style: TextStyle(color: HiteraColors.textMuted, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _showAddModal,
                      child: const Text('Tambah sekarang', style: TextStyle(color: HiteraColors.textSecondary)),
                    ),
                  ],
                ),
              )
            else
              ...prov.transaksi.map((t) {
                final isPemasukan = t.jenis == 'pemasukan';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: HiteraColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: HiteraColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: isPemasukan ? HiteraColors.accentGreenDim : HiteraColors.accentRedDim,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getKategoriIcon(t.kategori),
                          color: isPemasukan ? HiteraColors.accentGreen : HiteraColors.accentRed,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.kategori,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
                            Text(t.deskripsi ?? 'Tidak ada deskripsi',
                                style: const TextStyle(fontSize: 10, color: HiteraColors.textMuted, letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(isPemasukan ? Icons.add : Icons.remove,
                                  size: 12, color: isPemasukan ? HiteraColors.accentGreen : HiteraColors.accentRed),
                              Text(formatRupiah(t.jumlah),
                                  style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w700,
                                    color: isPemasukan ? HiteraColors.accentGreen : HiteraColors.accentRed,
                                  )),
                            ],
                          ),
                          Text(formatWaktu(t.createdAt),
                              style: const TextStyle(fontSize: 10, color: HiteraColors.textMuted)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              backgroundColor: HiteraColors.bgCard,
                              title: const Text('Hapus transaksi ini?', style: TextStyle(color: HiteraColors.textPrimary)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                                TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus', style: TextStyle(color: HiteraColors.accentRed))),
                              ],
                            ),
                          );
                          if (confirm != true || !mounted) return;
                          final err = await prov.hapus(t.id);
                          if (!mounted) return;
                          if (err == null) {
                            HiteraToast.success(context, 'Transaksi berhasil dihapus.');
                          } else {
                            HiteraToast.error(context, 'Gagal menghapus transaksi.');
                          }
                        },
                        child: const Icon(Icons.delete_outline, color: HiteraColors.textMuted, size: 18),
                      ),
                    ],
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

  Widget _summaryTile(String label, double value, Color color, IconData icon, bool loading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HiteraColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 9, color: HiteraColors.textMuted, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(loading ? '...' : formatRupiah(value),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: label == 'SALDO BERSIH' ? HiteraColors.textPrimary : color)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ],
      ),
    );
  }

  IconData _getKategoriIcon(String kategori) {
    final k = kategori.toLowerCase();
    if (k.contains('makan')) return Icons.restaurant;
    if (k.contains('transport')) return Icons.directions_car;
    if (k.contains('belanja')) return Icons.shopping_bag;
    if (k.contains('tagihan')) return Icons.receipt_long;
    if (k.contains('kesehatan')) return Icons.favorite;
    if (k.contains('hiburan')) return Icons.sports_esports;
    if (k.contains('pendidikan')) return Icons.school;
    if (k.contains('gaji') || k.contains('pekerjaan')) return Icons.work;
    return Icons.work;
  }
}
