import 'package:intl/intl.dart';

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
  return DateFormat('yyyy-MM-dd').format(DateTime.now());
}

String tambahHari(String tanggal, int jumlah) {
  final date = DateTime.parse(tanggal).add(Duration(days: jumlah));
  return DateFormat('yyyy-MM-dd').format(date);
}

String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 11) return 'Selamat Pagi';
  if (hour < 15) return 'Selamat Siang';
  if (hour < 18) return 'Selamat Sore';
  return 'Selamat Malam';
}

String formatWaktu(String isoDate) {
  try {
    final date = DateTime.parse(isoDate);
    return DateFormat('HH:mm').format(date);
  } catch (_) {
    return '';
  }
}
