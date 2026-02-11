/// Represents a single buyer review for a seller.
class ReviewModel {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String sellerId;
  final String orderId;
  final int rating; // 1-5 stars
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.sellerId,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  }) : assert(rating >= 1 && rating <= 5, 'Rating must be between 1 and 5');

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      reviewerId: json['reviewerId'] as String,
      reviewerName: json['reviewerName'] as String,
      sellerId: json['sellerId'] as String,
      orderId: json['orderId'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'sellerId': sellerId,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
