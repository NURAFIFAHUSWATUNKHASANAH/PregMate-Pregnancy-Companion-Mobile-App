import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:PregMate/config/api_config.dart';
import 'package:PregMate/app/modules/home/controllers/home_controller.dart';

class HistoriController extends GetxController {
  final box = GetStorage();

  var historiList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  var userId = "".obs;

  var totalLatihan = 0.obs;
  var avgAccuracy = 0.0.obs;

  // =========================
  // INIT
  // =========================
@override
void onInit() {
  super.onInit();

  // langsung load pertama kali
  loadUserData();

  // tunggu HomeController siap
  Future.delayed(Duration(milliseconds: 300), () {
    if (Get.isRegistered<HomeController>()) {
      ever(Get.find<HomeController>().statusKehamilan, (_) {
        refreshHistory();
      });
    }
  });
}

  // =========================
  // LOAD USER
  // =========================
  Future<void> loadUserData() async {
    final token = box.read('auth_token');
    userId.value = box.read('user_id') ?? "";

    if (token == null || userId.value.isEmpty) {
      print("❌ Belum login, skip histori");
      return;
    }

    await refreshHistory();
  }

  // =========================
  // SYNC KEHAMILAN (REALTIME UPDATE)
  // =========================
void syncKehamilan() {
  ever(Get.find<HomeController>().statusKehamilan, (_) {
    print("🔄 statusKehamilan berubah → refresh histori");
    refreshHistory();
  });
}

  // =========================
  // FETCH HISTORY
  // =========================
  Future<void> fetchHistory() async {
    final token = box.read('auth_token');
    final userId = box.read('user_id');
    final kehamilanId = box.read('kehamilan_id');

    if (token == null || userId == null) {
      print("❌ Token/UserID kosong");
      return;
    }

    if (kehamilanId == null) {
      print("⚠️ Tidak ada kehamilan aktif");
      historiList.clear();
      return;
    }

    isLoading.value = true;

    final url = Uri.parse(
      ApiConfig.historiByUserAndPregnancy(userId, kehamilanId),
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      // ======================
      // TOKEN EXPIRED
      // ======================
      if (response.statusCode == 401) {
        final body = jsonDecode(response.body);

        if (body["msg"] == "Token has expired") {
          print("🔐 Token expired → logout");
          box.erase();
          Get.offAllNamed('/login');
          return;
        }
      }

      // ======================
      // SUCCESS
      // ======================
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == "success") {
          historiList.value =
              List<Map<String, dynamic>>.from(data["data"] ?? []);

          print("✅ histori loaded: ${historiList.length}");
        }
      } else {
        print("❌ Fetch histori gagal: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetchHistory: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // FETCH STATS
  // =========================
  Future<void> fetchStats() async {
    final token = box.read('auth_token');
    final userId = box.read('user_id');
    final kehamilanId = box.read('kehamilan_id');

    if (token == null || userId == null) return;

    if (kehamilanId == null) return;

    final url = Uri.parse(
      ApiConfig.historiStats(userId, kehamilanId),
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      // TOKEN EXPIRED
      if (response.statusCode == 401) {
        final body = jsonDecode(response.body);

        if (body["msg"] == "Token has expired") {
          box.erase();
          Get.offAllNamed('/login');
          return;
        }
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == "success") {
          totalLatihan.value = data["total"] ?? 0;
          avgAccuracy.value = (data["avg_accuracy"] ?? 0).toDouble();
        }
      } else {
        print("❌ Fetch stats gagal: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetchStats: $e");
    }
  }

  // =========================
  // REFRESH ALL
  // =========================
  Future<void> refreshHistory() async {
    await fetchHistory();
    await fetchStats();
  }
}
