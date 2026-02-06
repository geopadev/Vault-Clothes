enum ItemCondition {
  newWithOptions,
  newWithoutTags,
  excellent,
  good,
  fair,
  poor,
}

enum ItemCategory { top, bottom, outerwear, shoes, accessories }

class ListingModel {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final ItemCategory category;
  final ItemCondition condition;
  final String size;
  final bool isSold;
  final DateTime createdAt;

  ListingModel({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    required this.condition,
    required this.size,
    this.isSold = false,
    required this.createdAt,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as String,
      sellerId: json['sellerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      images: (json['images'] as List<dynamic>).cast<String>(),
      category: ItemCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ItemCategory.top,
      ),
      condition: ItemCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => ItemCondition.good,
      ),
      size: json['size'] as String,
      isSold: json['isSold'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'title': title,
      'description': description,
      'price': price,
      'images': images,
      'category': category.name,
      'condition': condition.name,
      'size': size,
      'isSold': isSold,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ListingModel copyWith({
    String? title,
    String? description,
    double? price,
    List<String>? images,
    ItemCategory? category,
    ItemCondition? condition,
    String? size,
    bool? isSold,
  }) {
    return ListingModel(
      id: id,
      sellerId: sellerId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      images: images ?? this.images,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      size: size ?? this.size,
      isSold: isSold ?? this.isSold,
      createdAt: createdAt,
    );
  }
}
