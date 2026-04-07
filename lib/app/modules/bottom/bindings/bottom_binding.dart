import 'package:get/get.dart';
import 'package:PregMate/app/modules/edit_profil/controllers/edit_profil_controller.dart';
import 'package:PregMate/app/modules/home/controllers/home_controller.dart';
import 'package:PregMate/app/modules/informasi/controllers/informasi_controller.dart';

import '../controllers/bottom_controller.dart';
import '../../profil/controllers/profil_controller.dart'; // tambahkan

class BottomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomController>(() => BottomController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProfileController>(() => ProfileController()); // PENTING!
    Get.lazyPut<EditProfileController>(() => EditProfileController()); // PENTING!
     Get.lazyPut<InformasiController>(() => InformasiController());
  }
}
