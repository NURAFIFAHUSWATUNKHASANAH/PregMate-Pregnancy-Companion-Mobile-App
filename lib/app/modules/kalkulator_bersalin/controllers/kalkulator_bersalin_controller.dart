import 'dart:convert';
import 'package:PregMate/app/modules/home/controllers/home_controller.dart';
import 'package:PregMate/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
// Import controller home untuk mengambil data HPHT/HPL jika diperlukan
// import 'home_controller.dart';

class KalkulatorBersalinController extends GetxController {
  final box = GetStorage();
  // --- State Variables ---
  var isLoading = false.obs;
  var saldo = 0.0.obs;
  var totalMasuk = 0.0.obs;
  var totalKeluar = 0.0.obs;
  var totalKebutuhan = 0.0.obs;
  var sisa = 0.0.obs;
  var progress = 0.0.obs;
  var insight = "Lengkapi data untuk melihat insight".obs;
  var sisaBulan = 0.obs;
  var sisaHari = 0.obs;
  var listTransaksi = <dynamic>[].obs;
  var nabungPerBulan = 0.0.obs;

  var nabungPerMinggu = 0.0.obs; // 🔥 BARU
var targetNabung = 0.0.obs;    // 🔥 BARU
var metodeNabung = "bulanan".obs; // 🔥 BARU

  // --- Input Controllers ---
  final biayaController = TextEditingController();
  var totalBiaya = 0.0.obs;
  var isTargetConfigured = false.obs;

  // --- Flag Automation ---

  // Mock Token (Sesuaikan dengan sistem auth kamu)
  String? get token => box.read("auth_token");

  // Akses ke HomeController (Asumsi kamu punya data HPHT di sana)
  // final homeC = Get.find<HomeController>();
  // Jika tidak ada, buat dummy untuk keperluan UI View
// 🔥 Pakai controller asli
final homeC = Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    getDashboard();
  }

  @override
  void onReady() {
    super.onReady();
  }

