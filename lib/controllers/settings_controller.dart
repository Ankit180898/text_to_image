import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:text_to_image/controllers/home_controller.dart';

class SettingsController extends GetxController {
  // Observable variables for settings
  final Rx<String> defaultStyle = 'No Style'.obs;
  final Rx<String> defaultAspectRatio = '1:1'.obs;
  final Rx<String> defaultModel = 'stable-diffusion-v1-4'.obs;
  final Rx<bool> darkMode = true.obs;
  final RxDouble cacheSize = 32.5.obs;
  final RxString appVersion = '1.0.0'.obs;

  // Access the HomeController
  final HomeController homeController = Get.find<HomeController>();

  // List of available styles
  final List<String> availableStyles = [
    'No Style',
    'Photorealistic',
    'Digital Art',
    'Cinematic',
    'Anime',
    'Oil Painting',
  ];

  // List of available aspect ratios
  final List<String> availableAspectRatios = ['1:1', '16:9', '9:16'];

  // List of available models
  final List<String> availableModels = ['stable-diffusion-v1-4', 'stable-diffusion-v2-1', 'sdxl', 'dalle-mini'];

  // Method to update the selected model in HomeController
  void updateSelectedModel(String model) {
    homeController.selectedModel.value = model;
    defaultModel.value = model; // Update the default model in settings
  }

  // Method to update the selected aspect ratio in HomeController
  void updateSelectedAspectRatio(String aspectRatio) {
    switch (aspectRatio) {
      case '1:1':
        homeController.selectedAspectRatio.value = 0;
        break;
      case '16:9':
        homeController.selectedAspectRatio.value = 1;
        break;
      case '9:16':
        homeController.selectedAspectRatio.value = 2;
        break;
      // case '4:3':
      //   homeController.selectedAspectRatio.value = 3;
      //   break;
      // case '3:4':
      //   homeController.selectedAspectRatio.value = 4;
      //   break;
      default:
        homeController.selectedAspectRatio.value = 0;
    }
    defaultAspectRatio.value = aspectRatio; // Update the default aspect ratio in settings
  }

  // Method to clear cache
  Future<void> clearCache() async {
    // Simulate cache clearing with a delay
    await Future.delayed(const Duration(seconds: 1));
    cacheSize.value = 0.0;
  }

  // Method to calculate cache size
  Future<double> calculateCacheSize() async {
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      // Calculate the size of all files in the cache directory
      final files = cacheDir.listSync(recursive: true);
      double totalSize = 0;
      for (final file in files) {
        if (file is File) {
          totalSize += file.lengthSync();
        }
      }
      // Convert bytes to MB
      return totalSize / (1024 * 1024);
    }
    return 0.0;
  }

  // Update the cache size in the controller
  Future<void> updateCacheSize() async {
    final size = await calculateCacheSize();
    cacheSize.value = size;
  }

  // Method to toggle dark mode
  void toggleDarkMode() {
    darkMode.value = !darkMode.value;
    // Here you would implement the actual theme change in your app
  }
}
