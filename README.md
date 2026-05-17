# Hitera - Mobile Application

Hitera adalah platform manajemen kesehatan dan produktivitas terintegrasi premium yang dirancang untuk membantu pengguna melacak aktivitas kesehatan harian (air minum, jam tidur, olahraga, dan catatan) serta mengelola tugas harian secara efisien dengan sinkronisasi waktu nyata.

Repository ini berisi kode sumber untuk **Aplikasi Mobile** yang dibangun menggunakan framework Flutter untuk perangkat Android dan iOS.

---

## 🚀 Fitur Utama

- **Dashboard Keuangan & Finansial**: Pemantauan transaksi pendapatan dan pengeluaran secara visual, dinamis, dan terintegrasi dengan diagram lingkaran.
- **Manajemen Kesehatan (Health Tracker)**:
  - Pelacakan jumlah gelas air minum harian secara cepat.
  - Pelacakan durasi tidur (jam).
  - Pelacakan durasi olahraga (jam & menit) secara detail.
  - Catatan harian kesehatan dengan dukungan UI premium.
  - Grafik tren dan visualisasi riwayat kesehatan lengkap tanpa batasan hari (selalu tersimpan).
- **Manajemen Tugas & Produktivitas (Task Management)**:
  - Pembuatan tugas dengan prioritas (Rendah, Sedang, Tinggi) berbasis warna.
  - Penentuan batas waktu (tanggal dan jam deadline) yang dinamis dan terpotong secara aman tanpa kendala layout overflow.
  - Tampilan informasi waktu pembuatan tugas yang presisi dan tersinkronisasi sempurna dengan web dashboard.
- **Sistem Notifikasi Real-time**: Pemberitahuan push-notification lokal dan database untuk pengingat penting.
- **Multi-bahasa Premium (Localization)**: Dukungan penuh 5 bahasa: Indonesia, Inggris, Melayu, Jepang, dan Mandarin yang berubah seketika di seluruh halaman tanpa restart aplikasi.

---

## 🛠️ Stack Teknologi

- **Framework Utama**: Flutter SDK
- **Bahasa Pemrograman**: Dart
- **State Management**: Provider (SettingsProvider, TugasProvider, KeseharianProvider, KeuanganProvider)
- **Database & Otentikasi**: Supabase Flutter Client (`supabase_flutter`)
- **Manajemen Tanggal & Waktu**: `intl` untuk format tanggal lokal dan manipulasi zona waktu.
- **Desain UI**: Material Design 3 dengan skema warna gelap premium yang dikustomisasi secara presisi.

---

## ⚙️ Persyaratan Sistem

Sebelum memulai pengembangan, pastikan Anda telah menyiapkan:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Versi stable terbaru)
- [Dart SDK](https://dart.dev/get-started) (Disertakan bersama Flutter SDK)
- [Android Studio](https://developer.android.com/studio) / [VS Code](https://code.visualstudio.com/) dengan ekstensi Flutter & Dart terinstal.
- Emulator Android / iOS Simulator atau Perangkat Fisik (Handphone) untuk pengujian.
- Akun [Supabase](https://supabase.com/) untuk backend database dan otentikasi.

---

## 💻 Cara Instalasi & Menjalankan Project

### 1. Clone Repository & Masuk ke Direktori
```bash
git clone <repository-url>
cd hitera_mobile
```

### 2. Instalasi Paket Dependensi
Jalankan perintah flutter pub get untuk mengunduh semua paket dependensi proyek yang terdaftar di `pubspec.yaml`:
```bash
flutter pub get
```

### 3. Konfigurasi Environment Variables
Salin file konfigurasi contoh `.env.example` menjadi `.env` baru pada root direktori:
```bash
cp .env.example .env
```
Buka file `.env` dan masukkan kredensial Supabase Anda:
```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
```

### 4. Analisis Kode & Uji Coba Sintaks
Pastikan tidak ada kesalahan penulisan kode atau dependensi yang usang sebelum memulai build:
```bash
flutter analyze
```

### 5. Menjalankan Aplikasi
Hubungkan emulator atau perangkat fisik Anda ke laptop, lalu jalankan perintah:
```bash
flutter run
```

---

## 📂 Struktur Direktori Utama

```text
hitera_mobile/
├── android/             # Konfigurasi platform Android asli
├── ios/                 # Konfigurasi platform iOS asli
├── lib/
│   ├── config/          # Konfigurasi aplikasi (Tema, warna kustom HiteraColors)
│   ├── l10n/            # Lokalisasi bahasa (translations.dart)
│   ├── models/          # Definisi kelas Model Data (Tugas, DataKesehatan, Transaksi)
│   ├── providers/       # State Management Providers (TugasProvider, KeuanganProvider, dll)
│   ├── screens/         # Tampilan Halaman UI (Dashboard, Kesehatan, Tugas, Keuangan, Pengaturan)
│   ├── services/        # Service eksternal (SupabaseService)
│   ├── utils/           # Helper fungsionalitas (Waktu, Pemformatan Tanggal, Lokalisasi)
│   ├── widgets/         # Komponen Widget kustom yang dapat digunakan kembali (Toast, dll)
│   └── main.dart        # Titik masuk utama aplikasi (Main Entry Point)
├── .env.example         # File contoh environment variables untuk Supabase
├── pubspec.yaml         # Konfigurasi dependensi dan aset Flutter
└── README.md            # Dokumentasi ini
```
