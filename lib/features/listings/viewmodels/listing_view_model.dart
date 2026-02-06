import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:vault_clothes/core/services/service_locator.dart';
import 'package:vault_clothes/core/services/storage_service.dart';
import 'package:vault_clothes/core/viewmodels/base_view_model.dart';
import 'package:vault_clothes/features/auth/services/user_account_manager.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/listings/services/listing_service.dart';

class ListingViewModel extends BaseViewModel {
  final ListingService _listingService;
  final StorageService _storageService;
  final UserAccountManager _userManager;

  ListingViewModel(
    this._listingService,
    this._storageService,
    this._userManager,
  );

  Future<void> createListing({
    required String title,
    required String description,
    required double price,
    required ItemCategory category,
    required ItemCondition condition,
    required String size,
    File? imageFile,
  }) async {
    await runSafe(() async {
      final user = await _userManager.authStateChanges.first;
      if (user == null) throw Exception('Must be logged in to create listing');

      final List<String> imageUrls = [];
      final String listingId = const Uuid().v4();

      if (imageFile != null) {
        final String path = 'listings/$listingId/main.jpg';
        final String url = await _storageService.uploadImage(imageFile, path);
        imageUrls.add(url);
      }

      final listing = ListingModel(
        id: listingId,
        sellerId: user.uid,
        title: title,
        description: description,
        price: price,
        images: imageUrls,
        category: category,
        condition: condition,
        size: size,
        createdAt: DateTime.now(),
      );

      await _listingService.createListing(listing);
    });
  }
}
