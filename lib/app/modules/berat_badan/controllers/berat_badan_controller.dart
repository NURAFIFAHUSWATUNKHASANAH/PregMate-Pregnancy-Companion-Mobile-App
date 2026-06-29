import 'package:PregMate/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:PregMate/config/api_config.dart';

class BeratBadanController extends GetxController {
  final box = GetStorage();
  var riwayat = <Map<String, dynamic>>[].obs;
  var beratTerakhir = 0.0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRiwayatBeratBadan();
  }

  /// ==============================
  /// FETCH RIWAYAT
  /// ==============================
Future<void> fetchRiwayatBeratBadan() async {
  isLoading.value = true;

  final token = box.read('auth_token');

  if (token == null) {
    print("❌ Token tidak ada");
    isLoading.value = false;
    return;
  }

  try {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/berat_badan"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    /// 🔐 HANDLE TOKEN EXPIRED
    if (response.statusCode == 401) {
      final body = jsonDecode(response.body);

      if (body["msg"] == "Token has expired") {
        print("🔐 Token expired → logout");

        box.erase();
        Get.offAllNamed('/login');
        return;
      }
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      riwayat.value = List<Map<String, dynamic>>.from(
        data.map((d) {
          double berat = 0.0;

          final b = d["berat_badan"];

          if (b is String) {
            berat = double.tryParse(b) ?? 0.0;
          } else if (b is num) {
            berat = b.toDouble();
          }

          return {
            "_id": d["_id"],
            "berat_badan": berat,
            "tanggal": d["tanggal"],
          };
        }),
      );

      final home = Get.find<HomeController>();

      if (riwayat.isNotEmpty) {
        // gunakan pengukuran terakhir
        beratTerakhir.value = riwayat.last["berat_badan"];
      } else {
        // belum ada riwayat -> gunakan BB awal dari validasi kehamilan
        beratTerakhir.value =
            double.tryParse(home.beratBadan.value) ?? 0.0;
      }
    } else {
      print("❌ Gagal ambil berat badan: ${response.body}");
    }
  } catch (e) {
    print("❌ Error: $e");
  } finally {
    isLoading.value = false;
  }
}

DateTime? getHpht() {
  final hphtString = box.read("hpht");
  if (hphtString != null) {
    return DateTime.parse(hphtString);
  }
  return null;
}

int getBulanKehamilanByHpht(DateTime tanggal, DateTime hpht) {
  final start = DateTime(hpht.year, hpht.month, hpht.day);
  final current = DateTime(tanggal.year, tanggal.month, tanggal.day);

  if (current.isBefore(start)) return -1;

  int bulan = 1;
  DateTime awal = start;

  while (true) {
    final akhir = DateTime(
      awal.year,
      awal.month + 1,
      awal.day,
    );

    if (current.isBefore(akhir)) {
      return bulan;
    }

    bulan++;
    awal = akhir;

    if (bulan > 10) break;
  }

  return bulan;
}


  /// ==============================
  /// TAMBAH DATA
  /// ==============================
Future<void> tambahMingguan(double berat, DateTime tanggal) async {
  final token = box.read('auth_token');
  if (token == null) return;

final hphtString = box.read("hpht") ?? "";

  if (hphtString.isEmpty) {
    Get.snackbar("Error", "HPHT belum tersedia");
    return;
  }

  final hpht = DateTime.parse(hphtString);
  final batasAkhir = hpht.add(const Duration(days: 280));

  /// ❌ sebelum HPHT
  if (tanggal.isBefore(hpht)) {
    Get.snackbar("Error", "Tanggal tidak boleh sebelum HPHT");
    return;
  }

  /// ❌ lebih dari 40 minggu
  if (tanggal.isAfter(batasAkhir)) {
    Get.snackbar("Error", "Tanggal melebihi 40 minggu kehamilan");
    return;
  }

  /// ❌ masa depan
  if (tanggal.isAfter(DateTime.now())) {
    Get.snackbar("Error", "Tidak bisa pilih tanggal masa depan");
    return;
  }

  final mingguInput = getMingguKehamilan(tanggal, hpht);

  /// ============================
  /// VALIDASI LOKAL (CEPAT)
  /// ============================
  final existing = riwayat.firstWhereOrNull((item) {
    final tgl = DateTime.parse(item['tanggal']);
    return getMingguKehamilan(tgl, hpht) == mingguInput;
  });

  if (existing != null) {
    Get.defaultDialog(
      title: "Sudah Ada Data",
      middleText:
          "Data minggu ke-$mingguInput sudah diinput.\nSilakan edit atau hapus di riwayat.",
      textConfirm: "OK",
      onConfirm: () => Get.back(),
    );
    return;
  }

  /// ============================
  /// REQUEST API
  /// ============================
  try {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/berat_badan"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "berat_badan": berat,
        "tanggal": tanggal.toString().split(" ")[0],
      }),
    );

    /// 🔥 HANDLE DUPLIKAT DARI BACKEND (WAJIB)
    if (response.statusCode == 400) {
      final res = jsonDecode(response.body);

      if (res["error_code"] == "DUPLICATE_WEEK") {
        Get.defaultDialog(
          title: "Sudah Ada Data",
          middleText:
              "Minggu ke-${res["minggu"]} sudah diinput.\nSilakan edit atau hapus di riwayat.",
          textConfirm: "OK",
          onConfirm: () => Get.back(),
        );
        return;
      }

      Get.snackbar("Gagal", res["message"] ?? "Terjadi kesalahan");
      return;
    }

    /// ✅ SUCCESS
    if (response.statusCode == 200 || response.statusCode == 201) {
      fetchRiwayatBeratBadan();
    } else {
      print("❌ Gagal tambah: ${response.body}");
      Get.snackbar("Error", "Gagal menambahkan data");
    }

  } catch (e) {
    print("❌ Error: $e");
    Get.snackbar("Error", "Terjadi kesalahan koneksi");
  }
}

