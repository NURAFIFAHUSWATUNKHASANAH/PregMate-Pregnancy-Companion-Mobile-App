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

    /// ✅ PAKAI 1 SUMBER HISTORI
    final historiController = Get.put(HistoriController());
    historiController.refreshHistory();
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
          "Authorization": "Bearer $token"
        }
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

        usiaMinggu.value = data["usia_kehamilan_minggu"] ?? 0;
        usiaHari.value = data["usia_kehamilan_hari"] ?? 0;
        trimester.value = data["trimester"] ?? 0;
        hpl.value = data["hpl"] ?? "";

        hpht.value = data["hpht"] ?? "";
        tinggiBadan.value = data["tinggi_badan"]?.toString() ?? "";
        beratBadan.value = data["berat_badan"]?.toString() ?? "";
        riwayatPenyakit.value = data["riwayat_penyakit"] ?? "";

        ukuranJanin.value = data["ukuran_janin"] ?? "";
        perkembanganJanin.value = data["perkembangan_janin"] ?? "";
        tipsKesehatan.value = data["tips_kesehatan"] ?? "";

      } else {
        print("Dashboard pregnancy gagal: ${response.body}");
      }

    } catch (e) {
      print("Error dashboard: $e");
    }
  }
}