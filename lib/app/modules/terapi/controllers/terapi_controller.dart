import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:PregMate/config/api_config.dart';
import 'package:PregMate/models/terapi_model.dart';
import 'dart:convert';

class TerapiController extends GetxController {
  var selectedIndex = RxInt(-1);
  var terapiList = <TerapiModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTerapiData();
  }

  // Mengambil data terapi dari backend
 Future<void> fetchTerapiData() async {
  final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/terapi'));

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    print("DATA TERAPI: $data"); // ✅ Tambahkan ini

    terapiList.value = List<TerapiModel>.from(
      data.map((terapi) => TerapiModel.fromJson(terapi)),
    );
  } else {
    throw Exception('Failed to load terapi data');
  }
}


  // Memilih terapi berdasarkan index
  void selectTerapi(int index) {
    selectedIndex.value = index;
    update();
  }
}
