import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              title: Text('Gallery', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Color(0xFF1E1F2E),
                    child: Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                  ),
                );
              }, childCount: 10),
            ),
          ),
        ],
      ),
    );
  }
}