import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/supabase_service.dart';
import '../../widgets/toast.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _usernameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _loadingProfile = true;
  bool _savingProfile = false;
  bool _savingPassword = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _fullNameCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    setState(() => _loadingProfile = true);
    try {
      final data = await SupabaseService.fetchProfile(user.id);
      if (data != null) {
        _usernameCtrl.text = data['username'] ?? '';
        _fullNameCtrl.text = data['full_name'] ?? '';
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingProfile = false);
  }

  Future<void> _handleUpdateProfile() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    setState(() => _savingProfile = true);
    try {
      await SupabaseService.updateProfile(
        user.id,
        _usernameCtrl.text.trim(),
        _fullNameCtrl.text.trim(),
      );
      if (mounted) {
        HiteraToast.success(context, 'Profil berhasil disinkronisasi.');
      }
    } catch (e) {
      if (mounted) {
        HiteraToast.error(context, context.read<SettingsProvider>().t('failed_update_profile'));
      }
    }
    if (mounted) setState(() => _savingProfile = false);
  }

  Future<void> _handleChangePassword() async {
    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      HiteraToast.error(context, 'Konfirmasi kata sandi tidak sesuai.');
      return;
    }
    if (_newPasswordCtrl.text.length < 8) {
      HiteraToast.error(context, 'Password minimal 8 karakter.');
      return;
    }
    setState(() => _savingPassword = true);
    try {
      await SupabaseService.changePassword(_newPasswordCtrl.text);
      if (mounted) {
        HiteraToast.success(context, 'Kata sandi berhasil diterapkan.');
        _newPasswordCtrl.clear();
        _confirmPasswordCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        HiteraToast.error(context, context.read<SettingsProvider>().t('failed_update_password'));
      }
    }
    if (mounted) setState(() => _savingPassword = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: HiteraColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profil',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
          Container(
            decoration: BoxDecoration(
              color: HiteraColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HiteraColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: HiteraColors.bgSecondary,
                      border: Border.all(color: HiteraColors.border),
                    ),
                    child: const Icon(Icons.person, color: HiteraColors.accentBlue, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: HiteraColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          auth.user?.email ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: HiteraColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

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
                          color: HiteraColors.bgSecondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person_outline, color: HiteraColors.textPrimary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text('Konfigurasi Identitas',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
                    ],
                  ),
                ),
                const Divider(height: 1, color: HiteraColors.border),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _loadingProfile
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(color: HiteraColors.accentBlue),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Alias Unik (@)'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _usernameCtrl,
                              style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                              decoration: const InputDecoration(hintText: 'username'),
                            ),
                            const SizedBox(height: 16),
                            _label('Nama Lengkap Asli'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _fullNameCtrl,
                              style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                              decoration: const InputDecoration(hintText: 'Nama Lengkap'),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _savingProfile ? null : _handleUpdateProfile,
                                icon: _savingProfile
                                    ? const SizedBox(
                                        width: 18, height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.save_rounded, size: 18),
                                label: const Text('Sinkronisasi Profil',
                                    style: TextStyle(fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: HiteraColors.bgCardHover,
                                  foregroundColor: HiteraColors.textPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          
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
                          color: HiteraColors.accentRedDim,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.lock_outline, color: HiteraColors.accentRed, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text('Pembaruan Sandi',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
                    ],
                  ),
                ),
                const Divider(height: 1, color: HiteraColors.border),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Kata Sandi Baru'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _newPasswordCtrl,
                        obscureText: _obscureNew,
                        style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNew ? Icons.visibility_off : Icons.visibility,
                              color: HiteraColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _label('Konfirmasi Kata Sandi Baru'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _confirmPasswordCtrl,
                        obscureText: _obscureConfirm,
                        style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                              color: HiteraColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _savingPassword ? null : _handleChangePassword,
                          icon: _savingPassword
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.shield_rounded, size: 18),
                          label: const Text('Terapkan Sandi Baru',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HiteraColors.accentRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
}
