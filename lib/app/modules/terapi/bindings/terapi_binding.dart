import 'package:get/get.dart';
import 'package:PregMate/app/modules/rekomendasi/controllers/rekomendasi_controller.dart';

import '../controllers/terapi_controller.dart';

class TerapiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TerapiController>(
      () => TerapiController(),
    );
    Get.lazyPut(() => RekomendasiController());
  }
}
