import 'dart:convert';
import 'package:PregMate/config/api_config.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/tips_model.dart';

class TipsNewbornController extends GetxController {
  var list = <TipsModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchTips();
    super.onInit();
  }

  Future<void> fetchTips() async {
    try {
      isLoading.value = true;

      final res = await http.get(
        Uri.parse(ApiConfig.tipsNewbornUrl),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        list.value = List<TipsModel>.from(
          data.map((e) => TipsModel.fromJson(e)),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}