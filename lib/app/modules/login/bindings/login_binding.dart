import 'package:get/get.dart';
import 'package:PregMate/app/data/services/auth_services.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(()=> AuthService());
    Get.lazyPut<LoginController>(() => LoginController(authService: Get.find<AuthService>()));
  }
}
