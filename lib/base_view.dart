import 'package:flutter/material.dart';
import 'package:text_to_image/views/gallery_screen.dart';
import 'package:text_to_image/views/home_screen.dart';
import 'package:text_to_image/views/settings_screen.dart';

class TextToImageApp extends StatefulWidget {
  const TextToImageApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TextToImageAppState createState() => _TextToImageAppState();
}

class _TextToImageAppState extends State<TextToImageApp> {
  int _currentIndex = 0;
  final List<Widget> _screens = [HomeScreen(), GalleryScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1E1F2E),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Color(0xFF1E1F2E),
            selectedItemColor: Color(0xFF6C39FF),
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            elevation: 0,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.photo_library_outlined),
                activeIcon: Icon(Icons.photo_library),
                label: 'Gallery',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
