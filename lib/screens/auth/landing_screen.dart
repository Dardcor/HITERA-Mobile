import 'package:flutter/material.dart';
import '../../config/theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: HiteraColors.border)),
              ),
              child: Row(
                children: [
                  Image.asset('image/logo.png', height: 32),
                  const SizedBox(width: 12),
                  const Text(
                    'HITERA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: HiteraColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Masuk', style: TextStyle(color: HiteraColors.textPrimary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HiteraColors.accentBlue,
                      foregroundColor: HiteraColors.bgPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Daftar'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: HiteraColors.textPrimary, height: 1.2),
                          children: [
                            TextSpan(text: 'Atur Hidup Jadi\n'),
                            TextSpan(text: 'Lebih Mudah', style: TextStyle(color: HiteraColors.accentBlue)),
                            TextSpan(text: ' & Presisi'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Aplikasi personal life-management untuk mengontrol keuangan, memantau kesehatan, dan mengelola tugas harian Anda dalam satu tempat yang futuristik.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: HiteraColors.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HiteraColors.accentBlue,
                            foregroundColor: HiteraColors.bgPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Buka Akun Gratis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: HiteraColors.textPrimary,
                            side: const BorderSide(color: HiteraColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                          child: const Text('Masuk ke Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 64),
                      const Divider(color: HiteraColors.border),
                      const SizedBox(height: 48),
                      _buildFeatureCard(
                        icon: Icons.account_balance_wallet_rounded,
                        color: HiteraColors.accentBlue,
                        dimColor: HiteraColors.bgSecondary,
                        title: 'Keuangan',
                        desc: 'Pencatatan pemasukan dan pengeluaran harian dengan ringkasan saldo yang akurat.',
                      ),
                      const SizedBox(height: 24),
                      _buildFeatureCard(
                        icon: Icons.favorite_rounded,
                        color: HiteraColors.accentGreen,
                        dimColor: HiteraColors.bgSecondary,
                        title: 'Kesehatan',
                        desc: 'Pantau berat badan, asupan air, jam tidur, dan metrik kesehatan lainnya setiap hari.',
                      ),
                      const SizedBox(height: 24),
                      _buildFeatureCard(
                        icon: Icons.check_box_rounded,
                        color: HiteraColors.accentRed,
                        dimColor: HiteraColors.bgSecondary,
                        title: 'Tugas',
                        desc: 'Kelola daftar kegiatan dengan prioritas dan pantau progress penyelesaiannya.',
                      ),
                      const SizedBox(height: 64),
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: HiteraColors.bgSecondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text('Kenapa HITERA?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: HiteraColors.textPrimary)),
                            const SizedBox(height: 8),
                            const Text('Didesain untuk efisiensi dan fokus maksimal.', style: TextStyle(color: HiteraColors.textSecondary)),
                            const SizedBox(height: 32),
                            _buildWhyCard(Icons.security_rounded, 'Privasi Terjamin', 'Data Anda tersimpan aman dengan enkripsi tingkat lanjut di Supabase.'),
                            const SizedBox(height: 24),
                            _buildWhyCard(Icons.flash_on_rounded, 'Cepat & Ringan', 'Dioptimalkan untuk performa maksimal di semua device.'),
                            const SizedBox(height: 24),
                            _buildWhyCard(Icons.smartphone_rounded, 'Mobile Native', 'Akses lancar langsung dari smartphone Anda.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      const Divider(color: HiteraColors.border),
                      const SizedBox(height: 24),
                      const Text(
                        '© 2026 HITERA Application. Dibuat dengan presisi.',
                        style: TextStyle(color: HiteraColors.textMuted, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required Color color, required Color dimColor, required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: HiteraColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HiteraColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: dimColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: HiteraColors.textPrimary)),
          const SizedBox(height: 12),
          Text(desc, style: const TextStyle(color: HiteraColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildWhyCard(IconData icon, String title, String desc) {
    return Column(
      children: [
        Icon(icon, color: HiteraColors.accentBlue, size: 32),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HiteraColors.textPrimary)),
        const SizedBox(height: 8),
        Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: HiteraColors.textMuted)),
      ],
    );
  }
}
