import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_to_image/controllers/home_controller.dart';
import 'package:text_to_image/views/widgets/action_button.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF090A13), Color(0xFF0F1024)],
                ),
              ),
            ),

            // Content
            CustomScrollView(
              slivers: [
                // App bar
                SliverAppBar(
                  backgroundColor: Colors.black54,
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  flexibleSpace: const FlexibleSpaceBar(
                    title: Text(
                      'Vision AI',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                  ),
                ),

                // Main content
                Obx(
                  () => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Prompt input
                          const Text('Create', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          const Text(
                            'Type your prompt to generate an image',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1F2E),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                            ),
                            child: TextField(
                              controller: controller.textController,
                              style: const TextStyle(color: Colors.white),
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Type your prompt here...',
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.mic, color: Colors.grey), 
                                  onPressed: () {}
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Model selection
                          const Text('Model', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1F2E),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: controller.selectedModel.value,
                                dropdownColor: const Color(0xFF1E1F2E),
                                style: const TextStyle(color: Colors.white),
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                items: controller.models.map((String model) {
                                  return DropdownMenuItem<String>(
                                    value: model,
                                    child: Text(model),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    controller.selectedModel.value = newValue;
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Style presets
                          const Text('Style', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.stylePresets.length,
                              itemBuilder: (context, index) {
                                var style = controller.stylePresets[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Obx(
                                    () => ChoiceChip(
                                      label: Text(style),
                                      selected: controller.selectedStyle.value == style,
                                      onSelected: (bool selected) {
                                        if (selected) {
                                          controller.selectedStyle.value = style;
                                        }
                                      },
                                      backgroundColor: const Color(0xFF1E1F2E),
                                      selectedColor: const Color(0xFF6C39FF),
                                      checkmarkColor: Colors.white,
                                      labelStyle: const TextStyle(color: Colors.white),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Aspect ratio
                          const Text('Aspect Ratio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    controller.selectedAspectRatio.value = 0;
                                  },
                                  child: AspectRatioOption(
                                    title: '1:1',
                                    isSelected: controller.selectedAspectRatio.value == 0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    controller.selectedAspectRatio.value = 1;
                                  },
                                  child: AspectRatioOption(
                                    title: '16:9',
                                    isSelected: controller.selectedAspectRatio.value == 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    controller.selectedAspectRatio.value = 2;
                                  },
                                  child: AspectRatioOption(
                                    title: '9:16',
                                    isSelected: controller.selectedAspectRatio.value == 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Generate button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value ? null : controller.generateImage,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF6C39FF),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child:
                                  controller.isLoading.value
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text(
                                        'Generate Image',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Error message
                          if (controller.errorMessage.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
                            ),

                          // Recent prompts
                          if (controller.recentPrompts.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Recent Prompts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        controller.recentPrompts.length > 3 ? 3 : controller.recentPrompts.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          controller.textController.text = controller.recentPrompts[index];
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E1F2E),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.history, color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  controller.recentPrompts[index],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                          // Generated image
                          if (controller.imageData != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Generated Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.memory(controller.imageData!, fit: BoxFit.cover),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ActionButton(
                                      icon: Icons.refresh,
                                      label: 'Regenerate',
                                      onTap: controller.generateImage,
                                    ),
                                    ActionButton(
                                      icon: Icons.save_alt,
                                      label: 'Save',
                                      onTap: () async {
                                        await controller.saveImageToGallery(controller.imageData!);
                                      },
                                    ),
                                    ActionButton(
                                      icon: Icons.share,
                                      label: 'Share',
                                      onTap: () async {
                                        await controller.shareImage(controller.imageData!);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void showImageBottomSheet(BuildContext context, ImageController controller) {
  showCupertinoModalBottomSheet(
    context: context,
    backgroundColor: CupertinoColors.systemBackground.darkColor,
    elevation: 10,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Generated Image',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: CupertinoColors.systemGrey,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: controller.imageData != null
                      ? Image.memory(controller.imageData!, fit: BoxFit.cover)
                      : const CupertinoActivityIndicator(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCupertinoActionButton(
                  CupertinoIcons.refresh,
                  'Regenerate',
                  controller.generateImage,
                ),
                _buildCupertinoActionButton(
                  CupertinoIcons.arrow_down_circle,
                  'Save',
                  () async {
                    await controller.saveImageToGallery(controller.imageData!);
                    if (context.mounted) {
                      _showSuccessToast(context, 'Image saved to gallery');
                    }
                  },
                ),
                _buildCupertinoActionButton(
                  CupertinoIcons.share,
                  'Share',
                  () async {
                    await controller.shareImage(controller.imageData!);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

Widget _buildCupertinoActionButton(IconData icon, String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: CupertinoColors.systemIndigo.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: CupertinoColors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}


}

class AspectRatioOption extends StatelessWidget {
  final String title;
  final bool isSelected;

  const AspectRatioOption({super.key, required this.title, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6C39FF) : const Color(0xFF1E1F2E),
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}