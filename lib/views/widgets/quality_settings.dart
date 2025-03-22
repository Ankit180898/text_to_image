import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:text_to_image/controllers/home_controller.dart';

class QualitySettings extends StatelessWidget {
  final HomeController controller;

  const QualitySettings({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quality Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Obx(() => Slider(
          value: controller.qualityValue.value,
          min: 1,
          max: 100,
          divisions: 4,
          label: controller.qualityValue.value.round().toString(),
          onChanged: (value) {
            controller.qualityValue.value = value;
          },
        )),
        Obx(() => Text(
          'Quality Level: ${controller.qualityValue.value.round()}',
          style: const TextStyle(fontSize: 14),
        )),
      ],
    );
  }
}