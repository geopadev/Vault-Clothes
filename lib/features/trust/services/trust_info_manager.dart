import 'package:vault_clothes/core/services/database_connector.dart';
import 'package:vault_clothes/features/trust/models/review_model.dart';
import 'package:vault_clothes/features/trust/models/trust_info_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrustInfoManager {
  final DatabaseConnector _db;

  TrustInfoManager(this._db);

  /// Fetches the trust info for a given seller.
  /// If no info exists, returns a default 'new seller' profile.
  Future<TrustInfoModel> getTrustInfo(String sellerId) async {
    final data = await _db.getDocument('users/$sellerId/trust', 'info');

    if (data == null) {
      // Fetch user creation date if possible, but for default return now()
      // In a real app we'd fetch the user document to get 'createdAt'
      return TrustInfoModel(
        sellerId: sellerId,
        averageRating: 0.0,
        totalReviews: 0,
        totalSales: 0,
        memberSince: DateTime.now(), 
        verificationLevel: VerificationLevel.unverified,
      );
    }

    // Ensure memberSince is correctly parsed if it's a timestamp
    if (data['memberSince'] is Timestamp) {
      data['memberSince'] = (data['memberSince'] as Timestamp).toDate().toIso8601String();
    }

    return TrustInfoModel.fromJson(data);
  }

  /// Fetches recent reviews for a seller from their sub-collection.
  Stream<List<ReviewModel>> getReviewsStream(String sellerId, {int limit = 10}) {
    return _db.collectionStream(
      'users/$sellerId/reviews',
      orderBy: 'createdAt',
      descending: true,
      limit: limit, // Add limit to connector interface if missing
    ).map((list) => list.map((json) {
       // Handle timestamp conversion if needed
       if (json['createdAt'] is Timestamp) {
         json['createdAt'] = (json['createdAt'] as Timestamp).toDate().toIso8601String();
       }
       return ReviewModel.fromJson(json);
    }).toList());
  }

  /// Fetches reviews once (as a Future).
  Future<List<ReviewModel>> getReviews(String sellerId, {int limit = 10}) async {
    return await getReviewsStream(sellerId, limit: limit).first;
  }
}
