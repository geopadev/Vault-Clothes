import 'package:vault_clothes/core/services/database_connector.dart';
import 'package:vault_clothes/features/auth/services/account_authentication.dart';
import 'package:vault_clothes/features/favorites/models/favorite_model.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/listings/services/listing_service.dart';

/// Service to manage user favorites (add, remove, list).
class FavoritesService {
  final DatabaseConnector _db;
  final AccountAuthentication _auth;
  final ListingService _listingService;

  FavoritesService(this._db, this._auth, this._listingService);

  String? get _userId => _auth.currentUser?.uid;

  String _favoritesPath(String uid) => 'users/$uid/favorites';

  Future<void> toggleFavorite(String listingId) async {
    final uid = _userId;
    if (uid == null) {
      throw Exception('User must be logged in to favorite items');
    }

    final path = _favoritesPath(uid);
    final docId = listingId;

    final exists = await _db.getDocument(path, docId);

    if (exists != null) {
      await _db.deleteDocument(path, docId);
    } else {
      final favorite = FavoriteModel(
        listingId: listingId,
        createdAt: DateTime.now(),
      );
      await _db.saveDocument(path, docId, favorite.toJson());
    }
  }

  Stream<List<String>> getFavoriteIdsStream() {
    final uid = _userId;
    if (uid == null) return Stream.value([]);

    return _db
        .collectionStream(
          _favoritesPath(uid),
          orderBy: 'createdAt',
          descending: true,
        )
        .map(
          (docs) =>
              docs.map((doc) => FavoriteModel.fromJson(doc).listingId).toList(),
        );
  }

  Future<List<ListingModel>> getFavoriteListings(List<String> ids) async {
    if (ids.isEmpty) return [];

    final futures = ids.map((id) => _listingService.getListing(id));
    final results = await Future.wait(futures);

    return results.whereType<ListingModel>().toList();
  }
}
