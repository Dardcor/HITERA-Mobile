import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_emailController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await SupabaseService.resetPassword(_emailController.text.trim());
      if (mounted) {
        HiteraToast.success(context, 'Link reset password telah dikirim ke email Anda.');
        setState(() => _isSent = true);
      }
    } catch (e) {
      if (mounted) {
        HiteraToast.error(context, 'Gagal mengirim email reset password.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: HiteraColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: HiteraColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'HITERA',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: HiteraColors.accentBlue,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masukkan email Anda untuk menerima link reset password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: HiteraColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  if (_isSent) ...[
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: HiteraColors.accentGreenDim,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mail_rounded, color: HiteraColors.accentGreen, size: 32),
                    ),
                    const SizedBox(height: 20),
                    const Text('Email Terkirim',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text(
                      'Cek inbox email ${_emailController.text} untuk link reset password.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: HiteraColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Kembali ke Login'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: HiteraColors.textSecondary,
                          side: const BorderSide(color: HiteraColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 6),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Alamat Email',
                            style: TextStyle(color: HiteraColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(hintText: 'nama@email.com'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleSubmit,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: HiteraColors.bgPrimary))
                            : const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('Kirim Link Reset', style: TextStyle(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HiteraColors.accentBlue,
                          foregroundColor: HiteraColors.bgPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back, size: 14, color: HiteraColors.textMuted),
                          SizedBox(width: 6),
                          Text('Kembali ke Login',
                              style: TextStyle(color: HiteraColors.textMuted, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
