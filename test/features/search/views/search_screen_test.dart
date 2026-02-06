import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vault_clothes/core/services/service_locator.dart';
import 'package:vault_clothes/features/listings/models/filter_options.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/search/viewmodels/search_view_model.dart';
import 'package:vault_clothes/features/search/views/search_screen.dart';

@GenerateNiceMocks([MockSpec<SearchViewModel>()])
import 'search_screen_test.mocks.dart';

void main() {
  late MockSearchViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockSearchViewModel();
    getIt.registerFactory<SearchViewModel>(() => mockViewModel);
    
    // Default stubs
    when(mockViewModel.filterOptions).thenReturn(const FilterOptions());
    when(mockViewModel.results).thenReturn([]);
    when(mockViewModel.isSearching).thenReturn(false);
    when(mockViewModel.isLoading).thenReturn(false);
    when(mockViewModel.hasError).thenReturn(false);
  });

  tearDown(() {
    getIt.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: SearchScreen(),
    );
  }

  group('SearchScreen', () {
    testWidgets('renders search field and filter button', (tester) async {
       await tester.pumpWidget(createWidgetUnderTest());
       
       expect(find.byType(TextField), findsOneWidget);
       expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('entering text calls updateSearchQuery', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      await tester.enterText(find.byType(TextField), 'shoes');
      // Verify updateSearchQuery is called
      verify(mockViewModel.updateSearchQuery('shoes')).called(1);
    });

    testWidgets('shows loading indicator when searching', (tester) async {
      when(mockViewModel.isLoading).thenReturn(true);
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('shows results when list is not empty', (tester) async {
      final tListing = ListingModel(
        id: '1', sellerId: 's', title: 'Cool Shirt', description: 'd', 
        price: 10, images: [], category: ItemCategory.top, 
        condition: ItemCondition.good, size: 'M', createdAt: DateTime.now()
      );
      
      when(mockViewModel.results).thenReturn([tListing]);
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.text('Cool Shirt'), findsOneWidget);
    });
  });
}
