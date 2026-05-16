import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/supabase_service.dart';
import '../../widgets/toast.dart';

class KontrolDataScreen extends StatefulWidget {
  const KontrolDataScreen({super.key});

  @override
  State<KontrolDataScreen> createState() => _KontrolDataScreenState();
}

class _KontrolDataScreenState extends State<KontrolDataScreen> {
  bool _isDeleting = false;

  Future<void> _showDeleteConfirmation() async {
    final settings = context.read<SettingsProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HiteraColors.bgCard,
        title: Text(settings.t('delete_all_data'), style: const TextStyle(color: HiteraColors.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(
          settings.t('delete_confirm_message'),
          style: const TextStyle(color: HiteraColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(settings.t('cancel'), style: const TextStyle(color: HiteraColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HiteraColors.accentRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(settings.t('delete_all')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteAllData();
    }
  }

  Future<void> _deleteAllData() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final settings = context.read<SettingsProvider>();

    setState(() => _isDeleting = true);

    try {
      await SupabaseService.deleteAllUserData(user.id);
      if (mounted) {
        HiteraToast.success(context, settings.t('data_deleted_success'));
      }
    } catch (e) {
      if (mounted) {
        HiteraToast.error(context, settings.t('data_delete_failed'));
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: HiteraColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(settings.t('data_control'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: HiteraColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HiteraColors.accentRedDim),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HiteraColors.accentRedDim,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: HiteraColors.accentRed, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      settings.t('danger_zone'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HiteraColors.accentRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  settings.t('danger_zone_desc'),
                  style: const TextStyle(color: HiteraColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isDeleting ? null : _showDeleteConfirmation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HiteraColors.accentRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isDeleting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(settings.t('delete_all_data'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
