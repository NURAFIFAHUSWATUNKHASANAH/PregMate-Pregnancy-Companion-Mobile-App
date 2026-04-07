import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:PregMate/models/artikel_model.dart';
import 'package:PregMate/config/api_config.dart';

class ArtikelController extends GetxController {
  var artikels = <Artikel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchArtikels(); // ✅ dipanggil saat controller dibuat
  }

  Future<void> fetchArtikels() async {
    try {
      isLoading.value = true;

      final response = await http.get(Uri.parse(ApiConfig.artikelUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          List list = data['data'];

          artikels.assignAll(
            list.map((e) => Artikel.fromJson(e)).toList(),
          );
        } else {
          Get.snackbar("Error", "Data artikel tidak ditemukan");
        }
      } else {
        Get.snackbar("Error", "Gagal mengambil data artikel");
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    } finally {
      isLoading.value = false;
    }
  }


  Future<Artikel?> fetchArtikelDetail(String id) async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.artikelDetailUrl(id)));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return Artikel.fromJson(data['data']);
        }
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
    return null;
  }
}
