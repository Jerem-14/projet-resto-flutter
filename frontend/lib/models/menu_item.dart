class MenuItem {
  final int id;
  final String category;
  final String name;
  final String description;
  final double price;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItem({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      category: json['category'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      isAvailable: json['is_available'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'description': description,
      'price': price,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 