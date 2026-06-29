import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:PregMate/config/api_config.dart';

class UkuranJaninController extends GetxController {
  final box = GetStorage();

  var mingguUser = 0.obs;
  var role = "".obs;
  var isLoading = false.obs;

  // Variabel observasi untuk detail card utama
  var buah = "".obs;
  var panjang = "".obs;
  var berat = "".obs;
  var deskripsi = "".obs;
  var selectedWeek = "".obs; // Diubah ke String/int dinamis mengikuti data backend
  var imageUrl = "".obs;

  // List dinamis penampung data dari Backend
  var perkembanganJaninList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await fetchUsiaKehamilan();
    await fetchTimelineUkuranJanin();
    isLoading.value = false;
  }

  // 1. Ambil Usia Kehamilan Ibu Saat Ini
  Future<void> fetchUsiaKehamilan() async {
    final token = box.read("auth_token");
    role.value = box.read("user_role") ?? "ibu";

    if (token == null) return;

    final url = role.value == "pendamping"
        ? ApiConfig.pregnancyDashboardPasanganUrl
        : ApiConfig.pregnancyDashboardUrl;

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 401) {
        final body = jsonDecode(response.body);
        if (body["msg"] == "Token has expired") {
          box.erase();
          Get.offAllNamed('/login');
          return;
        }
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["usia_kehamilan_minggu"] != null) {
          mingguUser.value = data["usia_kehamilan_minggu"];
        }
      }
    } catch (e) {
      print("❌ Exception fetch kehamilan: $e");
    }
  }

  // 2. Ambil Semua Data Ukuran Janin dari Backend Admin
  Future<void> fetchTimelineUkuranJanin() async {
    final url = "${ApiConfig.baseUrl}/ukuran-janin"; 

    try {
      final response = await http.get(
        Uri.parse(url),
        // Tambahkan headers ini agar Flask mengembalikan JSON, bukan HTML
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        perkembanganJaninList.value = data;

        if (perkembanganJaninList.isNotEmpty) {
          var nearestItem = getNearestWeekItem(mingguUser.value);
          setPerkembangan(nearestItem);
        }
      } else {
        print("⚠ Server returned status code: ${response.statusCode}");
        deskripsi.value = "Gagal memuat data dari server (${response.statusCode}).";
      }
    } catch (e) {
      print("❌ Exception fetch timeline: $e");
      deskripsi.value = "Terjadi kesalahan koneksi saat memuat data.";
    }
  }

  // Fungsi mencari data minggu terdekat atau yang sesuai dengan minggu user
  dynamic getNearestWeekItem(int targetWeek) {
    if (perkembanganJaninList.isEmpty) return null;

    dynamic nearestItem = perkembanganJaninList.first;
    int minDiff = (targetWeek - int.parse(nearestItem["minggu"].toString())).abs();

    for (var item in perkembanganJaninList) {
      int itemWeek = int.parse(item["minggu"].toString());
      int diff = (targetWeek - itemWeek).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearestItem = item;
      }
    }
    return nearestItem;
  }

  // Setup data visual pada Card Utama
void setPerkembangan(dynamic item) {
  if (item == null) return;

  buah.value = item["buah"] ?? "-";
  panjang.value = item["panjang"] ?? "-";
  berat.value = item["berat"] ?? "-";
  deskripsi.value = item["deskripsi"] ?? "-";
  selectedWeek.value = item["minggu"].toString();

  if (item["imageUrl"] != null &&
      item["imageUrl"].toString().isNotEmpty) {
    imageUrl.value = ApiConfig.baseUrl + item["imageUrl"];
  } else {
    imageUrl.value = "";
  }
}
}