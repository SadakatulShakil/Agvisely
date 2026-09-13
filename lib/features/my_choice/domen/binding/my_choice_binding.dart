import 'package:get/get.dart';
import '../controllers/my_choice_controller.dart';

/// Lazily provisions [MyChoiceController] when the My Choice route opens.
class MyChoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyChoiceController>(() => MyChoiceController());
  }
}
