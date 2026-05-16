import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class BahasaScreen extends StatefulWidget {
  const BahasaScreen({super.key});

  @override
  State<BahasaScreen> createState() => _BahasaScreenState();
}

class _BahasaScreenState extends State<BahasaScreen> {
  final List<Map<String, String>> _bahasaOptions = [
    {'value': 'id', 'label': '🇮🇩 Indonesia'},
    {'value': 'en', 'label': '🇬🇧 English'},
    {'value': 'ms', 'label': '🇲🇾 Melayu'},
    {'value': 'ja', 'label': '🇯🇵 日本語'},
    {'value': 'zh', 'label': '🇨🇳 中文'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<SettingsProvider>().loadSettings(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: HiteraColors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: HiteraColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Bahasa',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: HiteraColors.textPrimary)),
      ),
      body: settings.loading
          ? const Center(child: CircularProgressIndicator(color: HiteraColors.accentBlue))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bahasaOptions.length,
              itemBuilder: (context, index) {
                final option = _bahasaOptions[index];
                final isSelected = settings.bahasa == option['value'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: HiteraColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? HiteraColors.accentBlue : HiteraColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (auth.user != null) {
                        context.read<SettingsProvider>().updateBahasa(auth.user!.id, option['value']!);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option['label']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: HiteraColors.textPrimary,
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: HiteraColors.accentBlue),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
