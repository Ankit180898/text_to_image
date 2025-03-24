import 'dart:typed_data';

class ImageModel {
  final int id;
  final String prompt;
  final Uint8List image;
  final int? collectionId; // New field for collection

  ImageModel({
    required this.id,
    required this.prompt,
    required this.image,
    this.collectionId,
  });

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      id: map['id'],
      prompt: map['prompt'],
      image: map['image'],
      collectionId: map['collection_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prompt': prompt,
      'image': image,
      'collection_id': collectionId,
    };
  }
}
