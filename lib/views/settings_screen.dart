import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_to_image/controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          // Apply the same gradient background as the main screen
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
                    'Settings',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Default Style
                    Obx(
                      () => _buildSettingItem(
                        context: context,
                        icon: Icons.brush,
                        title: 'Default Style',
                        subtitle: controller.defaultStyle.value,
                        onTap: () => _showStylePicker(context),
                      ),
                    ),

                    // Default Aspect Ratio
                    Obx(
                      () => _buildSettingItem(
                        context: context,
                        icon: Icons.aspect_ratio,
                        title: 'Default Aspect Ratio',
                        subtitle: controller.defaultAspectRatio.value,
                        onTap: () => _showAspectRatioPicker(context),
                      ),
                    ),

                    // Default Model
                    Obx(
                      () => _buildSettingItem(
                        context: context,
                        icon: Icons.cloud,
                        title: 'Default Model',
                        subtitle: controller.defaultModel.value,
                        onTap: () => _showModelPicker(context),
                      ),
                    ),

                    // Clear Cache
                    Obx(
                      () => _buildSettingItem(
                        context: context,
                        icon: Icons.storage,
                        title: 'Clear Cache',
                        subtitle: '${controller.cacheSize.value.toStringAsFixed(2)} MB used',
                        onTap: () => _showClearCacheDialog(context),
                      ),
                    ),

                    // Dark Mode Toggle
                    Obx(
                      () => _buildToggleSetting(
                        icon: Icons.dark_mode,
                        title: 'Dark Mode',
                        value: controller.darkMode.value,
                        onChanged: (value) {
                          controller.toggleDarkMode();
                        },
                      ),
                    ),

                    // About
                    Obx(
                      () => _buildSettingItem(
                        context: context,
                        icon: Icons.info,
                        title: 'About',
                        subtitle: 'Version ${controller.appVersion.value}',
                        onTap: () => _showAboutDialog(context),
                      ),
                    ),

                    // Add Rate App Option
                    _buildSettingItem(
                      context: context,
                      icon: Icons.star,
                      title: 'Rate App',
                      subtitle: 'Leave us a review',
                      onTap: () {
                        // Logic to open app store/play store
                        Get.snackbar(
                          'Rate App',
                          'Opening app store...',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF1E1F2E),
                          colorText: Colors.white,
                        );
                      },
                    ),

                    // Add Share App Option
                    _buildSettingItem(
                      context: context,
                      icon: Icons.share,
                      title: 'Share App',
                      subtitle: 'Share with friends',
                      onTap: () {
                        // Logic to share app
                        Get.snackbar(
                          'Share App',
                          'Opening share sheet...',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF1E1F2E),
                          colorText: Colors.white,
                        );
                      },
                    ),

                    // Account Settings
                    _buildSettingItem(
                      context: context,
                      icon: Icons.person,
                      title: 'Account',
                      subtitle: 'Manage your account',
                      onTap: () {
                        Get.snackbar(
                          'Account',
                          'Coming soon!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF1E1F2E),
                          colorText: Colors.white,
                        );
                      },
                    ),

                    // Add some space at the bottom
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build a standard setting item
  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFF1E1F2E), borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6C39FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6C39FF)),
          ),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }

  // Build a toggle setting item
  Widget _buildToggleSetting({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFF1E1F2E), borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF6C39FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF6C39FF)),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF6C39FF)),
      ),
    );
  }

  // Show style picker
  void _showStylePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1F2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Select Default Style',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.availableStyles.length,
                    itemBuilder: (context, index) {
                      final style = controller.availableStyles[index];
                      return ListTile(
                        title: Text(style, style: const TextStyle(color: Colors.white)),
                        trailing:
                            controller.defaultStyle.value == style
                                ? const Icon(Icons.check, color: Color(0xFF6C39FF))
                                : null,
                        onTap: () {
                          controller.defaultStyle.value = style;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Show aspect ratio picker
  void _showAspectRatioPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1F2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Select Default Aspect Ratio',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: controller.availableAspectRatios.length,
                    itemBuilder: (context, index) {
                      final ratio = controller.availableAspectRatios[index];
                      final isSelected = controller.defaultAspectRatio.value == ratio;

                      return GestureDetector(
                        onTap: () {
                          controller.updateSelectedAspectRatio(ratio);
                          controller.defaultAspectRatio.value = ratio;
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6C39FF) : const Color(0xFF2A2B3D),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              ratio,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Show model picker
  void _showModelPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1F2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Select Default Model',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.availableModels.length,
                    itemBuilder: (context, index) {
                      final model = controller.availableModels[index];
                      return ListTile(
                        title: Text(model, style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          index == 0
                              ? 'Fast, efficient'
                              : index == 1
                              ? 'Improved quality'
                              : index == 2
                              ? 'High detail'
                              : 'Premium quality',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing:
                            controller.defaultModel.value == model
                                ? const Icon(Icons.check, color: Color(0xFF6C39FF))
                                : null,
                        onTap: () {
                          controller.defaultModel.value = model;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Show clear cache dialog
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1F2E),
            title: const Text('Clear Cache', style: TextStyle(color: Colors.white)),
            content: const Text(
              'This will clear all temporary files. Your saved images will not be affected.',
              style: TextStyle(color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Show loading indicator
                  Get.dialog(
                    const Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C39FF))),
                    ),
                    barrierDismissible: false,
                  );

                  await controller.clearCache();
                  Get.back(); // Close loading dialog

                  Get.snackbar(
                    'Cache Cleared',
                    'All temporary files have been removed',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF1E1F2E),
                    colorText: Colors.white,
                  );
                },
                child: const Text('Clear', style: TextStyle(color: Color(0xFF6C39FF))),
              ),
            ],
          ),
    );
  }

  // Show about dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1F2E),
            title: const Text('About Vision AI', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(color: const Color(0xFF6C39FF).withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.auto_awesome, size: 40, color: Color(0xFF6C39FF)),
                ),
                const SizedBox(height: 16),
                Obx(() => Text('Version ${controller.appVersion.value}', style: const TextStyle(color: Colors.white))),
                const SizedBox(height: 8),
                const Text('© 2025 Vision AI', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                const Text(
                  'Vision AI is an advanced text-to-image generation app powered by state-of-the-art AI models.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Open privacy policy
                  Navigator.pop(context);
                  Get.snackbar(
                    'Privacy Policy',
                    'Opening privacy policy...',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF1E1F2E),
                    colorText: Colors.white,
                  );
                },
                child: const Text('Privacy Policy', style: TextStyle(color: Color(0xFF6C39FF))),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
    );
  }
}
