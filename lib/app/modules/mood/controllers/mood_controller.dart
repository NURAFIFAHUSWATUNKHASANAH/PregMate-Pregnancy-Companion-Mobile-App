import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:PregMate/config/api_config.dart';

class MoodController extends GetxController {
  final box = GetStorage(); // 🔥 TAMBAH INI

  var mual = 0.0.obs;
  var energi = 5.0.obs;
  var nyeri = 0.0.obs;
  var tidur = 5.0.obs;
  var nafsuMakan = 5.0.obs;

  var recommendation = "".obs;
  var isLoading = false.obs;

  Future<void> getRecommendation() async {
    isLoading.value = true;

    try {
      final userId = box.read('user_id');
      final kehamilanId = box.read('kehamilan_id');

      // 🔥 VALIDASI PENTING
      if (userId == null || kehamilanId == null) {
        recommendation.value = "⚠ Data user / kehamilan tidak ditemukan";
        isLoading.value = false;
        return;
      }

      final url = ApiConfig.moodRecommendationUrl;

      final bodyData = {
        "user_id": userId,
        "kehamilan_id": kehamilanId, // ✅ SUDAH BENAR
        "energy": energi.value,
        "nausea": mual.value,
        "pain": nyeri.value,
        "sleep": tidur.value,
        "appetite": nafsuMakan.value
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == "success") {
          recommendation.value =
              data["recommendation"] ?? "Tidak ada rekomendasi";
        } else {
          recommendation.value = "⚠ ${data["message"]}";
        }
      } else {
        recommendation.value = "⚠ Server error: ${response.statusCode}";
      }
    } catch (e) {
      recommendation.value = "⚠ Error: $e";
    }

    isLoading.value = false;
  }
}
