import 'dart:async';
import 'package:vault_clothes/core/viewmodels/base_view_model.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/listings/services/listing_service.dart';

class FeedViewModel extends BaseViewModel {
  final ListingService _listingService;
  StreamSubscription? _subscription;
  List<ListingModel> _listings = [];

  List<ListingModel> get listings => _listings;

  FeedViewModel(this._listingService) {
    _startListening();
  }

  void _startListening() {
    setLoading(true);
    _subscription = _listingService.getFeed().listen(
      (data) {
        _listings = data;
        setLoading(false);
      },
      onError: (e) {
        setError(e.toString());
        setLoading(false);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
