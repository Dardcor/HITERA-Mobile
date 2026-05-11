import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/keseharian_provider.dart';
import '../../utils/utils.dart';
import '../../widgets/toast.dart';

class KeseharianScreen extends StatefulWidget {
  const KeseharianScreen({super.key});

  @override
  State<KeseharianScreen> createState() => _KeseharianScreenState();
}

class _KeseharianScreenState extends State<KeseharianScreen> {
  final _todoController = TextEditingController();
  late TextEditingController _jurnalController;
  bool _jurnalInitialized = false;

  @override
  void initState() {
    super.initState();
    _jurnalController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KeseharianProvider>().fetch();
    });
  }

  @override
  void dispose() {
    _todoController.dispose();
    _jurnalController.dispose();
    super.dispose();
  }

  void _addTodo() async {
    final text = _todoController.text.trim();
    if (text.isEmpty) return;

    final err = await context.read<KeseharianProvider>().addTodo(text);
    if (mounted) {
      if (err == null) {
        _todoController.clear();
      } else {
        HiteraToast.error(context, 'Gagal menambah tugas.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<KeseharianProvider>();

    // Sync jurnal controller with provider data after initial load
    if (!_jurnalInitialized && !prov.loading) {
      _jurnalController.text = prov.jurnal;
      _jurnalInitialized = true;
    }

    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Jurnal & Tugas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
            const SizedBox(height: 4),
            Text(
              formatTanggalID(prov.tanggal),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: HiteraColors.accentBlue),
            ),
          ],
        ),
      ),
      body: prov.loading
          ? const Center(
              child: CircularProgressIndicator(color: HiteraColors.accentBlue),
            )
          : RefreshIndicator(
              color: HiteraColors.accentBlue,
              onRefresh: () async {
                _jurnalInitialized = false;
                await prov.fetch();
                _jurnalController.text = prov.jurnal;
                _jurnalInitialized = true;
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // === TUGAS HARIAN SECTION ===
                  Container(
                    decoration: BoxDecoration(
                      color: HiteraColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: HiteraColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: HiteraColors.accentBlueDim,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.checklist_rounded, color: HiteraColors.accentBlue, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text('Tugas Harian',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: HiteraColors.border),

                        // Add todo input
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _todoController,
                                  style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                                  decoration: const InputDecoration(
                                    hintText: 'Tambahkan tugas baru...',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                  onSubmitted: (_) => _addTodo(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _addTodo,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: HiteraColors.accentBlue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.add, color: HiteraColors.bgPrimary, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Todo list
                        if (prov.todos.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.check_circle_outline, color: HiteraColors.textMuted, size: 48),
                                  SizedBox(height: 12),
                                  Text('Tidak ada tugas dalam antrean.',
                                      style: TextStyle(color: HiteraColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
                                  SizedBox(height: 4),
                                  Text('Nikmati waktu luang Anda atau tambahkan tugas.',
                                      style: TextStyle(color: HiteraColors.textMuted, fontSize: 12)),
                                ],
                              ),
                            ),
                          )
                        else
                          ...prov.todos.map((todo) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: HiteraColors.border.withValues(alpha: 0.5))),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => prov.toggleTodo(todo.id, todo.done),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: todo.done ? HiteraColors.accentBlue : Colors.transparent,
                                          border: Border.all(
                                            color: todo.done ? HiteraColors.accentBlue : HiteraColors.border,
                                            width: 2,
                                          ),
                                        ),
                                        child: todo.done
                                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        todo.text,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: todo.done ? FontWeight.w400 : FontWeight.w500,
                                          color: todo.done ? HiteraColors.textMuted : HiteraColors.textPrimary,
                                          decoration: todo.done ? TextDecoration.lineThrough : null,
                                          decorationColor: HiteraColors.textMuted,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        final err = await prov.deleteTodo(todo.id);
                                        if (err != null && mounted) {
                                          HiteraToast.error(context, 'Gagal menghapus tugas.');
                                        }
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Icon(Icons.close, color: HiteraColors.textMuted, size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // === JURNAL SECTION ===
                  Container(
                    decoration: BoxDecoration(
                      color: HiteraColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: HiteraColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: HiteraColors.accentYellowDim,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.edit_note_rounded, color: HiteraColors.accentYellow, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Catatan & Jurnal',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
                                      SizedBox(height: 2),
                                      Text('Kebebasan untuk menuangkan isi pikiran Anda.',
                                          style: TextStyle(fontSize: 11, color: HiteraColors.textMuted)),
                                    ],
                                  ),
                                ],
                              ),
                              if (prov.savingJurnal)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: HiteraColors.accentYellowDim,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: HiteraColors.accentYellow.withValues(alpha: 0.3)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 12, height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          color: HiteraColors.accentYellow,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Text('Menyimpan...',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: HiteraColors.accentYellow)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: HiteraColors.border),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: _jurnalController,
                            maxLines: 10,
                            minLines: 6,
                            style: const TextStyle(
                              color: HiteraColors.textPrimary,
                              fontSize: 15,
                              height: 1.8,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Mulai mengetik pemikiran Anda di sini...',
                              fillColor: HiteraColors.bgPrimary.withValues(alpha: 0.4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: prov.savingJurnal ? HiteraColors.accentYellow : HiteraColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: prov.savingJurnal ? HiteraColors.accentYellow : HiteraColors.border,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              prov.updateJurnal(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
