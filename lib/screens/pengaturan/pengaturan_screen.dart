import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

import 'profil_screen.dart';
import 'notifikasi_screen.dart';
import 'kontrol_data_screen.dart';
import 'bahasa_screen.dart';

class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  Future<void> _showLogoutDialog(BuildContext context, AuthProvider auth, SettingsProvider settings) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HiteraColors.bgCard,
        title: Text(settings.t('logout'), style: const TextStyle(color: HiteraColors.textPrimary)),
        content: Text(
          settings.t('logout_confirm'),
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
            child: Text(settings.t('logout')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await auth.signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    }
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = HiteraColors.textPrimary,
    bool showArrow = true,
    Widget? trailing,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: HiteraColors.border)),
      ),
      child: Material(
        color: HiteraColors.bgCard,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
                if (trailing != null) trailing
                else if (showArrow)
                  const Icon(Icons.chevron_right, color: HiteraColors.textMuted, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(settings.t('settings'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: HiteraColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HiteraColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  title: settings.t('profile'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilScreen())),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.notifications_none_rounded,
                  title: settings.t('notifications'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiScreen())),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.delete_outline_rounded,
                  title: settings.t('data_control'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KontrolDataScreen())),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.language_rounded,
                  title: settings.t('language'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BahasaScreen())),
                ),
                _buildMenuItem(
                  context,
                  icon: settings.themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  title: 'Tema',
                  trailing: Text(
                    settings.themeMode == ThemeMode.dark ? 'Gelap' : 'Terang',
                    style: const TextStyle(color: HiteraColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    settings.toggleTheme();
                    settings.updateTheme(auth.user!.id);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: settings.t('logout'),
                  color: HiteraColors.accentRed,
                  showArrow: false,
                  onTap: () => _showLogoutDialog(context, auth, settings),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Center(
            child: Column(
              children: [
                Text(
                  'HITERA VERSION 2.0.0',
                  style: TextStyle(
                    fontSize: 10,
                    color: HiteraColors.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '© 2026 Dardcor Hitera',
                  style: TextStyle(
                    fontSize: 10,
                    color: HiteraColors.textMuted,
                    letterSpacing: -0.3,
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
