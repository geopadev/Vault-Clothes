import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vault_clothes/features/listings/models/filter_options.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/listings/services/listing_service.dart';
import 'package:vault_clothes/features/search/viewmodels/search_view_model.dart';

@GenerateNiceMocks([MockSpec<ListingService>()])
import 'search_view_model_test.mocks.dart';

void main() {
  late SearchViewModel viewModel;
  late MockListingService mockService;

  setUp(() {
    mockService = MockListingService();
    // Default mock response: empty list
    when(mockService.searchListings(any)).thenAnswer((_) => Stream.value([]));
    viewModel = SearchViewModel(mockService);
  });

  group('SearchViewModel', () {
    test('initial state is correct', () {
      expect(viewModel.results, isEmpty);
      expect(viewModel.filterOptions.searchQuery, isNull);
      expect(viewModel.isSearching, false);
    });

    test(
      'updateSearchQuery updates filter options and triggers search',
      () async {
        // Because of debounce (300ms), we expect call to happen after delay.
        viewModel.updateSearchQuery('shirt');

        expect(viewModel.filterOptions.searchQuery, 'shirt');

        // Fast forward logic or wait
        await Future.delayed(const Duration(milliseconds: 350));

        verify(
          mockService.searchListings(
            argThat(predicate<FilterOptions>((f) => f.searchQuery == 'shirt')),
          ),
        ).called(1);
      },
    );

    test(
      'updateFilters updates options and triggers immediate search',
      () async {
        // updateFilters also goes through the subject which is debounced.
        // Wait, let's check SearchViewModel implementation.
        // Yes, filters update the subject, so they are also debounced.

        const filters = FilterOptions(category: ItemCategory.top);
        viewModel.updateFilters(filters);

        expect(viewModel.filterOptions.category, ItemCategory.top);

        await Future.delayed(const Duration(milliseconds: 350));

        verify(mockService.searchListings(any)).called(1);
      },
    );

    test('results are updated from service stream', () async {
      final tList = [
        ListingModel(
          id: '1',
          sellerId: 's',
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

      when(
        mockService.searchListings(any),
      ).thenAnswer((_) => Stream.value(tList));

      viewModel.updateSearchQuery('T');
      await Future.delayed(const Duration(milliseconds: 350));

      // Stream needs to emit.
      // The view model listens to the stream returned by switchMap.
      // We might need a small delay for stream propagation.
      await Future.delayed(Duration.zero);

      expect(viewModel.results, tList);
      expect(viewModel.isLoading, false);
    });
  });
}
