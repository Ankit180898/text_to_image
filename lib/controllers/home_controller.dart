import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:text_to_image/controllers/gallery_controller.dart';
import 'package:text_to_image/models/history_item_model.dart';
import 'package:text_to_image/service/database_helper.dart';

class HomeController extends GetxController {
  final List<HistoryItem> history = [];
  final TextEditingController textController = TextEditingController();
  Uint8List? imageData;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxString selectedModel = 'stable-diffusion-v1-4'.obs;
  RxInt selectedAspectRatio = 1.obs; // 0: 1:1, 1: 16:9, 2: 9:16
  final galleryController = Get.put(GalleryController());

  final List<String> models = ['stable-diffusion-v1-4', 'stable-diffusion-v2-1', 'sdxl', 'dalle-mini'];

  final List<String> stylePresets = [
    'No Style',
    'Photorealistic',
    'Digital Art',
    'Illustration',
    'Anime',
    'Cinematic',
    'Neon',
    'Watercolor',
  ];
  RxString selectedStyle = 'No Style'.obs;

  List<String> recentPrompts = [
    'A magical forest with glowing mushrooms and fairy lights',
    'Futuristic city skyline at sunset',
    'Abstract geometric patterns in vibrant colors',
    'Serene mountain landscape with a reflective lake',
  ];

  @override
  void onInit() {
    requestPermissions();
    super.onInit();
  }

  String getModelEndpoint(String model) {
    switch (model) {
      case 'stable-diffusion-v2-1':
        return 'https://router.huggingface.co/hf-inference/models/stabilityai/stable-diffusion-2-1';
      case 'sdxl':
        return 'https://router.huggingface.co/hf-inference/models/stabilityai/stable-diffusion-xl-base-1.0';
      case 'dalle-mini':
        return 'https://router.huggingface.co/hf-inference/models/dalle-mini/dalle-mini';
      case 'stable-diffusion-v1-4':
      default:
        return 'https://router.huggingface.co/hf-inference/models/CompVis/stable-diffusion-v1-4';
    }
  }

  Future<void> requestPermissions() async {
    // For Android 13+ (API 33+)
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        // Use READ_MEDIA_IMAGES permission for Android 13+
        var status = await Permission.photos.request();
        // Or this, depending on your permission_handler version
        // var status = await Permission.mediaLibrary.request();
        if (status.isGranted) {
          debugPrint("Permission Granted");
        } else {
          debugPrint("Permission Denied");
        }
      } else if (androidInfo.version.sdkInt >= 29) {
        // For Android 10-12
        var status = await Permission.storage.request();
        if (status.isGranted) {
          debugPrint("Permission Granted");
        } else {
          debugPrint("Permission Denied");
        }
      } else {
        // For Android 9 and below
        var status = await Permission.storage.request();
        if (status.isGranted) {
          debugPrint("Permission Granted");
        } else {
          debugPrint("Permission Denied");
        }
      }
    }
  }

  Future<void> generateImage() async {
    if (textController.text.isEmpty) {
      errorMessage.value = 'Please enter a prompt';
      return;
    }

    isLoading.value = true;
    imageData = null;
    errorMessage.value = '';

    try {
      final apiToken = dotenv.env['API_KEY'];
      final modelEndpoint = getModelEndpoint(selectedModel.value);

      final response = await http
          .post(
            Uri.parse(modelEndpoint),
            headers: {'Authorization': 'Bearer $apiToken', 'Content-Type': 'application/json'},
            body: json.encode({
              "inputs": textController.text,
              "parameters": {
                "style": selectedStyle.value != 'No Style' ? selectedStyle.value.toLowerCase() : null,
                "aspect_ratio": getAspectRatioValue(),
              },
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timed out. The server may be busy.');
            },
          );

      if (response.statusCode == 200) {
        imageData = response.bodyBytes;
        isLoading.value = false;

        // Add to history
        history.add(HistoryItem(prompt: textController.text, imageData: response.bodyBytes, timestamp: DateTime.now()));
        await DatabaseHelper.insertImage(textController.text, imageData!);
        await galleryController.fetchImages();

        // Add to recent prompts if not already there
        if (!recentPrompts.contains(textController.text)) {
          recentPrompts.insert(0, textController.text);
          if (recentPrompts.length > 10) {
            recentPrompts.removeLast();
          }
        }
      } else {
        isLoading.value = false;
        errorMessage.value = 'Error ${response.statusCode}: ${response.reasonPhrase}';
        debugPrint('Error response: ${response.body}');
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Error: ${e.toString()}';
      debugPrint('Exception caught: $e');
    }
  }

  String getAspectRatioValue() {
    switch (selectedAspectRatio.value) {
      case 0:
        return "1:1";
      case 1:
        return "16:9";
      case 2:
        return "9:16";
      default:
        return "1:1";
    }
  }

  Future<void> saveImageToGallery(Uint8List imageBytes) async {
    try {
      // For Android 10+ (API 29+), we need to use MediaStore API
      if (Platform.isAndroid) {
        // Using photo_manager
        final entity = await PhotoManager.editor.saveImage(
          imageBytes,
          filename: 'VisionAI_${DateTime.now().millisecondsSinceEpoch}',
        );

        // Show success feedback
        Get.snackbar(
          'Success',
          'Image saved to gallery successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(8),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );

        debugPrint('Image Saved Successfully: $entity');
      }
      // For iOS
      else if (Platform.isIOS) {
        final entity = await PhotoManager.editor.saveImage(
          imageBytes,
          filename: 'VisionAI_${DateTime.now().millisecondsSinceEpoch}',
        );

        Get.snackbar(
          'Success',
          'Image saved to gallery successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(8),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );

        debugPrint('Image Saved Successfully: $entity');
      }
    } catch (e) {
      _showErrorSavingImage(e.toString());
      debugPrint('Error saving image: $e');
    }
  }

  void _showErrorSavingImage(String errorMessage) {
    Get.snackbar(
      'Error',
      'Failed to save image: $errorMessage',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> shareImage(Uint8List imageBytes) async {
    try {
      // Temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/shared_image.png');

      // Save Uint8List to file
      await file.writeAsBytes(imageBytes);

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Check out this AI-generated image!');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
      debugPrint("Error sharing image: $e");
    }
  }
}
