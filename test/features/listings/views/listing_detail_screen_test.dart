import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vault_clothes/features/favorites/viewmodels/favorites_view_model.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/listings/views/listing_detail_screen.dart';

/// A fake ViewModel with proper ChangeNotifier behavior.
class FakeFavoritesViewModel extends ChangeNotifier
    implements FavoritesViewModel {
  bool _isLoading = false;
  String? _error;
  List<String> _favoriteIds = [];
  final BehaviorSubject<List<ListingModel>> _subject =
      BehaviorSubject<List<ListingModel>>.seeded([]);

  @override
  bool get isLoading => _isLoading;
  @override
  String? get error => _error;
  @override
  bool get hasError => _error != null;
  @override
  Stream<List<ListingModel>> get favoritesStream => _subject.stream;
  @override
  bool isFavorite(String listingId) => _favoriteIds.contains(listingId);

  bool toggleFavoriteCalled = false;
  String? lastToggledId;

  @override
  Future<void> toggleFavorite(String listingId) async {
    toggleFavoriteCalled = true;
    lastToggledId = listingId;
  }

  @override
  void setLoading(bool value) => _isLoading = value;
  @override
  void setError(String? value) => _error = value;
  @override
  Future<void> runSafe(Future<void> Function() action) async {}

  void configure({bool loading = false, List<String> ids = const []}) {
    _isLoading = loading;
    _favoriteIds = ids;
    notifyListeners();
  }
}

void main() {
  late FakeFavoritesViewModel fakeVM;

  final testListing = ListingModel(
    id: '1',
    sellerId: 'user1',
    title: 'Detail Test Item',
    description: 'Detailed Description',
    price: 99.99,
    category: ItemCategory.top,
    condition: ItemCondition.newWithOptions,
    size: 'L',
    images: [],
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() async {
    fakeVM = FakeFavoritesViewModel();
    fakeVM.configure(loading: false, ids: []);
    await GetIt.instance.reset();
    GetIt.instance
        .registerFactory<FavoritesViewModel>(() => fakeVM);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('shows item details and favorite button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ListingDetailScreen(listing: testListing)),
    );
    await tester.pump();

    expect(find.text('Detail Test Item'), findsOneWidget);
    expect(find.text('Detailed Description'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('tapping favorite button calls toggleFavorite', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ListingDetailScreen(listing: testListing)),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();

    expect(fakeVM.toggleFavoriteCalled, true);
    expect(fakeVM.lastToggledId, '1');
  });
}
