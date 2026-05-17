import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz_env;
import 'package:flutter_timezone/flutter_timezone.dart';

import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/keuangan_provider.dart';
import 'providers/kesehatan_provider.dart';
import 'providers/tugas_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';

import 'screens/auth/splash_screen.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/loading_screen.dart';
import 'screens/dashboard/dashboard_shell.dart';
import 'screens/keuangan/keuangan_history_screen.dart';
import 'screens/kesehatan/kesehatan_history_screen.dart';
import 'screens/tugas/tugas_history_screen.dart';
import 'screens/pengaturan/pengaturan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  await initializeDateFormatting('id_ID', null);
  tz.initializeTimeZones();
  try {
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz_env.setLocalLocation(tz_env.getLocation(tzInfo.identifier));
  } catch (e) {
    debugPrint('Could not get local timezone: $e');
  }
  await NotificationService.initialize();

  await Supabase.initialize(
    url: dotenv.env['NEXT_PUBLIC_SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['NEXT_PUBLIC_SUPABASE_ANON_KEY'] ?? '',
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
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            scaffoldMessengerKey: SyncService.scaffoldMessengerKey,
            title: 'HITERA',
            debugShowCheckedModeBanner: false,
            theme: HiteraTheme.lightTheme,
            darkTheme: HiteraTheme.darkTheme,
            themeMode: settings.themeMode,
            home: const _AuthGate(),
            routes: {
              '/landing': (_) => const LandingScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/forgot-password': (_) => const ForgotPasswordScreen(),
              '/loading': (_) => const LoadingScreen(),
              '/dashboard': (_) => const DashboardShell(),
              '/keuangan-history': (_) => const KeuanganHistoryScreen(),
              '/kesehatan-history': (_) => const KesehatanHistoryScreen(),
              '/tugas-history': (_) => const TugasHistoryScreen(),
              '/pengaturan': (_) => const PengaturanScreen(),
            },
          );
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
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) return const SplashScreen();

    final auth = context.watch<AuthProvider>();

    if (auth.loading) return const SplashScreen();

    if (auth.isAuthenticated) return const DashboardShell();

    return const LandingScreen();
  }
}
