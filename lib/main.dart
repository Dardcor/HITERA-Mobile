import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/keuangan_provider.dart';
import 'providers/kesehatan_provider.dart';
import 'providers/tugas_provider.dart';

import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/dashboard/dashboard_shell.dart';
import 'screens/keuangan/keuangan_history_screen.dart';
import 'screens/kesehatan/kesehatan_history_screen.dart';
import 'screens/tugas/tugas_history_screen.dart';
import 'screens/pengaturan/pengaturan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: 'https://qgcycervjrnercscdayo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFnY3ljZXJ2anJuZXJjc2NkYXlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcwMTUxNTIsImV4cCI6MjA5MjU5MTE1Mn0.-Kd80p-5vigZkSbWtg0YvI7ioPdMTOHNSMyST0IUpkc',
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: HiteraColors.bgCard,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const HiteraApp());
}

class HiteraApp extends StatelessWidget {
  const HiteraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => KeuanganProvider()),
        ChangeNotifierProvider(create: (_) => KesehatanProvider()),
        ChangeNotifierProvider(create: (_) => TugasProvider()),

      ],
      child: MaterialApp(
        title: 'HITERA',
        debugShowCheckedModeBanner: false,
        theme: HiteraTheme.darkTheme,
        home: const _AuthGate(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/forgot-password': (_) => const ForgotPasswordScreen(),
          '/dashboard': (_) => const DashboardShell(),
          '/keuangan-history': (_) => const KeuanganHistoryScreen(),
          '/kesehatan-history': (_) => const KesehatanHistoryScreen(),
          '/tugas-history': (_) => const TugasHistoryScreen(),
          '/pengaturan': (_) => const PengaturanScreen(),
        },
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) return const SplashScreen();

    final auth = context.watch<AuthProvider>();

    if (auth.loading) return const SplashScreen();

    if (auth.isAuthenticated) return const DashboardShell();

    return const LoginScreen();
  }
}
