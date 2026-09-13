import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

/// Lazily provisions [AuthController] when the Sign In route opens.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