void showConfigSheet(BuildContext context) {
  // 🔥 sinkron nilai awal
  biayaController.text =
      totalKebutuhan.value > 0 ? totalKebutuhan.value.toInt().toString() : "";

  totalBiaya.value = totalKebutuhan.value;

  if (metodeNabung.value.isEmpty) {
    metodeNabung.value = "bulanan";
  }

  Get.bottomSheet(
    isScrollControlled: true,
    enableDrag: true,
    Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),

        // 🔥 BATAS HEIGHT BIAR GA HILANG
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.85,
          ),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                // ================= HEADER =================
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Obx(() => Text(
                      totalKebutuhan.value > 0
                          ? "Edit Konfigurasi Target"
                          : "Konfigurasi Target",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0C2D57),
                      ),
                    )),

                const SizedBox(height: 25),

                // ================= DATA REFERENSI (FIX POSISI) =================
                const Text(
                  "DATA REFERENSI",
                  style: TextStyle(
                    color: Color(0xFF0C2D57),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _infoFieldDisabled(
                        "HPHT",
                        homeC.hpht.value,
                        Icons.calendar_today_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoFieldDisabled(
                        "HPL",
                        homeC.hpl.value,
                        Icons.event_available_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ================= INPUT BIAYA =================
                TextField(
                  controller: biayaController,
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      totalBiaya.value = double.tryParse(v) ?? 0,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFF0C2D57),
                    ),
                    labelText: "Target Biaya Persalinan (Rp)",
                    filled: true,
                    fillColor: Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ================= METODE NABUNG =================
                const Text(
                  "Metode Menabung",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0C2D57),
                  ),
                ),

                const SizedBox(height: 10),

                Obx(() => Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("Bulanan"),
                            selected: metodeNabung.value == "bulanan",
                            onSelected: (_) => metodeNabung.value = "bulanan",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("Mingguan"),
                            selected: metodeNabung.value == "mingguan",
                            onSelected: (_) => metodeNabung.value = "mingguan",
                          ),
                        ),
                      ],
                    )),

                const SizedBox(height: 30),

                // ================= BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C2D57),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      if (isTargetConfigured.value) {
                        updateKalkulatorConfig();
                      } else {
                        saveKalkulator();
                      }
                    },
                    child: const Text(
                      "Simpan Rencana",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}


  Widget _infoFieldDisabled(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF0C2D57)),
              const SizedBox(width: 10),
              Text(
                value.isEmpty ? "-" : value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0C2D57),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  // --- API Methods ---

  Future<void> getDashboard() async {
  try {
    if (token == null) return;

    isLoading.value = true;

    // 🔥 Ambil kehamilan_id dari storage
    final kehamilanId = box.read("kehamilan_id") ?? "";

    print("DEBUG GET DASHBOARD - KEHAMILAN_ID: $kehamilanId");

    // 🔥 Kirim ke backend (kalau ada)
    final url = kehamilanId.isNotEmpty
        ? "${ApiConfig.kalkulatorDashboardUrl}?kehamilan_id=$kehamilanId"
        : ApiConfig.kalkulatorDashboardUrl;

    final res = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(res.body);

    if (data["status"] == "success") {
      final d = data["data"] ?? {};

      // ===============================
      // 🔥 SIMPAN kehamilan_id dari backend
      // ===============================
      if (d["kehamilan_id"] != null) {
        box.write("kehamilan_id", d["kehamilan_id"]);
        print("✅ KEHAMILAN_ID DISIMPAN: ${d["kehamilan_id"]}");
      }

      // ===============================
      // 🔥 SAFE PARSING (ANTI NULL ERROR)
      // ===============================
      saldo.value = (d["saldo"] ?? 0).toDouble();
      totalMasuk.value = (d["total_masuk"] ?? 0).toDouble();
      totalKeluar.value = (d["total_keluar"] ?? 0).toDouble();
      totalKebutuhan.value = (d["total_kebutuhan"] ?? 0).toDouble();

      isTargetConfigured.value = totalKebutuhan.value > 0;

      sisa.value = (d["sisa"] ?? 0).toDouble();
      nabungPerBulan.value = (d["nabung_per_bulan"] ?? 0).toDouble();
      nabungPerMinggu.value = (d["nabung_per_minggu"] ?? 0).toDouble();
      targetNabung.value = (d["target_nabung"] ?? 0).toDouble();

      metodeNabung.value = d["metode_nabung"] ?? "bulanan";

      progress.value = (d["progress"] ?? 0).toDouble();
      insight.value = d["insight"] ?? "Lengkapi data untuk melihat insight";

      sisaBulan.value = d["sisa_bulan"] ?? 0;
      sisaHari.value = d["sisa_hari"] ?? 0;

      // ===============================
      // 🔥 RIWAYAT
      // ===============================
      if (d["riwayat"] != null) {
        listTransaksi.assignAll(d["riwayat"]);
      } else {
        listTransaksi.clear();
      }

      // ===============================
      // 🔥 SYNC INPUT TARGET
      // ===============================
      if (totalKebutuhan.value > 0) {
        totalBiaya.value = totalKebutuhan.value;
        biayaController.text = totalKebutuhan.value.toInt().toString();
      }

      // ===============================
      // 🔥 AUTO SHOW DIALOG (ONLY ONCE)
      // ===============================
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isTargetConfigured.value) {
          _showTargetDialogOnce();
        }
      });
    } else {
      print("❌ STATUS ERROR: ${data["message"]}");
    }
  } catch (e) {
    debugPrint("❌ ERROR DASHBOARD: $e");
  } finally {
    isLoading.value = false;
  }
}

  Future<void> saveKalkulator() async {
  if (totalBiaya.value <= 0) {
    Get.snackbar("Perhatian", "Masukkan estimasi biaya yang valid");
    return;
  }

  try {
    isLoading.value = true;

    // 🔥 1. PAKSA AMBIL DATA KEHAMILAN TERBARU
    await homeC.fetchDashboardKehamilan();

    // 🔥 2. AMBIL KEHAMILAN ID DARI STORAGE (HASIL DASHBOARD)
    final kehamilanId = box.read("kehamilan_id");

    if (kehamilanId == null || kehamilanId.toString().isEmpty) {
      Get.snackbar("Error", "ID kehamilan tidak ditemukan");
      return;
    }

    print("DEBUG SAVE - KEHAMILAN_ID: $kehamilanId");

    // 🔥 3. FORMAT TANGGAL
    final hpht = formatToBackend(homeC.hpht.value);
    final hpl  = formatToBackend(homeC.hpl.value);

    if (hpht.isEmpty || hpl.isEmpty) {
      Get.snackbar("Error", "Format tanggal HPHT/HPL tidak valid");
      return;
    }

    // 🔥 4. REQUEST API
    final res = await http.post(
      Uri.parse(ApiConfig.kalkulatorSaveUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "kehamilan_id": kehamilanId, // ✅ FIX UTAMA
        "hpht": hpht,
        "hpl": hpl,
        "total_biaya": totalBiaya.value,
        "metode": "Manual",
        "pakai_bpjs": false,
        "metode_nabung": metodeNabung.value
      }),
    );

    print("DEBUG RESPONSE: ${res.body}");

    // 🔐 TOKEN EXPIRED
    if (res.statusCode == 401) {
      box.erase();
      Get.offAllNamed('/login');
      return;
    }

    // ❌ ERROR VALIDASI BACKEND
    if (res.statusCode == 400) {
      final data = jsonDecode(res.body);
      Get.snackbar("Gagal", data["message"] ?? "Gagal menyimpan data");
      return;
    }

    // ✅ SUCCESS
    if (res.statusCode == 200 || res.statusCode == 201) {
      final responseData = jsonDecode(res.body);

      // 🔥 5. JAGA JIKA BACKEND BALIKIN ID
      final newId = responseData["kehamilan_id"];
      if (newId != null && newId.toString().isNotEmpty) {
        box.write("kehamilan_id", newId);
      }

      // 🔥 6. REFRESH DASHBOARD
      await getDashboard();

      // 🔥 7. CLOSE MODAL
      Get.back();

      // 🔥 8. NOTIFIKASI
      Get.snackbar(
        "Berhasil",
        "Rencana tabungan berhasil disimpan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0C2D57),
        colorText: Colors.white,
      );
    } else {
      print("❌ ERROR: ${res.body}");
      Get.snackbar("Error", "Gagal menyimpan data");
    }
  } catch (e) {
    print("❌ ERROR SAVE: $e");
    Get.snackbar("Error", "Terjadi kesalahan koneksi");
  } finally {
    isLoading.value = false;
  }
}

