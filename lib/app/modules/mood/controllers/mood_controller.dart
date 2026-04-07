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
      // 🔥 GANTI SharedPreferences → GetStorage
      final userId = box.read('user_id');

      print("DEBUG USER ID (GetStorage): $userId");

      final url = ApiConfig.moodRecommendationUrl;

      final bodyData = {
        "user_id": userId,
        "energy": energi.value,
        "nausea": mual.value,
        "pain": nyeri.value,
        "sleep": tidur.value,
        "appetite": nafsuMakan.value
      };

      print("Request Body: ${jsonEncode(bodyData)}");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(bodyData),
      );

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

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