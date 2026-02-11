class FavoriteModel {
  final String listingId;
  final DateTime createdAt;

  const FavoriteModel({
    required this.listingId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'listingId': listingId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      listingId: json['listingId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
