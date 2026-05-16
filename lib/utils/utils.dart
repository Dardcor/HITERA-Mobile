import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';




DateTime nowWIB() {
  final now = DateTime.now();
  final utc = now.toUtc();
  
  return DateTime(
    utc.year, utc.month, utc.day,
    utc.hour + 7, utc.minute, utc.second, utc.millisecond,
  );
}

String formatRupiah(double angka) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  return formatter.format(angka);
}

String formatTanggalID(String tanggal) {
  try {
    final date = DateTime.parse(tanggal);
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  } catch (_) {
    return tanggal;
  }
}

String formatTanggalSingkat(String tanggal) {
  try {
    final date = DateTime.parse(tanggal);
    return DateFormat('d MMM', 'id_ID').format(date);
  } catch (_) {
    return tanggal;
  }
}

String hariIni() {
  return DateFormat('yyyy-MM-dd').format(nowWIB());
}

String tambahHari(String tanggal, int jumlah) {
  final date = DateTime.parse(tanggal).add(Duration(days: jumlah));
  return DateFormat('yyyy-MM-dd').format(date);
}

String getGreeting(SettingsProvider settings) {
  final hour = DateTime.now().hour;
  if (hour < 12) return settings.t('greeting_morning');
  if (hour < 15) return settings.t('greeting_afternoon');
  if (hour < 18) return settings.t('greeting_evening');
  return settings.t('greeting_night');
}

String formatWaktu(String isoDate) {
  try {
    final date = DateTime.parse(isoDate);
    return DateFormat('HH:mm - d MMM yyyy', 'id_ID').format(date);
  } catch (_) {
    return '';
  }
}
