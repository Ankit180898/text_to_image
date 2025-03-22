import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_to_image/controllers/gallery_controller.dart';
import 'package:text_to_image/controllers/home_controller.dart';

class GalleryScreen extends StatelessWidget {
  final controller = Get.find<GalleryController>();
  final homeController = Get.find<HomeController>();
  
  GalleryScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF090A13), Color(0xFF0F1024)],
            ),
          ),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 120,
                floating: false,
                pinned: true,
                elevation: 0,
                flexibleSpace: const FlexibleSpaceBar(
                  title: Text(
                    'Gallery',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: Obx(() {
                  if (controller.images.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: Text("No Images Saved!", style: TextStyle(fontSize: 18, color: Colors.white70))),
                    );
                  }
                  
                  return SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      var data = controller.images[index];
                      return GestureDetector(
                        onTap: () => _showImageDetailDialog(context, data),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.memory(data.image, fit: BoxFit.cover),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black87],
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  child: Text(
                                    data.prompt,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: controller.images.length),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

 void _showImageDetailDialog(BuildContext context, var imageData) { 
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF090A13),
        ),
        child: Stack(
          children: [
            // Image viewer with interactive viewer for zooming
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Image.memory(imageData.image),
              ),
            ),
            // Close button
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
            // Bottom panel with prompt and actions
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Prompt:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      imageData.prompt,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildActionButton(
                          icon: Icons.save_alt,
                          label: 'Save',
                          onTap: () => homeController.saveImageToGallery(imageData.image),
                        ),
                        buildActionButton(
                          icon: Icons.share,
                          label: 'Share',
                          onTap: () => homeController.shareImage(imageData.image),
                        ),
                        buildActionButton(
                          icon: Icons.delete,
                          label: 'Delete',
                          onTap: () => controller.deleteImage(imageData.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildActionButton({required IconData icon, required String label, required Function() onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
}