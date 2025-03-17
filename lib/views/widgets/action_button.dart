import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionButton({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Color(0xFF1E1F2E), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Color(0xFF6C39FF)),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}