int getMingguKehamilan(DateTime date, DateTime hpht) {
  final d = DateTime(date.year, date.month, date.day);
  final h = DateTime(hpht.year, hpht.month, hpht.day);

  final selisihHari = d.difference(h).inDays;

  if (selisihHari < 0) return -1;

  return (selisihHari ~/ 7) + 1; // pakai integer division
}

DateTime getAwalBulanKehamilanBerikutnya(DateTime date) {
  final hpht = getHpht();
  if (hpht == null) return date;

  final bulan = getBulanKehamilanByHpht(date, hpht);

  return DateTime(
    hpht.year,
    hpht.month + bulan,
    hpht.day,
  );
}

bool isBulanSudahAda(DateTime date) {
  final hpht = getHpht();
  if (hpht == null) return false;

  final bulanDipilih = getBulanKehamilanByHpht(date, hpht);

  return riwayat.any((item) {
    final tgl = DateTime.parse(item["tanggal"]);

    return getBulanKehamilanByHpht(tgl, hpht) == bulanDipilih;
  });
}

/// 🔥 penting banget biar tanggal bersih (tanpa jam)
DateTime _normalize(DateTime d) {
  return DateTime(d.year, d.month, d.day);
}


bool isMasaDepan(DateTime date) {
  return date.isAfter(DateTime.now());
}

DateTime? getBatasAkhirKehamilan() {
  final hpht = getHpht();
  if (hpht == null) return null;

  return hpht.add(const Duration(days: 280)); // 40 minggu
}

double hitungIMT() {
final tb = double.tryParse(box.read("tinggi_badan") ?? "") ?? 0;
final bb = double.tryParse(box.read("berat_badan") ?? "") ?? 0;

  if (tb == 0 || bb == 0) return 0;

  final tinggiMeter = tb / 100;
  return bb / (tinggiMeter * tinggiMeter);
}

double getIMT() {
  final home = Get.find<HomeController>();

  final tb = double.tryParse(home.tinggiBadan.value) ?? 0;
  final bb = double.tryParse(home.beratBadan.value) ?? 0;

  if (tb == 0 || bb == 0) return 0;

  final meter = tb / 100;

  return bb / (meter * meter);
}

bool bolehInputBulanSekarang() {
  final hpht = getHpht();
  if (hpht == null) return false;

  return !isBulanSudahAda(DateTime.now());
}

Map<String, dynamic> getKategoriIMT() {
  final imt = getIMT();

  if (imt < 18.5) {
    return {
      "kategori": "Kurus",
      "minimal": 13.0,
      "maksimal": 18.0,
    };
  }

  if (imt < 25) {
    return {
      "kategori": "Normal",
      "minimal": 11.0,
      "maksimal": 16.0,
    };
  }

  if (imt < 30) {
    return {
      "kategori": "Gemuk",
      "minimal": 7.0,
      "maksimal": 11.0,
    };
  }

  return {
    "kategori": "Obesitas",
    "minimal": 5.0,
    "maksimal": 9.0,
  };
}

Map<String, double> getRangeTargetBerat(int bulan) {
  final kategori = getKategoriIMT();

final home = Get.find<HomeController>();

final bbAwal =
    double.tryParse(home.beratBadan.value) ?? 0;

  double minNaik;
  double maxNaik;

  switch (bulan) {
    case 1:
      minNaik = 0;
      maxNaik = 0;
      break;

    case 2:
      minNaik = 0.5;
      maxNaik = 1.0;
      break;

    case 3:
      minNaik = 1.0;
      maxNaik = 2.0;
      break;

    default:
      final progress = (bulan - 3) / 6;

      minNaik =
          1.0 +
          ((kategori["minimal"]! - 1.0) * progress);

      maxNaik =
          2.0 +
          ((kategori["maksimal"]! - 2.0) * progress);
  }

  return {
    "minimal": bbAwal + minNaik,
    "maksimal": bbAwal + maxNaik,
  };
}



