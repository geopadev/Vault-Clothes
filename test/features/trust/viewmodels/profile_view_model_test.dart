import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vault_clothes/features/auth/models/user_model.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/listings/services/listing_service.dart';
import 'package:vault_clothes/features/trust/models/review_model.dart';
import 'package:vault_clothes/features/trust/models/trust_info_model.dart';
import 'package:vault_clothes/features/trust/services/trust_info_manager.dart';
import 'package:vault_clothes/features/trust/viewmodels/profile_view_model.dart';

@GenerateNiceMocks([
  MockSpec<TrustInfoManager>(),
  MockSpec<ListingService>(),
])
import 'profile_view_model_test.mocks.dart';

void main() {
  late ProfileViewModel viewModel;
  late MockTrustInfoManager mockTrustManager;
  late MockListingService mockListingService;

  final testTrustInfo = TrustInfoModel(
    sellerId: 's1',
    averageRating: 4.0,
    totalReviews: 10,
    totalSales: 5,
    memberSince: DateTime(2023),
    verificationLevel: VerificationLevel.verified,
  );

  final testReview = ReviewModel(
    id: 'r1',
    reviewerId: 'u1',
    reviewerName: 'Bob',
    sellerId: 's1',
    orderId: 'o1',
    rating: 5,
    comment: 'Good',
    createdAt: DateTime(2023),
  );

  final testListing = ListingModel(
    id: 'l1',
    sellerId: 's1',
    title: 'Item',
    description: 'Desc',
    price: 10,
    category: ItemCategory.top,
    condition: ItemCondition.newWithOptions,
    size: 'M',
    images: [],
    createdAt: DateTime(2023),
  );

  final testUser = UserModel(
    uid: 's1',
    email: 'test@example.com',
    displayName: 'Test Seller',
    createdAt: DateTime(2023),
  );

  setUp(() {
    mockTrustManager = MockTrustInfoManager();
    mockListingService = MockListingService();
    viewModel = ProfileViewModel(mockTrustManager, mockListingService);
  });

  test('loadProfile fetches data in parallel and updates state', () async {
    when(mockTrustManager.getTrustInfo('s1'))
        .thenAnswer((_) async => testTrustInfo);
    when(mockTrustManager.getReviews('s1'))
        .thenAnswer((_) async => [testReview]);
    when(mockListingService.getUserListings('s1'))
        .thenAnswer((_) => Stream.value([testListing]));
    when(mockTrustManager.getSellerProfile('s1'))
        .thenAnswer((_) async => testUser);

    expect(viewModel.isLoading, false);
    
    // Trigger load
    await viewModel.loadProfile('s1');

    expect(viewModel.trustInfo, testTrustInfo);
    expect(viewModel.reviews.length, 1);
    expect(viewModel.reviews.first, testReview);
    expect(viewModel.listings.length, 1);
    expect(viewModel.listings.first, testListing);
    expect(viewModel.sellerName, 'Test Seller');
    expect(viewModel.isLoading, false);
  });

  test('loadProfile handles errors', () async {
    when(mockTrustManager.getTrustInfo(any)).thenThrow(Exception('Error'));
    
    await viewModel.loadProfile('s1');

    expect(viewModel.hasError, true);
    expect(viewModel.error, contains('Error'));
  });
}
