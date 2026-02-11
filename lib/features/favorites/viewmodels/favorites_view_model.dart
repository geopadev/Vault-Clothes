import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:vault_clothes/features/favorites/services/favorites_service.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/core/viewmodels/base_view_model.dart';

class FavoritesViewModel extends BaseViewModel {
  final FavoritesService _favoritesService;

  FavoritesViewModel(this._favoritesService) {
    _init();
  }

  final BehaviorSubject<List<ListingModel>> _favoritesSubject = 
      BehaviorSubject<List<ListingModel>>.seeded([]);

  Stream<List<ListingModel>> get favoritesStream => _favoritesSubject.stream;
  List<String> _currentFavoriteIds = [];

  StreamSubscription? _subscription;

  void _init() {
    setLoading(true);
    _subscription = _favoritesService.getFavoriteIdsStream().switchMap((ids) {
      _currentFavoriteIds = ids;
      // Fetch only if we have IDs, otherwise return empty list immediately
      if (ids.isEmpty) return Stream.value(<ListingModel>[]);
      return Stream.fromFuture(_favoritesService.getFavoriteListings(ids));
    }).listen(
      (listings) {
        _favoritesSubject.add(listings);
        setLoading(false);
      },
      onError: (e) {
        setError(e.toString());
        setLoading(false);
      },
    );
  }

  bool isFavorite(String listingId) {
    return _currentFavoriteIds.contains(listingId);
  }

  Future<void> toggleFavorite(String listingId) async {
    await runSafe(() async {
      await _favoritesService.toggleFavorite(listingId);
      // Optimistic update or wait for stream? 
      // Stream is better for single source of truth, but UI might want instant feedback.
      // Since it's a toggle, we can just wait for stream update which should be fast (local database usually).
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _favoritesSubject.close();
    super.dispose();
  }
}
