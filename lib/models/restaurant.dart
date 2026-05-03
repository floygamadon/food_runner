class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory Restaurant.fromMap(String id, Map<String, dynamic> data) {
    return Restaurant(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}