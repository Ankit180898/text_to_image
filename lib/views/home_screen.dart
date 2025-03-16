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
              decoration: BoxDecoration(
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
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Vision AI',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                  ),
                ),

                // Main content
                Obx(()=>
                   SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Prompt input
                          Text('Create', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text(
                            'Type your prompt to generate an image',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF1E1F2E),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                            ),
                            child: TextField(
                              controller: controller.textController,
                              style: TextStyle(color: Colors.white),
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Type your prompt here...',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                                suffixIcon: IconButton(icon: Icon(Icons.mic, color: Colors.grey), onPressed: () {}),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                  
                          // Style presets
                          Text('Style', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.stylePresets.length,
                              itemBuilder: (context, index) {
                                var a = controller.stylePresets[index];
                                return Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(a),
                                    selected: index == 0,
                                    onSelected: (bool selected) {},
                                    backgroundColor: Color(0xFF1E1F2E),
                                    selectedColor: Color(0xFF6C39FF),
                                    checkmarkColor: Colors.white,
                                    labelStyle: TextStyle(color: Colors.white),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                  
                          // Aspect ratio
                          Text('Aspect Ratio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    controller.selectedAspectRatio.value = 0;
                                  },
                                  child: AspectRatioOption(title: '1:1', isSelected: controller.selectedAspectRatio == 0),
                                ),
                              ),
                              SizedBox(width: 8),
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
                              SizedBox(width: 8),
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
                          SizedBox(height: 20),
                  
                          // Generate button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value ? null : controller.generateImage,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color(0xFF6C39FF),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child:
                                  controller.isLoading.value
                                      ? CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                        'Generate Image',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                            ),
                          ),
                          SizedBox(height: 20),
                  
                          // Error message
                          if (controller.errorMessage.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(controller.errorMessage.value, style: TextStyle(color: Colors.red)),
                            ),
                  
                          // Recent prompts
                          if (controller.recentPrompts.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Recent Prompts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: controller.recentPrompts.length > 3 ? 3 : controller.recentPrompts.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          controller.textController.text = controller.recentPrompts[index];
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 8),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF1E1F2E),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.history, color: Colors.grey),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  controller.recentPrompts[index],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
                                Text('Generated Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.memory(controller.imageData!, fit: BoxFit.cover),
                                  ),
                                ),
                                SizedBox(height: 16),
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
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Image saved to gallery'),
                                            backgroundColor: Color(0xFF6C39FF),
                                          ),
                                        );
                                      },
                                    ),
                                    ActionButton(icon: Icons.share, label: 'Share', onTap: () {}),
                                  ],
                                ),
                                SizedBox(height: 30),
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
}

class AspectRatioOption extends StatelessWidget {
  final String title;
  final bool isSelected;

  const AspectRatioOption({super.key, required this.title, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF6C39FF) : Color(0xFF1E1F2E),
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
