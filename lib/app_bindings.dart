import 'package:get/get.dart';
import 'package:text_to_image/controllers/auth_controller.dart';
import 'package:text_to_image/controllers/gallery_controller.dart';
import 'package:text_to_image/controllers/home_controller.dart';
import 'package:text_to_image/controllers/settings_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize controllers
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<SettingsController>(SettingsController(), permanent: true);
    Get.put<GalleryController>(GalleryController(), permanent: true);
  }
}
