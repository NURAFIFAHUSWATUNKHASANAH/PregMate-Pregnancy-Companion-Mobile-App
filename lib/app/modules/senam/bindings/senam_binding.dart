import 'package:get/get.dart';
import 'package:PregMate/app/modules/histori/controllers/histori_controller.dart';
import '../controllers/senam_controller.dart';

class SenamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SenamController>(
      () => SenamController(),
    );
    Get.lazyPut<HistoriController>(() => HistoriController());
  }
}