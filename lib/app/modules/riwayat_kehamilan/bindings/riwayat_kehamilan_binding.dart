import 'package:get/get.dart';
import '../controllers/riwayat_kehamilan_controller.dart';

class RiwayatKehamilanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatKehamilanController>(
      () => RiwayatKehamilanController(),
    );
  }
}