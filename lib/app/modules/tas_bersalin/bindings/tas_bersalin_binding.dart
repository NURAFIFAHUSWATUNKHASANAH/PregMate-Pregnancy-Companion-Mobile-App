import 'package:get/get.dart';
import '../controllers/tas_bersalin_controller.dart';

class TasBersalinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TasBersalinController>(
      () => TasBersalinController(),
    );
  }
}