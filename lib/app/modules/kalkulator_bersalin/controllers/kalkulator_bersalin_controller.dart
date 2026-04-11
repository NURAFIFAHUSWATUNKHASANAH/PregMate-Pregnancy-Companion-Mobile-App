import 'dart:convert';
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
  var homeC = _DummyHomeC();

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
    // 🔥 Sinkronisasi nilai awal
    biayaController.text =
        totalKebutuhan.value > 0 ? totalKebutuhan.value.toInt().toString() : "";

    Get.bottomSheet(
      isScrollControlled: true,
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 Drag Indicator
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

                const SizedBox(height: 25),

                // 🔥 Title
                const Text(
                  "Konfigurasi Target",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0C2D57),
                  ),
                ),

                const SizedBox(height: 25),

                // 🔥 Input
                TextField(
                  controller: biayaController,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => totalBiaya.value = double.tryParse(v) ?? 0,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.account_balance_wallet_rounded,
                        color: Color(0xFF0C2D57)),
                    labelText: "Target Biaya Persalinan (Rp)",
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide:
                          const BorderSide(color: Color(0xFF0C2D57), width: 1),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // 🔥 Section Title
                const Text(
                  "DATA REFERENSI",
                  style: TextStyle(
                    color: Color(0xFF0C2D57),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 15),

                // 🔥 HPHT & HPL
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
                        "ESTIMASI HPL",
                        homeC.hpl.value,
                        Icons.event_available_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // 🔥 BUTTON SIMPAN
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C2D57),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: saveKalkulator,
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
              ],
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

      final res = await http.get(
        Uri.parse(ApiConfig.kalkulatorDashboardUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(res.body);
      if (data["status"] == "success") {
        final d = data["data"];

        saldo.value = (d["saldo"] ?? 0).toDouble();
        totalMasuk.value = (d["total_masuk"] ?? 0).toDouble();
        totalKeluar.value = (d["total_keluar"] ?? 0).toDouble();
        totalKebutuhan.value = (d["total_kebutuhan"] ?? 0).toDouble();
        isTargetConfigured.value = totalKebutuhan.value > 0;
        sisa.value = (d["sisa"] ?? 0).toDouble();
        nabungPerBulan.value = (d["nabung_per_bulan"] ?? 0).toDouble();
        progress.value = (d["progress"] ?? 0).toDouble();
        insight.value = d["insight"] ?? "Lengkapi data untuk melihat insight";
        sisaBulan.value = d["sisa_bulan"] ?? 0;
        sisaHari.value = d["sisa_hari"] ?? 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!isTargetConfigured.value) {
            _showTargetDialogOnce();
          }
        });

        // Ambil riwayat dari API
        if (d["riwayat"] != null) {
          listTransaksi.assignAll(d["riwayat"]);
        }

        if (totalKebutuhan.value > 0) {
          totalBiaya.value = totalKebutuhan.value;
          biayaController.text = totalKebutuhan.value.toInt().toString();
        }
      }
    } catch (e) {
      debugPrint("ERROR DASHBOARD: $e");
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
      if (homeC.hpht.value.isEmpty) {
        Get.snackbar("Data Kurang",
            "Silakan isi data HPHT di halaman Home terlebih dahulu.");
        return;
      }

      final res = await http.post(
        Uri.parse(ApiConfig.kalkulatorSaveUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "hpht": homeC.hpht.value,
          "hpl": homeC.hpl.value,
          "total_biaya": totalBiaya.value,
          "metode": "Manual",
          "pakai_bpjs": false
        }),
      );

      if (res.statusCode == 200) {
        await getDashboard();
        Get.back();
        Get.snackbar("Berhasil", "Rencana tabungan diperbarui",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF0C2D57),
            colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("ERROR SAVE: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> tambahTransaksi(double val, bool isIncome,
      {String keterangan = ""}) async {
    if (val <= 0) return;

    if (!isIncome && keterangan.isEmpty) {
      Get.snackbar("Error", "Keterangan wajib diisi");
      return;
    }

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
        body: jsonEncode(isIncome
            ? {"jumlah": val}
            : {
                "jumlah": val,
                "keterangan": keterangan, // 🔥 TAMBAHAN
                "kategori": "biaya_persalinan"
              }),
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

// Helper untuk menghindari error jika HomeController belum terpasang
class _DummyHomeC {
  var hpht = "01-01-2024".obs;
  var hpl = "10-10-2024".obs;
}
