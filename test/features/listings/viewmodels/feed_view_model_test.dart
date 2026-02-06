import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/listings/services/listing_service.dart';
import 'package:vault_clothes/features/listings/viewmodels/feed_view_model.dart';

@GenerateNiceMocks([MockSpec<ListingService>()])
import 'feed_view_model_test.mocks.dart';

void main() {
  late FeedViewModel viewModel;
  late MockListingService mockService;

  setUp(() {
    mockService = MockListingService();
    // Default stub
    when(mockService.getFeed()).thenAnswer((_) => const Stream.empty());
  });

  group('FeedViewModel', () {
    test('initializes with loading', () {
      viewModel = FeedViewModel(mockService);
      expect(viewModel.isLoading, true);
    });

    test('updates listings from stream', () async {
      final tListings = [
        ListingModel(
          id: '1',
          sellerId: 'u1',
          title: 'T',
          description: 'D',
          price: 1,
          images: [],
          category: ItemCategory.top,
          condition: ItemCondition.good,
          size: 'M',
          createdAt: DateTime.now(),
        ),
      ];

      when(mockService.getFeed()).thenAnswer((_) => Stream.value(tListings));

      viewModel = FeedViewModel(mockService);

      await Future.delayed(Duration.zero); // Wait for stream

      expect(viewModel.listings, tListings);
      expect(viewModel.isLoading, false);
    });
  });
}
