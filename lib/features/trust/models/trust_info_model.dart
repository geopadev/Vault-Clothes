/// Aggregated trust and reputation data for a seller.
///
/// Computed from individual reviews and account metadata.
/// Used by the PublicProfileScreen to display seller credibility.
enum VerificationLevel { unverified, basic, verified, trusted }

class TrustInfoModel {
  final String sellerId;
  final double averageRating;
  final int totalReviews;
  final int totalSales;
  final DateTime memberSince;
  final VerificationLevel verificationLevel;

  TrustInfoModel({
    required this.sellerId,
    required this.averageRating,
    required this.totalReviews,
    required this.totalSales,
    required this.memberSince,
    required this.verificationLevel,
  });

  /// Convenience getter: how long the account has been active.
  Duration get accountAge => DateTime.now().difference(memberSince);

  /// Whether the seller is considered "established" (has >= 5 reviews and >= 3.5 avg).
  bool get isEstablished => totalReviews >= 5 && averageRating >= 3.5;

  factory TrustInfoModel.fromJson(Map<String, dynamic> json) {
    return TrustInfoModel(
      sellerId: json['sellerId'] as String,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      totalSales: (json['totalSales'] as num).toInt(),
      memberSince: DateTime.parse(json['memberSince'] as String),
      verificationLevel: VerificationLevel.values.firstWhere(
        (v) => v.name == json['verificationLevel'],
        orElse: () => VerificationLevel.unverified,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sellerId': sellerId,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'totalSales': totalSales,
      'memberSince': memberSince.toIso8601String(),
      'verificationLevel': verificationLevel.name,
    };
  }
}
