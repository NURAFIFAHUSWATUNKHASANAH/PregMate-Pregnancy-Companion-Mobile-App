import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:PregMate/config/api_config.dart';

class CravingController extends GetxController {
  final box = GetStorage();

  var cravings = [].obs;
  var isLoading = false.obs;

  /// =========================
  /// GET DATA
  /// =========================
  Future<void> fetchCravings() async {
    final token = box.read('auth_token');

    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/craving"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        cravings.value = jsonDecode(response.body);
      }
    } catch (e) {
      print("Error fetch craving: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// =========================
  /// ADD CRAVING
  /// =========================
  Future<void> addCraving(String makanan, String keterangan) async {
  final token = box.read('auth_token');

  try {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/api/craving"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "makanan": makanan,
        "keterangan": keterangan
      }),
    );

    if (response.statusCode == 200) {
      fetchCravings();
      Get.snackbar("Sukses", "Ngidam ditambahkan 💖");
    }
  } catch (e) {
    print("Error add craving: $e");
  }
}

  /// =========================
  /// UPDATE STATUS
  /// =========================
  Future<void> updateStatus(String id, String status) async {
    final token = box.read('auth_token');

    try {
      await http.put(
        Uri.parse("${ApiConfig.baseUrl}/api/craving/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"status": status}),
      );

      fetchCravings();
    } catch (e) {
      print("Error update: $e");
    }
  }

  @override
  void onInit() {
    fetchCravings();
    super.onInit();
  }
}