import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_to_image/controllers/home_controller.dart';

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
                  backgroundColor: Colors.transparent, // Changed to transparent
                  expandedHeight: 40,
                  floating: false,
                  pinned: true,
                  centerTitle: true,
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
                                suffixIcon: Obx(
                                  () => IconButton(
                                    icon: Icon(
                                      controller.isListening.value ? Icons.mic_off : Icons.mic,
                                      color: controller.isListening.value ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () {
                                      if (controller.isListening.value) {
                                        controller.stopListening();
                                      } else {
                                        controller.startListening();
                                      }
                                    },
                                  ),
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
                                items:
                                    controller.models.map((String model) {
                                      return DropdownMenuItem<String>(value: model, child: Text(model));
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
                          // Quality slider
                          const Text('Quality', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Obx(
                            () => Slider(
                              value: controller.qualityValue.value,
                              min: 0,
                              max: 100,
                              divisions: 4,
                              label: controller.qualityValue.value.round().toString(),
                              onChanged: (value) {
                                controller.qualityValue.value = value;
                              },
                              activeColor: const Color(0xFF6C39FF), // Added for consistent color scheme
                              inactiveColor: Colors.grey.withOpacity(0.3), // Improved inactive track color
                            ),
                          ),
                          Obx(
                            () => Text(
                              'Quality Level: ${controller.qualityValue.value.round()}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Generate button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  controller.isLoading.value
                                      ? null
                                      : () async {
                                        await controller.generateImage();
                                        // Show image in CupertinoActionSheet if generation was successful
                                        if (controller.imageData != null) {
                                          _showImageSheet(context);
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF6C39FF),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child:
                                  controller.isLoading.value
                                      ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Generating...',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
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
                                  const Text(
                                    'Recent Prompts',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
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
                                                  style: const TextStyle(color: Colors.white), // Added text color
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
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Voice Recognition Overlay - Fixed
            Obx(() {
              if (controller.isListening.value) {
                return Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.mic, color: Colors.red, size: 60),
                          const SizedBox(height: 20),
                          const Text(
                            'Listening...',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1F2E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              controller.recognizedText.value.isEmpty
                                  ? 'Say something...'
                                  : controller.recognizedText.value,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () => controller.stopListening(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(16),
                            ),
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }

  // Method to show the generated image in a CupertinoActionSheet
  void _showImageSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title: const Text(
              'Generated Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6C39FF)),
            ),
            message: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    controller.imageData!,
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width * 0.9,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context: context,
                      icon: Icons.refresh,
                      label: 'Regenerate',
                      onTap: () {
                        Navigator.pop(context);
                        controller.generateImage();
                      },
                    ),
                    _buildActionButton(
                      context: context,
                      icon: Icons.save_alt,
                      label: 'Save',
                      onTap: () async {
                        await controller.saveImageToGallery(controller.imageData!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(const SnackBar(content: Text('Image saved to gallery')));
                        }
                      },
                    ),
                    _buildActionButton(
                      context: context,
                      icon: Icons.share,
                      label: 'Share',
                      onTap: () async {
                        await controller.shareImage(controller.imageData!);
                      },
                    ),
                  ],
                ),
              ],
            ),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ),
    );
  }

  // Helper method to build action buttons for the CupertinoActionSheet
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: onTap, icon: Icon(icon), color: const Color(0xFF6C39FF), iconSize: 28),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
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
