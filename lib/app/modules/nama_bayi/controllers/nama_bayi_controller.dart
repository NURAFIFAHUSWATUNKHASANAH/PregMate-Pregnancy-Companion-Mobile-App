import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:PregMate/config/api_config.dart';

class NamaBayiController extends GetxController {
  /// ================================
  /// STATE
  /// ================================

  var keyword = "".obs;
  var category = "Islami".obs;
  var gender = "Laki-laki".obs;

  var result = "".obs;
  var isLoading = false.obs;

  var favorites = <Map<String, dynamic>>[].obs;
  final box = GetStorage();

  /// ================================
  /// INIT
  /// ================================

  @override
  void onInit() {
    super.onInit();
    getFavorites();
  }

  /// ================================
  /// GENERATE NAMA BAYI (AI)
  /// ================================

  Future<void> generateNama() async {
    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.generateBabyNameUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "keyword": keyword.value.trim(),
          "category": category.value,
          "gender": gender.value
        }),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        result.value = data["names"];
      } else {
        result.value = "Tidak ada rekomendasi nama.";
      }
    } catch (e) {
      result.value = "Gagal mengambil rekomendasi";
    }

    isLoading.value = false;
  }

  /// ================================
  /// PARSE HASIL AI KE LIST
  /// ================================

  List<Map<String, String>> get parsedNames {
    List<Map<String, String>> list = [];

    final lines = result.value.split("\n");
    for (var line in lines) {
      if (line.contains("-")) {
        final clean = line.replaceAll("•", "").trim();
        final parts = clean.split(RegExp(r"\s-\s|\-"));

        if (parts.length == 2) {
          list.add({
            "name": parts[0].trim(),
            "meaning": parts[1].trim(),
          });
        }
      }
    }
    return list;
  }

  /// ================================
  /// SAVE FAVORITE
  /// ================================

  Future<void> saveFavorite(String name, String meaning) async {
    final token = box.read('auth_token');

    try {
      await http.post(
        Uri.parse(ApiConfig.babyNameFavoriteUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "name": name.trim(),
          "meaning": meaning.trim(),
          "category": category.value,
          "gender": gender.value
        }),
      );

      // 🔥 TAMBAH INI (biar langsung merah)
      favorites.add({
        "name": name,
        "meaning": meaning,
      });

      Get.snackbar("Berhasil", "Disimpan ke favorit");
    } catch (e) {
      Get.snackbar("Error", "Gagal simpan");
    }
  }

  Future<void> getFavorites() async {
    final token = box.read('auth_token');

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.babyNameFavoriteUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        favorites.value = List<Map<String, dynamic>>.from(data["data"]);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal ambil favorit");
    }
  }

  /// ================================
  /// DELETE FAVORITE
  /// ================================

  Future<void> removeFavorite(String name) async {
    final token = box.read('auth_token');

    try {
      final encodedName = Uri.encodeComponent(name);

      await http.delete(
        Uri.parse("${ApiConfig.babyNameFavoriteUrl}/$encodedName"),
        headers: {"Authorization": "Bearer $token"},
      );

      // 🔥 TAMBAH INI (biar langsung hilang merahnya)
      favorites.removeWhere((e) => e["name"] == name);

      Get.snackbar("Berhasil", "Dihapus dari favorit");
    } catch (e) {
      Get.snackbar("Error", "Gagal hapus");
    }
  }

  bool isFavorite(String name) {
    return favorites.any((e) => e["name"] == name);
  }
}
