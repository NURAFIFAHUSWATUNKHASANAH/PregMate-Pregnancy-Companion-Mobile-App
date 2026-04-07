import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:PregMate/config/api_config.dart';

class MeditationController extends GetxController {
  var breathingSessions = <Map<String, dynamic>>[].obs;

  var selectedSession = Rxn<Map<String, dynamic>>();

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/meditation_sessions"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        breathingSessions.value = List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  void selectSession(int index) {
    selectedSession.value = breathingSessions[index];
  }

  void clearSelection() {
    selectedSession.value = null;
  }

  Future<void> kirimNotifSelesaiRelaksasi({
    required String label,
    required double durasiMenit,
  }) async {
    try {
      final box = GetStorage();
      final userId = box.read('user_id');

      print("DEBUG USER ID (Meditation): $userId");

      final url = "${ApiConfig.baseUrl}/kirim_notif_relaksasi";

      final bodyData = {
        "user_id": userId,
        "label": label,
        "durasi": durasiMenit,
      };

      print("BODY NOTIF: ${jsonEncode(bodyData)}");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(bodyData),
      );

      print("STATUS NOTIF: ${response.statusCode}");
      print("RESPONSE NOTIF: ${response.body}");
    } catch (e) {
      print("ERROR KIRIM NOTIF RELAKSASI: $e");
    }
  }
}