int getBulanKehamilan(DateTime tanggal, DateTime hpht) {
  return getBulanKehamilanByHpht(tanggal, hpht);
}

Map<String, double> getTargetBulanan() {
  final kategori = getKategoriIMT();

  final double targetTotal =
      ((kategori["minimal"] as double) + (kategori["maksimal"] as double)) / 2;

final home = Get.find<HomeController>();

final double bbAwal =
    double.tryParse(home.beratBadan.value) ?? 0;
  final Map<String, double> target = {};

  // Trimester 1
  target["1"] = bbAwal;
  target["2"] = bbAwal + 0.5;
  target["3"] = bbAwal + 1.5;

  // Bulan 4–9
  for (int bulan = 4; bulan <= 9; bulan++) {
    final progress = (bulan - 3) / 6;

    final kenaikan =
        1.5 + ((targetTotal - 1.5) * progress);

    target[bulan.toString()] = bbAwal + kenaikan;
  }

  return target;
}

bool isBeratSesuaiTarget(int index) {
  if (index < 0) return true;

  final hphtString = box.read("hpht");
  if (hphtString == null || hphtString.isEmpty) return true;

  final hpht = DateTime.parse(hphtString);

  final item = riwayat[index];

  final bulan = getBulanKehamilan(
    DateTime.parse(item["tanggal"]),
    hpht,
  );

  final berat = item["berat_badan"];

  final range = getRangeTargetBerat(bulan);

  return berat >= range["minimal"]! &&
      berat <= range["maksimal"]!;
}

double getTargetBeratBulan(int bulan) {
  final kategori = getKategoriIMT();

  final double targetTotal =
      ((kategori["minimal"] as double) + (kategori["maksimal"] as double)) / 2;

final home = Get.find<HomeController>();

final double bbAwal =
    double.tryParse(home.beratBadan.value) ?? 0;

  // Batasi agar bulan tetap 1-9
  if (bulan < 1) bulan = 1;
  if (bulan > 9) bulan = 9;

  // Trimester 1
  switch (bulan) {
    case 1:
      return bbAwal;

    case 2:
      return bbAwal + 0.5;

    case 3:
      return bbAwal + 1.5;
  }

  // Bulan 4-9
  final progress = (bulan - 3) / 6;

  final kenaikan =
      1.5 + ((targetTotal - 1.5) * progress);

  return bbAwal + kenaikan;
}

Map<String, dynamic> getStatusBeratSaatIni() {
  final hpht = DateTime.parse(box.read("hpht"));

  final sekarang = DateTime.now();

  final bulan = getBulanKehamilan(sekarang, hpht);

  final range = getRangeTargetBerat(bulan);

final home = Get.find<HomeController>();

final sekarangBB = riwayat.isNotEmpty
    ? riwayat.last["berat_badan"]
    : double.tryParse(home.beratBadan.value) ?? 0;

  return {
    "bulan": bulan,
    "minimal": range["minimal"],
    "maksimal": range["maksimal"],
    "sekarang": sekarangBB,
  };
}

Future<void> updateBeratBadan(String id, double berat, {String? tanggal}) async {
  final token = box.read('auth_token');
  if (token == null) return;

  if (id.isEmpty) return;

  try {
    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/berat_badan/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "berat_badan": berat,
        "tanggal": tanggal,
      }),
    );

    if (response.statusCode == 200) {
      await fetchRiwayatBeratBadan();
    } else {
      print("❌ gagal update: ${response.body}");
    }
  } catch (e) {
    print("❌ error update: $e");
  }
}

Future<void> deleteBeratBadan(String id) async {
  final token = box.read('auth_token');
  if (token == null) return;

  if (id.isEmpty) {
    print("❌ ID kosong, abort delete");
    return;
  }

  try {
    final response = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/berat_badan/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      await fetchRiwayatBeratBadan();
    } else {
      print("❌ gagal delete: ${response.body}");
    }
  } catch (e) {
    print("❌ error delete: $e");
  }
}

String formatBerat(dynamic value) {
  double val = 0;

  if (value is String) {
    val = double.tryParse(value) ?? 0;
  } else if (value is num) {
    val = value.toDouble();
  }

  // kalau bilangan bulat → hilangkan .0
  if (val % 1 == 0) {
    return val.toInt().toString();
  }

  return val.toString();
}
}
