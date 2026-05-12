class Transaksi {
  final String id;
  final String userId;
  final String jenis; // 'pemasukan' | 'pengeluaran'
  final double jumlah;
  final String kategori;
  final String? deskripsi;
  final String tanggal;
  final String createdAt;

  Transaksi({
    required this.id,
    required this.userId,
    required this.jenis,
    required this.jumlah,
    required this.kategori,
    this.deskripsi,
    required this.tanggal,
    required this.createdAt,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      jenis: json['jenis'] as String,
      jumlah: (json['jumlah'] as num).toDouble(),
      kategori: json['kategori'] as String,
      deskripsi: json['deskripsi'] as String?,
      tanggal: json['tanggal'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    return {
      'user_id': userId,
      'jenis': jenis,
      'jumlah': jumlah,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'tanggal': tanggal,
    };
  }
}

class DataKesehatan {
  final String id;
  final String userId;
  final String tanggal;
  final int? airMinum;
  final double? jamTidur;
  final String? catatan;
  final String createdAt;

  DataKesehatan({
    required this.id,
    required this.userId,
    required this.tanggal,
    this.airMinum,
    this.jamTidur,
    this.catatan,
    required this.createdAt,
  });

  factory DataKesehatan.fromJson(Map<String, dynamic> json) {
    return DataKesehatan(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tanggal: json['tanggal'] as String,
      airMinum: json['air_minum'] as int?,
      jamTidur: (json['jam_tidur'] as num?)?.toDouble(),
      catatan: json['catatan'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}

class Tugas {
  final String id;
  final String userId;
  final String judul;
  final String? deskripsi;
  final String prioritas; // 'rendah' | 'sedang' | 'tinggi'
  final String status; // 'aktif' | 'selesai' | 'ditunda'
  final String tanggalTarget;
  final String? deadline;
  final String? tanggalSelesai;
  final String createdAt;

  Tugas({
    required this.id,
    required this.userId,
    required this.judul,
    this.deskripsi,
    required this.prioritas,
    required this.status,
    required this.tanggalTarget,
    this.deadline,
    this.tanggalSelesai,
    required this.createdAt,
  });

  factory Tugas.fromJson(Map<String, dynamic> json) {
    return Tugas(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      judul: json['judul'] as String,
      deskripsi: json['deskripsi'] as String?,
      prioritas: json['prioritas'] as String,
      status: json['status'] as String,
      tanggalTarget: json['tanggal_target'] as String,
      deadline: json['deadline'] as String?,
      tanggalSelesai: json['tanggal_selesai'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    return {
      'user_id': userId,
      'judul': judul,
      'deskripsi': deskripsi,
      'prioritas': prioritas,
      'status': status,
      'tanggal_target': tanggalTarget,
      'deadline': deadline,
    };
  }
}

class KeseharianTodo {
  final String id;
  final String text;
  final bool done;

  KeseharianTodo({
    required this.id,
    required this.text,
    required this.done,
  });

  factory KeseharianTodo.fromJson(Map<String, dynamic> json) {
    return KeseharianTodo(
      id: json['id'] as String,
      text: json['text'] as String,
      done: json['is_done'] as bool? ?? false,
    );
  }
}
