import 'package:get/get.dart';
import '../controllers/craving_controller.dart';

class CravingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CravingController>(() => CravingController());
  }
}