import 'package:vault_clothes/core/services/database_connector.dart';
import 'package:vault_clothes/features/listings/models/filter_options.dart';
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

  Stream<List<ListingModel>> searchListings(FilterOptions options) {
    // 1. Base Query: Start with all listings sorted by recency
    // Note: In a real app with 1M+ items, we'd need composite indexes or a search engine (Algolia).
    // For MVP (<1000 items), client-side filtering after fetching a reasonable subset is acceptable strategy.
    // However, we can apply exact matches on the server.

    // WARNING: Firestore Limitation
    // We cannot filter by multiple different fields easily without composite indexes for every combination.
    // Example: .where('category', ...).where('price', ...) requires an index.
    // To avoid complex index management for this MVP, we will fetch the 'Feed' (or filter by one main field if possible)
    // and do advanced filtering in memory.

    Stream<List<ListingModel>> stream = getFeed();

    return stream.map((listings) {
      return listings.where((item) {
        // 1. Text Search (Case-insensitive title/desc)
        if (options.searchQuery != null && options.searchQuery!.isNotEmpty) {
          final query = options.searchQuery!.toLowerCase();
          final matchesTitle = item.title.toLowerCase().contains(query);
          final matchesDesc = item.description.toLowerCase().contains(query);
          if (!matchesTitle && !matchesDesc) return false;
        }

        // 2. Category
        if (options.category != null && item.category != options.category) {
          return false;
        }

        // 3. Condition
        if (options.condition != null && item.condition != options.condition) {
          return false;
        }

        // 4. Size (Exact match for now)
        if (options.size != null && options.size!.isNotEmpty) {
          if (item.size.toLowerCase() != options.size!.toLowerCase())
            return false;
        }

        // 5. Price Range
        if (options.minPrice != null && item.price < options.minPrice!)
          return false;
        if (options.maxPrice != null && item.price > options.maxPrice!)
          return false;

        return true;
      }).toList();
    });
  }

  Future<void> deleteListing(String id) async {
    await _db.deleteDocument(_collection, id);
  }
}