Future<void> editRiwayat({
  required String riwayatId,
  required double jumlah,
  String keterangan = "",
}) async {

  final kehamilanId = box.read("kehamilan_id");

  if (kehamilanId == null || kehamilanId.toString().isEmpty) {
    Get.snackbar("Error", "kehamilan_id tidak ditemukan");
    return;
  }

  final res = await http.put(
    Uri.parse("${ApiConfig.baseUrl}/kalkulator/edit-riwayat"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
    body: jsonEncode({
      "kehamilan_id": kehamilanId,
      "riwayat_id": riwayatId,
      "jumlah": jumlah,
      "keterangan": keterangan
    }),
  );

  print("EDIT RESPONSE: ${res.statusCode} ${res.body}");

  await getDashboard();
}


Future<void> deleteRiwayat(String riwayatId) async {

  final kehamilanId = box.read("kehamilan_id");

  if (kehamilanId == null || kehamilanId.toString().isEmpty) {
    Get.snackbar("Error", "kehamilan_id tidak ditemukan");
    return;
  }

  final res = await http.delete(
    Uri.parse("${ApiConfig.baseUrl}/kalkulator/delete-riwayat"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
    body: jsonEncode({
      "kehamilan_id": kehamilanId,
      "riwayat_id": riwayatId
    }),
  );

  print("DELETE RESPONSE: ${res.statusCode} ${res.body}");

  await getDashboard();
}

Future<void> updateKalkulatorConfig() async {
  try {
    isLoading.value = true;

    final kehamilanId = box.read("kehamilan_id");

    final res = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/kalkulator/update"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "kehamilan_id": kehamilanId,
        "total_biaya": totalBiaya.value,
        "metode_nabung": metodeNabung.value,
      }),
    );

    final data = jsonDecode(res.body);

    if (data["status"] == "success") {
      await getDashboard();
      Get.back();

      Get.snackbar(
        "Berhasil",
        "Konfigurasi berhasil diupdate",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar("Error", data["message"]);
    }
  } catch (e) {
    Get.snackbar("Error", e.toString());
  } finally {
    isLoading.value = false;
  }
}


