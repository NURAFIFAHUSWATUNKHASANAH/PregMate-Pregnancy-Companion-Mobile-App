import 'package:get/get.dart';
import '../controllers/tips_newborn_controller.dart';

class TipsNewbornBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TipsNewbornController>(() => TipsNewbornController());
  }
}