import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:PregMate/config/api_config.dart';

class RiwayatKehamilanController extends GetxController {
  final box = GetStorage();

  var listKehamilan = [].obs;
  var historiList = [].obs;

  var isLoading = false.obs;

  /// ==============================
  /// GET LIST KEHAMILAN
  /// ==============================
  Future<void> fetchKehamilan() async {
    final token = box.read('auth_token');
    if (token == null) return;

    isLoading.value = true;

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/pregnancy/history/detail"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        listKehamilan.value = data["data"];
      }
    } catch (e) {
      print("Error kehamilan: $e");
    }

    isLoading.value = false;
  }

  /// ==============================
  /// GET HISTORI BERDASARKAN KEHAMILAN
  /// ==============================
  Future<void> fetchHistoriByKehamilan(String kehamilanId) async {
    final token = box.read('auth_token');
    if (token == null) return;

    historiList.clear();

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/histori/by-kehamilan/$kehamilanId"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        historiList.value = data["data"];
      }
    } catch (e) {
      print("Error histori: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchKehamilan();
  }
}
