import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:PregMate/config/api_config.dart';
import 'package:PregMate/app/routes/app_pages.dart';

class ValidasiKehamilanController extends GetxController {

  final box = GetStorage();

  var hpht = "";
  var tinggi = "";
  var berat = "";

  void setHpht(String v) => hpht = v;
  void setTinggi(String v) => tinggi = v;
  void setBerat(String v) => berat = v;

  Future<void> submitData() async {

    /// 🔥 AMBIL TOKEN DARI GET STORAGE
    final token = box.read("auth_token");

    /// ❗ VALIDASI TOKEN
    if (token == null || token.toString().isEmpty) {
      Get.snackbar("Session Habis", "Silakan login ulang");
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    try {

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/pregnancy/validate"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "hpht": hpht,
          "tinggi_badan": tinggi,
          "berat_badan": berat,
        }),
      );

      /// ✅ SUCCESS
      if (response.statusCode == 200) {

        box.write("is_validated", true);

        Get.offAllNamed(Routes.BOTTOM);

      }

      /// 🔴 TOKEN EXPIRED / INVALID
      else if (response.statusCode == 401) {

        box.erase(); // logout total

        Get.snackbar("Login Expired", "Silakan login ulang");
        Get.offAllNamed(Routes.LOGIN);

      }

      /// ❌ ERROR LAIN
      else {

        print("ERROR: ${response.body}");
        Get.snackbar("Error", "Gagal menyimpan data");
      }

    } catch (e) {

      print("EXCEPTION: $e");
      Get.snackbar("Error", "Terjadi kesalahan server");
    }
  }
}