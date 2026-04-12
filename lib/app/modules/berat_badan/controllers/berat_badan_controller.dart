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
        headers: {"Authorization": "Bearer $token"},
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

        riwayat.value = List<Map<String, dynamic>>.from(data.map((d) {
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
        }));

        if (riwayat.isNotEmpty) {
          beratTerakhir.value = riwayat.last["berat_badan"];
        } else {
          beratTerakhir.value = 0.0;
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


bool isMingguSudahAda(DateTime date) {
final hphtString = box.read("hpht") ?? "";

  if (hphtString.isEmpty) return false;

  final hpht = DateTime.parse(hphtString);

  final mingguDipilih = getMingguKehamilan(_normalize(date), hpht);

  return riwayat.any((item) {
    final tgl = _normalize(DateTime.parse(item['tanggal']));
    final mingguData = getMingguKehamilan(tgl, hpht);

    return mingguData == mingguDipilih;
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

double getBatasNormalMingguan() {
  final imt = hitungIMT();

  if (imt == 0) return 0.4;

  if (imt < 18.5) return 0.5;
  if (imt < 25) return 0.4;
  if (imt < 30) return 0.3;
  return 0.2;
}

bool isLonjakanAbnormal(int index) {
  if (index <= 0 || index >= riwayat.length) return false;

  final current = riwayat[index];
  final prev = riwayat[index - 1];

  final currBB = (current["berat_badan"] as num).toDouble();
  final prevBB = (prev["berat_badan"] as num).toDouble();

  final kenaikan = currBB - prevBB;

  final batas = getBatasNormalMingguan();

  /// 🔥 tambahan: kalau turun juga warning (opsional tapi bagus)
  if (kenaikan < 0) return true;

  return kenaikan > batas;
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