String formatToBackend(String date) {
  try {
    if (date.isEmpty) return "";

    // 🔥 Jika sudah format backend (yyyy-MM-dd), langsung pakai
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      return date;
    }

    // 🔥 Jika format UI (dd-MM-yyyy)
    if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(date)) {
      final parsed = DateFormat("dd-MM-yyyy").parseStrict(date);
      return DateFormat("yyyy-MM-dd").format(parsed);
    }

    // ❌ Format tidak dikenal
    debugPrint("FORMAT TIDAK DIKENAL: $date");
    return "";
  } catch (e) {
    debugPrint("FORMAT ERROR: $date | $e");
    return "";
  }
}
  Future<void> tambahTransaksi(double val, bool isIncome,
    {String keterangan = ""}) async {

  if (val <= 0) return;

  if (!isIncome && keterangan.isEmpty) {
    Get.snackbar("Error", "Keterangan wajib diisi");
    return;
  }

  final kehamilanId = box.read("kehamilan_id"); // 🔥 FIX

  final url = isIncome
      ? ApiConfig.kalkulatorTabungUrl
      : ApiConfig.kalkulatorPengeluaranUrl;

  try {
    final res = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(
        isIncome
            ? {
                "kehamilan_id": kehamilanId, // 🔥 FIX
                "jumlah": val
              }
            : {
                "kehamilan_id": kehamilanId, // 🔥 FIX
                "jumlah": val,
                "keterangan": keterangan,
                "kategori": "biaya_persalinan"
              },
      ),
    );

    if (res.statusCode == 200) {
      getDashboard();
    }
  } catch (e) {
    debugPrint("ERROR TRANSACTION: $e");
  }
}

  bool _dialogShown = false;

  void _showTargetDialogOnce() {
    if (_dialogShown) return;

    // Tambahkan pengecekan jika target sudah ada dari API, jangan tampilkan dialog
    if (isTargetConfigured.value) return;

    _dialogShown = true;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header yang Estetik
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C2D57).withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF0C2D57),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Judul
              const Text(
                "Mulai Perencanaanmu",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0C2D57),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Deskripsi
              const Text(
                "Atur target biaya persalinan dulu yuk, agar kamu bisa memantau sisa tabunganmu setiap hari dengan lebih mudah.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        "Nanti",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C2D57),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        Future.delayed(const Duration(milliseconds: 200), () {
                          showConfigSheet(Get.context!);
                        });
                      },
                      child: const Text(
                        "Atur Sekarang",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false, // User wajib memilih salah satu
    );
  }

  void _showNotReadyDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C2D57).withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Color(0xFF0C2D57), size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                "Mulai Perencanaanmu",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0C2D57)),
              ),
              const SizedBox(height: 10),
              const Text(
                "Atur target biaya persalinan dulu yuk, agar kamu bisa memantau sisa tabunganmu setiap hari.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF64748B), height: 1.5),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Nanti",
                          style: TextStyle(color: Color(0xFF64748B))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C2D57),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        Get.back();
                        // Kita trigger action untuk membuka Config Sheet di View
                        // Cara termudah adalah memicu fungsi global/callback atau
                        // langsung buka dari sini jika UI-nya bisa dipindah ke Get.bottomSheet
                      },
                      child: const Text("Atur Sekarang",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
