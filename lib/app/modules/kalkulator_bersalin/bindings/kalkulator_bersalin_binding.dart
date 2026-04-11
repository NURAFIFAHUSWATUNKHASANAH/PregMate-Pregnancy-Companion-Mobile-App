import 'package:get/get.dart';
import '../controllers/kalkulator_bersalin_controller.dart';

class KalkulatorBersalinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KalkulatorBersalinController>(
      () => KalkulatorBersalinController(),
    );
  }
}