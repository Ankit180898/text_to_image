import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;
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
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:text_to_image/controllers/gallery_controller.dart';
import 'package:text_to_image/models/history_item_model.dart';
import 'package:text_to_image/service/database_helper.dart';
import 'package:text_to_image/service/subscription_service.dart';
import 'package:text_to_image/views/subscription_screen.dart';

class HomeController extends GetxController {
  final List<HistoryItem> history = [];
  final TextEditingController textController = TextEditingController();
  Uint8List? imageData;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxString selectedModel = 'stable-diffusion-v1-4'.obs;
  RxInt selectedAspectRatio = 1.obs; // 0: 1:1, 1: 16:9, 2: 9:16
  final galleryController = Get.put(GalleryController());

  // Get the subscription service
  final subscriptionService = Get.put(SubscriptionService());

  final List<String> models = ['stable-diffusion-v1-4', 'stable-diffusion-v2-1', 'sdxl', 'dalle-mini'];
  RxDouble qualityValue = 50.0.obs; // Default quality level

  final stt.SpeechToText speech = stt.SpeechToText();
  RxBool isListening = false.obs;
  RxString recognizedText = ''.obs;

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

  // Filtered models and styles based on subscription
  RxList<String> filteredModels = <String>[].obs;
  RxList<String> filteredStyles = <String>[].obs;

  // Limits based on subscription
  RxBool highQualityEnabled = false.obs;
  RxBool customAspectRatioEnabled = false.obs;
  RxBool voiceToTextEnabled = false.obs;
  RxBool saveToGalleryEnabled = true.obs;
  RxBool shareEnabled = false.obs;

  @override
  void onInit() {
    requestPermissions();
    initializeSpeech();
    updateSubscriptionFeatures();

    // Add listener to update features when subscription changes
    ever(subscriptionService.currentTier, (_) => updateSubscriptionFeatures());

    super.onInit();
  }

  void updateSubscriptionFeatures() {
    final features = subscriptionService.getFeatures();

    // Update available models
    filteredModels.value = models.where((model) => features.availableModels.contains(model)).toList();

    // Make sure the selected model is available, or select the first available
    if (!filteredModels.contains(selectedModel.value) && filteredModels.isNotEmpty) {
      selectedModel.value = filteredModels.first;
    }

    // Update available styles
    filteredStyles.value = stylePresets.where((style) => features.availableStyles.contains(style)).toList();

    // Make sure the selected style is available, or select the first available
    if (!filteredStyles.contains(selectedStyle.value) && filteredStyles.isNotEmpty) {
      selectedStyle.value = filteredStyles.first;
    }

    // Update feature flags
    highQualityEnabled.value = features.highQualityEnabled;
    customAspectRatioEnabled.value = features.customAspectRatioEnabled;
    voiceToTextEnabled.value = features.voiceToTextEnabled;
    saveToGalleryEnabled.value = features.saveToGalleryEnabled;
    shareEnabled.value = features.shareEnabled;

    // If high quality is not enabled, reset the quality value
    if (!highQualityEnabled.value && qualityValue.value > 50) {
      qualityValue.value = 50;
    }

    // If custom aspect ratio is not enabled, reset to 1:1
    if (!customAspectRatioEnabled.value) {
      selectedAspectRatio.value = 0; // 1:1
    }
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

    // Check if user has reached daily limit
    if (!subscriptionService.canGenerateImage()) {
      errorMessage.value = 'You\'ve reached your daily limit of images. Upgrade your plan for more!';
      _showSubscriptionDialog();
      return;
    }

    isLoading.value = true;
    imageData = null;
    errorMessage.value = '';

    try {
      final apiToken = dotenv.env['API_KEY'];
      final modelEndpoint = getModelEndpoint(selectedModel.value);

      // Get quality parameters based on subscription
      final baseWidth = 512;
      final baseHeight = 512;
      final inferenceSteps =
          highQualityEnabled.value
              ? (qualityValue > 70 ? 50 : (qualityValue > 40 ? 30 : 20))
              : 20; // Limit steps for free/basic

      final response = await http
          .post(
            Uri.parse(modelEndpoint),
            headers: {'Authorization': 'Bearer $apiToken', 'Content-Type': 'application/json'},
            body: json.encode({
              "inputs": textController.text,
              "parameters": {
                "style": selectedStyle.value != 'No Style' ? selectedStyle.value.toLowerCase() : null,
                "aspect_ratio": getAspectRatioValue(),
                // Adjust quality based on subscription
                "width": highQualityEnabled.value ? (baseWidth + (qualityValue / 100 * 256)).round() : baseWidth,
                "height": highQualityEnabled.value ? (baseHeight + (qualityValue / 100 * 256)).round() : baseHeight,
                "num_inference_steps": inferenceSteps,
                "guidance_scale": 7.5,
                "seed": DateTime.now().millisecondsSinceEpoch,
              },
            }),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw Exception(
                'Request timed out. The server may be busy or the image generation is taking longer than expected.',
              );
            },
          );

      if (response.statusCode == 200) {
        imageData = response.bodyBytes;

        // Increment the image count for today
        await subscriptionService.incrementImageCount();

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

  Map<String, dynamic> getQualityParameters() {
    final quality = qualityValue.value;

    // Limit quality based on subscription
    final adjustedQuality = highQualityEnabled.value ? quality : Math.min(quality, 50.0);

    return {
      "width": (512 + (adjustedQuality / 100 * 512)).round(),
      "height": (512 + (adjustedQuality / 100 * 512)).round(),
      "num_inference_steps": (20 + (adjustedQuality / 100 * 30)).round(),
      "guidance_scale": 7.5,
    };
  }

  Future<void> saveImageToGallery(Uint8List imageBytes) async {
    // Check if user has permission to save to gallery
    if (!saveToGalleryEnabled.value) {
      Get.snackbar(
        'Feature Locked',
        'Upgrade your subscription to save images to your gallery',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
      return;
    }

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
    // Check if user has permission to share
    if (!shareEnabled.value) {
      Get.snackbar(
        'Feature Locked',
        'Upgrade your subscription to share images',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
      return;
    }

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

  Future<void> initializeSpeech() async {
    bool available = await speech.initialize();
    if (!available) {
      Get.snackbar('Error', 'Speech recognition not available');
    }
  }

  void startListening() async {
    // Check if voice-to-text is enabled for this subscription tier
    if (!voiceToTextEnabled.value) {
      Get.snackbar(
        'Feature Locked',
        'Voice-to-text is available with the Basic plan and above',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (!isListening.value) {
      isListening.value = true;
      recognizedText.value = '';
      speech.listen(
        onResult: (result) {
          recognizedText.value = result.recognizedWords;
          if (result.finalResult) {
            isListening.value = false;
            textController.text = recognizedText.value;
          }
        },
      );
    }
  }

  void stopListening() {
    if (isListening.value) {
      speech.stop();
      isListening.value = false;
    }
  }

  int getRemainingGenerations() {
    return subscriptionService.getRemainingGenerations();
  }

  void _showSubscriptionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Daily Limit Reached'),
        content: const Text(
          'You\'ve reached your daily limit of image generations. Upgrade your subscription to continue generating images.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Not Now')),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close the dialog
              Get.to(() => SubscriptionScreen()); // Navigate to the subscription screen
            },
            child: const Text('Upgrade Plan'),
          ),
        ],
      ),
    );
  }
}
