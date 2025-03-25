import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_to_image/controllers/settings_controller.dart';
import 'package:text_to_image/controllers/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart' as url;

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final SettingsController controller = Get.put(SettingsController());
  final AuthController authController = Get.find();

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
                    // User Profile Section
                    Obx(() {
                      final user = authController.currentUser.value;
                      return user != null
                          ? _buildUserProfileSection(user)
                          : _buildSignInButton(context);
                    }),

                    // Rest of the existing settings remain the same...
                    // (Previous settings items from the original code)

                    const SizedBox(height: 20),
                    // Logout button (only show if user is signed in)
                    Obx(() {
                      final user = authController.currentUser.value;
                      return user != null
                          ? _buildLogoutButton(context)
                          : const SizedBox.shrink();
                    }),

                    // Existing "Made with ❤️ by Ankit" section
                    GestureDetector(
                      onTap: () {
                        url.launch('https://ankitdev18.netlify.app/#/minified:Fh');
                        Get.snackbar(
                          'Ankit',
                          'Opening my website...',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF1E1F2E),
                          colorText: Colors.white,
                        );
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          text: 'Made with ',
                          style: TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(text: '❤️', style: TextStyle(color: Colors.red)),
                            TextSpan(text: ' by ', style: TextStyle(color: Colors.grey)),
                            TextSpan(
                              text: 'Ankit',
                              style: TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

  // New method to build user profile section
  Widget _buildUserProfileSection(dynamic user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // User Avatar
          CircleAvatar(
            radius: 40,
            backgroundImage: user.userMetadata?['avatar_url'] != null
                ? NetworkImage(user.userMetadata['avatar_url'])
                : null,
            child: user.userMetadata?['avatar_url'] == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.userMetadata?['full_name'] ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email ?? 'No email',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to build sign-in button
  Widget _buildSignInButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: const Text(
          'Sign In with Google',
          style: TextStyle(color: Colors.white),
        ),
        trailing: const Icon(Icons.login, color: Color(0xFF6C39FF)),
        onTap: () => authController.signInWithGoogle(),
      ),
    );
  }

  // Method to build logout button
  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.red),
        ),
        trailing: const Icon(Icons.logout, color: Colors.red),
        onTap: () => authController.signOut(),
      ),
    );
  }

  // Existing methods remain the same...
  // (All other methods from the original SettingsScreen remain unchanged)
}