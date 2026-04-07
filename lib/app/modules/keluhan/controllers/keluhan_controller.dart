import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:PregMate/app/modules/rekomendasi/controllers/rekomendasi_controller.dart';
import 'package:PregMate/config/api_config.dart'; // Import config

class KeluhanController extends GetxController {
  var keluhanList = <Map<String, dynamic>>[].obs;
  var selectedKeluhan = "".obs;
  var terapiList = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllKeluhan();
  }

void pilihKeluhan(String keluhan) async {
  selectedKeluhan.value = keluhan;

  await fetchTerapiByKeluhan(keluhan);

  // Tambahkan logika terapi progress
  final keluhanData = keluhanList.firstWhere((k) => k['nama'] == keluhan);
  final keluhanId = keluhanData['_id']; // atau sesuaikan key-nya

  final rekomendasiController = Get.put(RekomendasiController());

  rekomendasiController.setKeluhan(keluhanId); // ini wajib duluan
  await rekomendasiController.fetchTerapiByKeluhanId(keluhanId); // lalu fetch terapinya
}


  void toggleKeluhan(String keluhan) {
    if (selectedKeluhan.value == keluhan) {
      selectedKeluhan.value = "";
    } else {
      selectedKeluhan.value = keluhan;
    }
  }

  Future<void> fetchAllKeluhan() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/keluhan_all');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        keluhanList.value = List<Map<String, dynamic>>.from(data);
      } else {
        print("Gagal memuat keluhan: ${response.statusCode}");
      }
    } catch (e) {
      print("Error saat fetch keluhan: $e");
    }
  }

  Future<void> fetchTerapiByKeluhan(String keluhan) async {
    try {
      // Cari objek keluhan berdasarkan nama
      final keluhanData = keluhanList.firstWhere((k) => k['nama'] == keluhan);

      final rekomendasiId = keluhanData['rekomendasi_terapi_id'];

      final url = Uri.parse(
          '${ApiConfig.baseUrl}/terapi_by_ids?ids=${rekomendasiId.join(",")}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // response berupa list
        terapiList.value = List<String>.from(data.map((item) => item['nama']));
      } else {
        print("Gagal memuat terapi: ${response.statusCode}");
      }
    } catch (e) {
      print("Error saat fetch terapi: $e");
    }
  }
}
