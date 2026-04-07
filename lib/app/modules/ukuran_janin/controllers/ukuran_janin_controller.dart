import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:PregMate/config/api_config.dart';

class UkuranJaninController extends GetxController {
  final box = GetStorage();

  var mingguUser = 0.obs;

  var buah = "".obs;
  var panjang = "".obs;
  var berat = "".obs;
  var deskripsi = "".obs;

  var selectedWeek = 0.obs;
  var role = "".obs;

  final Map<int, Map<String, dynamic>> perkembanganJanin = {
    8: {
      "buah": "Anggur",
      "panjang": "1.6 cm",
      "berat": "4 g",
      "desc": "Organ vital mulai terbentuk"
    },
    12: {
      "buah": "Jeruk Kecil",
      "panjang": "5.4 cm",
      "berat": "14 g",
      "desc": "Refleks bayi mulai muncul"
    },
    16: {
      "buah": "Alpukat",
      "panjang": "11.6 cm",
      "berat": "100 g",
      "desc": "Otot dan tulang berkembang"
    },
    20: {
      "buah": "Pisang",
      "panjang": "25 cm",
      "berat": "300 g",
      "desc": "Gerakan bayi mulai terasa"
    },
    24: {
      "buah": "Jagung",
      "panjang": "30 cm",
      "berat": "600 g",
      "desc": "Paru-paru berkembang"
    },
    28: {
      "buah": "Terong",
      "panjang": "37.6 cm",
      "berat": "1 kg",
      "desc": "Otak berkembang pesat"
    },
    32: {
      "buah": "Kelapa Muda",
      "panjang": "42.4 cm",
      "berat": "1.7 kg",
      "desc": "Bayi mulai memposisikan diri"
    },
    36: {
      "buah": "Pepaya",
      "panjang": "47.4 cm",
      "berat": "2.6 kg",
      "desc": "Bayi mulai turun ke panggul"
    },
    40: {
      "buah": "Semangka",
      "panjang": "51.2 cm",
      "berat": "3.4 kg",
      "desc": "Perkiraan waktu persalinan"
    },
  };

  @override
  void onInit() {
    super.onInit();
    fetchUsiaKehamilan();
  }

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

      /// 🔐 HANDLE TOKEN EXPIRED
      if (response.statusCode == 401) {
        final body = jsonDecode(response.body);

        if (body["msg"] == "Token has expired") {
          print("🔐 Token expired → logout");

          box.erase();
          Get.offAllNamed('/login');
          return;
        }
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["usia_kehamilan_minggu"] != null) {
          mingguUser.value = data["usia_kehamilan_minggu"];

          int nearestWeek = getNearestWeek(mingguUser.value);
          selectedWeek.value = nearestWeek;
          setPerkembangan(nearestWeek);
        } else {
          mingguUser.value = 0;
          buah.value = "-";
          panjang.value = "-";
          berat.value = "-";
          deskripsi.value = "Data kehamilan belum tersedia";
        }
      } else {
        print("❌ Error fetch kehamilan: ${response.body}");

        mingguUser.value = 0;
        buah.value = "-";
        panjang.value = "-";
        berat.value = "-";
        deskripsi.value = "Data kehamilan belum tersedia";
      }
    } catch (e) {
      print("❌ Exception: $e");

      mingguUser.value = 0;
      buah.value = "-";
      panjang.value = "-";
      berat.value = "-";
      deskripsi.value = "Terjadi kesalahan saat mengambil data";
    }
  }

  int getNearestWeek(int week) {
    int nearest = 8;
    for (var key in perkembanganJanin.keys) {
      if (week >= key) {
        nearest = key;
      }
    }
    return nearest;
  }

  void setPerkembangan(int week) {
    final data = perkembanganJanin[week]!;
    buah.value = data["buah"];
    panjang.value = data["panjang"];
    berat.value = data["berat"];
    deskripsi.value = data["desc"];
    selectedWeek.value = week;
  }
}
