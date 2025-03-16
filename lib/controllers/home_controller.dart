import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:text_to_image/models/history_item_model.dart';
class HomeController extends GetxController{
  final List<HistoryItem> history = [];
  final TextEditingController textController = TextEditingController();
  Uint8List? imageData;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  final String selectedModel = 'stable-diffusion-v1-4';
   RxInt selectedAspectRatio = 1.obs; // 0: 1:1, 1: 16:9, 2: 9:16

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

  List<String> recentPrompts = [
    'A magical forest with glowing mushrooms and fairy lights',
    'Futuristic city skyline at sunset',
    'Abstract geometric patterns in vibrant colors',
    'Serene mountain landscape with a reflective lake',
  ];

  

  String getModelEndpoint(String model) {
    switch (model) {
      case 'stable-diffusion-v2-1':
        return 'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-2-1';
      case 'sdxl':
        return 'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0';
      case 'dalle-mini':
        return 'https://api-inference.huggingface.co/models/dalle-mini/dalle-mini';
      case 'stable-diffusion-v1-4':
      default:
        return 'https://api-inference.huggingface.co/models/CompVis/stable-diffusion-v1-4';
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
      final apiToken = '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'; // Replace with your API token
      final modelEndpoint = getModelEndpoint(selectedModel);

      final response = await http
          .post(
            Uri.parse(modelEndpoint),
            headers: {'Authorization': 'Bearer $apiToken', 'Content-Type': 'application/json'},
            body: json.encode({'inputs': textController.text}),
          )
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timed out. The server may be busy.');
            },
          );

      if (response.statusCode == 200) {
          imageData = response.bodyBytes;
          isLoading.value = false;

          // Add to history
           history.add(HistoryItem(prompt:  textController.text, imageData: response.bodyBytes, timestamp: DateTime.now()));

          // Add to recent prompts if not already there
          if (! recentPrompts.contains( textController.text)) {
             recentPrompts.insert(0,  textController.text);
            if ( recentPrompts.length > 10) {
               recentPrompts.removeLast();
            }
          }
      } else {
           isLoading.value = false;
           errorMessage.value = 'Error ${response.statusCode}: ${response.reasonPhrase}';
        
        print('Error response: ${response.body}');
      }
    } catch (e) {
         isLoading.value = false;
         errorMessage.value = 'Error: ${e.toString()}';
      print('Exception caught: $e');
    }
  }
}