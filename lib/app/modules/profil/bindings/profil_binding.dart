import 'package:get/get.dart';
import 'package:PregMate/app/modules/profil/controllers/profil_controller.dart';

class ProfilBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
