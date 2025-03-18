import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_to_image/models/image_model.dart';
import 'package:text_to_image/service/database_helper.dart';

class GalleryController extends GetxController {
  RxList<ImageModel> images = <ImageModel>[].obs;

  @override
  void onInit() {
    fetchImages();
    super.onInit();
  }

  Future<void> fetchImages() async {
    final data = await DatabaseHelper.getImages();
    images.value = data;
  }

  Future<void> deleteImage(int id) async {
    await DatabaseHelper.deleteImage(id);

    await fetchImages();

    Get.back();
    Get.snackbar(
      'Success',
      'Image deleted successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }
}
