import 'package:vault_clothes/core/viewmodels/base_view_model.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/listings/services/listing_service.dart';
import 'package:vault_clothes/features/trust/models/review_model.dart';
import 'package:vault_clothes/features/trust/models/trust_info_model.dart';
import 'package:vault_clothes/features/trust/services/trust_info_manager.dart';

class ProfileViewModel extends BaseViewModel {
  final TrustInfoManager _trustManager;
  final ListingService _listingService;

  TrustInfoModel? _trustInfo;
  List<ReviewModel> _reviews = [];
  List<ListingModel> _listings = [];

  ProfileViewModel(this._trustManager, this._listingService);

  TrustInfoModel? get trustInfo => _trustInfo;
  List<ReviewModel> get reviews => _reviews;
  List<ListingModel> get listings => _listings;

  List<ListingModel> get activeListings =>
      _listings.where((l) => !l.isSold).toList();
      
  List<ListingModel> get soldListings =>
      _listings.where((l) => l.isSold).toList();

  Future<void> loadProfile(String sellerId) async {
    await runSafe(() async {
      // Parallel execution for better performance
      final results = await Future.wait([
        _trustManager.getTrustInfo(sellerId),
        _trustManager.getReviews(sellerId),
        _listingService.getUserListings(sellerId).first,
      ]);

      _trustInfo = results[0] as TrustInfoModel;
      _reviews = results[1] as List<ReviewModel>;
      _listings = results[2] as List<ListingModel>;
    });
  }
}
