import 'package:vault_clothes/core/viewmodels/base_view_model.dart';
import 'package:vault_clothes/features/auth/services/user_account_manager.dart';
import 'package:vault_clothes/features/chat/services/chat_service.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';

class ListingDetailViewModel extends BaseViewModel {
  final ChatService _chatService;
  final UserAccountManager _userAccountManager;

  ListingDetailViewModel(this._chatService, this._userAccountManager);

  Future<String?> startChatForListing(ListingModel listing) async {
    final currentUser = _userAccountManager.currentUser;
    if (currentUser == null) return null; // Must be logged in

    if (currentUser.uid == listing.sellerId) {
      // Cannot chat with self
      return null;
    }

    String? chatId;
    await runSafe(() async {
      chatId = await _chatService.startChat(
        buyerId: currentUser.uid,
        sellerId: listing.sellerId,
        listingId: listing.id,
        listingTitle: listing.title,
        listingImage: listing.images.isNotEmpty ? listing.images.first : '',
      );
    });
    
    return chatId;
  }
}
