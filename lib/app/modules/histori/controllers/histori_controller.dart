import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:PregMate/config/api_config.dart';

class HistoriController extends GetxController {

  final box = GetStorage();

  var historiList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  var userId = "".obs;

  var totalLatihan = 0.obs;
  var avgAccuracy = 0.0.obs;

  /// ==============================
  /// INIT
  /// ==============================
  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  /// ==============================
  /// LOAD USER DATA
  /// ==============================
  Future<void> loadUserData() async {

    final token = box.read('auth_token');
    userId.value = box.read('user_id') ?? "";

    // ❗ STOP kalau belum login
    if (token == null || userId.value.isEmpty) {
      print("❌ Belum login, skip fetch histori");
      return;
    }

    await fetchHistory();
    await fetchStats();
  }

  /// ==============================
  /// FETCH HISTORY
  /// ==============================
  Future<void> fetchHistory() async {

    final token = box.read('auth_token');
    final userId = box.read('user_id');

    if (token == null || userId == null) {
      print("❌ Token/UserID tidak ada");
      return;
    }

    isLoading.value = true;

    final url = Uri.parse(
      ApiConfig.historiUrlByUser(userId),
    );

    try {

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
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

        if (data["status"] == "success") {
          historiList.value =
              List<Map<String, dynamic>>.from(data["data"]);
        }

      } else {
        print("❌ Fetch histori gagal: ${response.statusCode}");
      }

    } catch (e) {
      print("❌ Error fetch histori: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ==============================
  /// FETCH STATS
  /// ==============================
  Future<void> fetchStats() async {

    final token = box.read('auth_token');
    final userId = box.read('user_id');

    if (token == null || userId == null) return;

    final url = Uri.parse(
      "${ApiConfig.historiUrl}/stats/$userId",
    );

    try {

      final response = await http.get(
        url,
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

        if (data["status"] == "success") {
          totalLatihan.value = data["total"] ?? 0;
          avgAccuracy.value =
              (data["avg_accuracy"] ?? 0).toDouble();
        }

      } else {
        print("❌ Fetch stats gagal: ${response.statusCode}");
      }

    } catch (e) {
      print("❌ Error fetch stats: $e");
    }
  }

  /// ==============================
  /// REFRESH
  /// ==============================
  Future<void> refreshHistory() async {
    await fetchHistory();
    await fetchStats();
  }
}