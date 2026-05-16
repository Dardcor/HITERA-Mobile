import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/toast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      HiteraToast.error(context, 'Password tidak cocok.');
      return;
    }
    if (_passwordController.text.length < 8) {
      HiteraToast.error(context, 'Password minimal 8 karakter.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await SupabaseService.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _namaController.text.trim(),
      );
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/loading', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        HiteraToast.error(context, 'Registration failed.');
        setState(() => _isLoading = false);
      }
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
                  Image.asset(
                    'image/logo.png',
                    height: 60,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mulai manajemen hidup yang lebih baik',
                    style: TextStyle(color: HiteraColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  _buildField('Nama Lengkap', _namaController, 'John Doe'),
                  const SizedBox(height: 20),
                  _buildField('Email', _emailController, 'nama@email.com',
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  _buildPasswordField('Password (min 8 karakter)', _passwordController, _obscurePassword, () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  }),
                  const SizedBox(height: 20),
                  _buildPasswordField('Konfirmasi Password', _confirmPasswordController, _obscureConfirm, () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  }),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HiteraColors.accentBlue,
                        foregroundColor: HiteraColors.bgPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: HiteraColors.bgPrimary),
                            )
                          : const Text('Daftar', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun? ',
                          style: TextStyle(color: HiteraColors.textSecondary, fontSize: 14)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text('Masuk',
                            style: TextStyle(color: HiteraColors.accentBlue, fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint,
      {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(label, style: const TextStyle(color: HiteraColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
      String label, TextEditingController controller, bool obscure, VoidCallback toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(label, style: const TextStyle(color: HiteraColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: HiteraColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: '••••••••',
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: HiteraColors.textMuted, size: 20),
              onPressed: toggle,
            ),
          ),
        ),
      ],
    );
  }
}
