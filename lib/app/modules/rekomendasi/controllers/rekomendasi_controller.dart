import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:PregMate/config/api_config.dart';
import 'package:PregMate/app/modules/rekomendasi/views/informasi_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RekomendasiController extends GetxController {
  var terapiList = <Map<String, dynamic>>[].obs;
  var selectedTerapi = "".obs;
  var keluhanTerpilih = "".obs;
  var terapiProgress = <bool>[].obs;

Future<void> fetchTerapiByKeluhanId(String keluhanId) async {
  try {
    final keluhanResponse = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/keluhan/$keluhanId'),
    );

    if (keluhanResponse.statusCode == 200) {
      final keluhanData = json.decode(keluhanResponse.body);
      final List<dynamic> terapiIds = keluhanData['rekomendasi_terapi_id'];

      if (terapiIds.isEmpty) {
        print("Keluhan tidak memiliki terapi yang direkomendasikan.");
        terapiList.clear();
        terapiProgress.clear();
        return;
      }

      final idsQuery = terapiIds.join(',');
      print("ID terapi yang akan di-fetch: $idsQuery");

      final terapiResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/terapi_by_ids?ids=$idsQuery'),
      );

      if (terapiResponse.statusCode == 200) {
        final terapiDataList = json.decode(terapiResponse.body);

        for (var terapi in terapiDataList) {
          terapi["gambar"] = "${ApiConfig.baseUrl}/${terapi["gambar"].replaceAll("\\", "/")}";
        }

        terapiList.assignAll(List<Map<String, dynamic>>.from(terapiDataList));
        terapiProgress.assignAll(List<bool>.filled(terapiList.length, false));
         await loadProgressFromStorage(keluhanId);
      } else {
        print("Gagal memuat terapi: ${terapiResponse.statusCode}");
      }
    } else {
      print("Gagal memuat keluhan: ${keluhanResponse.statusCode}");
    }
  } catch (e) {
    print('Error saat fetch terapi: $e');
  }
}


  void markTerapiAsCompleted(int index) {
    if (index >= 0 && index < terapiProgress.length) {
      terapiProgress[index] = true;
      terapiProgress.refresh();
      saveProgressToStorage();
    }

  }

  bool canAccessTerapi(int index) {
    if (index == 0) return true;
    return terapiProgress[index - 1];
  }

  void pilihTerapi(Map<String, dynamic> terapi, int index) {
    selectedTerapi.value = terapi["nama"];
    Get.dialog(InformasiDialog(terapi: terapi, index: index));
  }

  void setKeluhan(String id) {
    keluhanTerpilih.value = id;
  }


Future<void> loadProgressFromStorage(String keluhanId) async {
  final prefs = await SharedPreferences.getInstance();
  final savedKeluhanId = prefs.getString('keluhan_id');

  if (savedKeluhanId == keluhanId) {
    // Ambil progress lama
    final savedProgress = prefs.getStringList('terapi_progress') ?? [];
    terapiProgress.assignAll(savedProgress.map((e) => e == 'true').toList());
  } else {
    // Reset progress jika keluhan berbeda
    terapiProgress.assignAll(List<bool>.filled(terapiList.length, false));
    await prefs.setString('keluhan_id', keluhanId);
    await prefs.setStringList(
        'terapi_progress',
        List.generate(terapiList.length, (index) => 'false'));
  }
}

Future<void> saveProgressToStorage() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('terapi_progress',
      terapiProgress.map((e) => e.toString()).toList());
}

}
