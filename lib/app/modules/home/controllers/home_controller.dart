import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:PregMate/app/modules/histori/views/histori_view.dart';
import 'package:PregMate/app/modules/home/views/home_view.dart';
import 'package:PregMate/app/modules/profil/controllers/profil_controller.dart';
import 'package:PregMate/app/modules/profil/views/profil_view.dart';
import 'package:PregMate/app/modules/terapi/views/terapi_view.dart';
import 'package:PregMate/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:PregMate/app/modules/histori/controllers/histori_controller.dart';

class HomeController extends GetxController {
  final box = GetStorage();

  var totalLatihan = 0.obs;
  var totalWaktuLatihan = "".obs;
  var selectedIndex = 0.obs;

  var usiaMinggu = 0.obs;
  var usiaHari = 0.obs;
  var trimester = 0.obs;
  var hpl = "".obs;

  var hpht = "".obs;
  var tinggiBadan = "".obs;
  var beratBadan = "".obs;
  var riwayatPenyakit = "".obs;

  var ukuranJanin = "".obs;
  var perkembanganJanin = "".obs;
  var tipsKesehatan = "".obs;
  var statusKehamilan = "".obs;

  final pages = <Widget>[
    HomeView(),
    TerapiView(),
    HistoriView(),
    ProfileView(),
  ];

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();

    final userId = box.read('user_id');

    if (userId == null || userId.toString().isEmpty) {
      print("Belum login, tidak fetch data");
      return;
    }

    fetchUserData();
    fetchDashboardKehamilan();
  }

  void fetchUserData() {
    final profileController = Get.find<ProfileController>();
    print('Nama pengguna: ${profileController.namaC.value}');
  }

  /// ==============================
  /// DASHBOARD KEHAMILAN
  /// ==============================
  Future<void> fetchDashboardKehamilan() async {
    final token = box.read('auth_token');
    final role = box.read('user_role');

    if (token == null) return;

    String url = "${ApiConfig.baseUrl}/pregnancy/dashboard";

    if (role == "pendamping") {
      url = "${ApiConfig.baseUrl}/pregnancy/dashboard/pasangan";
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      /// 🔐 TOKEN EXPIRED
      if (response.statusCode == 401) {
        final body = jsonDecode(response.body);

        if (body["msg"] == "Token has expired") {
          print("🔐 Token expired → logout");

          box.erase();
          Get.offAllNamed('/login');
          return;
        }
      }

      /// ❌ TIDAK ADA KEHAMILAN AKTIF
      if (response.statusCode == 404) {
        print("⚠️ Tidak ada kehamilan aktif");

        statusKehamilan.value = "finished";
        usiaMinggu.value = 0;
        usiaHari.value = 0;
        trimester.value = 0;
        hpl.value = "";
        hpht.value = "";
        tinggiBadan.value = "";
        beratBadan.value = "";
        ukuranJanin.value = "";
        perkembanganJanin.value = "";
        tipsKesehatan.value = "";

        return;
      }

      /// ✅ SUKSES
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        /// 🔥 SIMPAN KEHAMILAN ID (WAJIB DULU)
        if (data["kehamilan_id"] != null) {
          box.write("kehamilan_id", data["kehamilan_id"]);
          try {
            final historiController = Get.find<HistoriController>();
            historiController.refreshHistory();
          } catch (e) {
            print("HistoriController belum ready: $e");
          }
          print("✅ kehamilan_id tersimpan: ${data["kehamilan_id"]}");
        } else {
          print("⚠️ kehamilan_id NULL dari backend");
        }

        usiaMinggu.value = data["usia_kehamilan_minggu"] ?? 0;
        usiaHari.value = data["usia_kehamilan_hari"] ?? 0;
        trimester.value = data["trimester"] ?? 0;
        hpl.value = data["hpl"] ?? "";

        hpht.value = data["hpht"] ?? "";
        box.write("hpht", hpht.value); 
        tinggiBadan.value = data["tinggi_badan"]?.toString() ?? "";
        beratBadan.value = data["berat_badan"]?.toString() ?? "";
        riwayatPenyakit.value = data["riwayat_penyakit"] ?? "";

        ukuranJanin.value = data["ukuran_janin"] ?? "";
        perkembanganJanin.value = data["perkembangan_janin"] ?? "";
        tipsKesehatan.value = data["tips_kesehatan"] ?? "";
        statusKehamilan.value = data["status"] ?? "active";

        /// 🔥 FIX PENTING: trigger histori SETELAH kehamilan_id pasti ada
        try {
          final historiController = Get.find<HistoriController>();

          await Future.delayed(Duration(milliseconds: 150));

          await historiController.refreshHistory();
          print("✅ histori berhasil di-refresh");
        } catch (e) {
          print("⚠️ HistoriController belum ready: $e");
        }

        return;
      }

      /// ⚠️ ERROR LAIN
      print("Dashboard pregnancy gagal: ${response.body}");
    } catch (e) {
      print("Error dashboard: $e");
    }
  }

  Future<void> endPregnancy() async {
    final token = box.read('auth_token');
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/pregnancy/end"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        statusKehamilan.value = "finished";
        Get.snackbar("Selesai", "Kehamilan telah diakhiri");
        fetchDashboardKehamilan();
      } else {
        Get.snackbar("Gagal", "Tidak bisa mengakhiri kehamilan");
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan");
    }
  }
}
