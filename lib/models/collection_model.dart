class CollectionModel {
  final int id;
  final String name;
  final String? description;
  final int createdAt;
  final int imageCount;

  CollectionModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.imageCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
    };
  }

  static CollectionModel fromMap(Map<String, dynamic> map) {
    return CollectionModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: map['created_at'],
      imageCount: map['image_count'] ?? 0,
    );
  }
}