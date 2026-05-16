import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'home_screen.dart';
import '../keuangan/keuangan_screen.dart';
import '../kesehatan/kesehatan_screen.dart';
import '../tugas/tugas_screen.dart';
import '../pengaturan/pengaturan_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    KeuanganScreen(),
    KesehatanScreen(),
    TugasScreen(),
    PengaturanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: HiteraColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.dashboard_rounded), label: settings.t('home').toUpperCase()),
            BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet_rounded), label: settings.t('finance').toUpperCase()),
            BottomNavigationBarItem(icon: const Icon(Icons.favorite_rounded), label: settings.t('health').toUpperCase()),
            BottomNavigationBarItem(icon: const Icon(Icons.check_box_rounded), label: settings.t('tasks').toUpperCase()),
            BottomNavigationBarItem(icon: const Icon(Icons.settings_rounded), label: settings.t('settings').toUpperCase()),
          ],
        ),
      ),
    );
  }
}
