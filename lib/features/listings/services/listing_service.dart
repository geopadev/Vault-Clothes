import 'package:vault_clothes/core/services/database_connector.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';

class ListingService {
  final DatabaseConnector _db;
  static const String _collection = 'listings';

  ListingService(this._db);

  Future<void> createListing(ListingModel listing) async {
    await _db.saveDocument(_collection, listing.id, listing.toJson());
  }

  Future<ListingModel?> getListing(String id) async {
    final data = await _db.getDocument(_collection, id);
    if (data == null) return null;
    return ListingModel.fromJson(data);
  }

  Stream<List<ListingModel>> getFeed() {
    return _db
        .collectionStream(_collection, orderBy: 'createdAt', descending: true)
        .map(
          (list) => list.map((data) => ListingModel.fromJson(data)).toList(),
        );
  }

  Stream<List<ListingModel>> getUserListings(String userId) {
    // Note: DatabaseConnector needs a 'where' clause support for meaningful filtering.
    // For now, we filter client-side or assume we'll add 'where' to connector later.
    // This is a temporary simpler implementation.
    return getFeed().map(
      (list) => list.where((l) => l.sellerId == userId).toList(),
    );
  }

  Future<void> deleteListing(String id) async {
    await _db.deleteDocument(_collection, id);
  }
}
