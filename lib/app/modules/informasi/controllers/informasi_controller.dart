import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:PregMate/config/api_config.dart';

class InformasiController extends GetxController {

  final box = GetStorage();

  var informasiList = [].obs;
  var selectedData = Rxn<dynamic>();

  @override
  void onInit() {
    super.onInit();
    fetchInformasi();
  }

  Future fetchInformasi() async {

    final token = box.read('auth_token');

    if (token == null) {
      print("❌ Token tidak ada");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/informasi"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        }
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

      if(response.statusCode == 200){

        final data = jsonDecode(response.body);
        informasiList.value = data["data"];

      } else {
        print("❌ Gagal ambil informasi: ${response.body}");
      }

    } catch (e) {
      print("❌ Error: $e");
    }
  }

  void selectData(dynamic data) {
    selectedData.value = data;
  }

  void clearSelected() {
    selectedData.value = null;
  }
}