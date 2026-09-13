import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

/// Lazily provisions [ProfileController] when the Profile route opens.
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
