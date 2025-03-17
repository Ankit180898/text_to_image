import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> settingItems = [
      {'icon': Icons.brush, 'title': 'Default Style', 'subtitle': 'No Style'},
      {'icon': Icons.aspect_ratio, 'title': 'Default Aspect Ratio', 'subtitle': '1:1'},
      {'icon': Icons.cloud, 'title': 'Default Model', 'subtitle': 'Stable Diffusion v1.4'},
      {'icon': Icons.storage, 'title': 'Clear Cache', 'subtitle': '32.5 MB used'},
      {'icon': Icons.dark_mode, 'title': 'Dark Mode', 'subtitle': 'On'},
      {'icon': Icons.info, 'title': 'About', 'subtitle': 'Version 1.0.0'},
    ];

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = settingItems[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Color(0xFF1E1F2E), borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF6C39FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'], color: Color(0xFF6C39FF)),
                    ),
                    title: Text(item['title']),
                    subtitle: Text(item['subtitle'], style: TextStyle(color: Colors.grey)),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                );
              }, childCount: settingItems.length),
            ),
          ),
        ],
      ),
    );
  }
}
