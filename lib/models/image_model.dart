import 'dart:typed_data';

class ImageModel {
  final int id;
  final String prompt;
  final Uint8List image;

  ImageModel({required this.id, required this.prompt, required this.image});

  // Convert Map to Model
  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      id: map['id'],
      prompt: map['prompt'],
      image: Uint8List.fromList(map['image'] as List<int>),
    );
  }
}
