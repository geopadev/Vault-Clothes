import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vault_clothes/features/favorites/viewmodels/favorites_view_model.dart';
import 'package:vault_clothes/features/favorites/views/favorites_screen.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';

/// A fake ViewModel that extends the real type for proper ChangeNotifier behavior.
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

  void emitLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void emitFavorites(List<ListingModel> items, List<String> ids) {
    _isLoading = false;
    _favoriteIds = ids;
    _subject.add(items);
    notifyListeners();
  }

  void emitEmpty() {
    _isLoading = false;
    _favoriteIds = [];
    _subject.add([]);
    notifyListeners();
  }
}

void main() {
  late FakeFavoritesViewModel fakeVM;

  final testListing = ListingModel(
    id: '1',
    sellerId: 'user1',
    title: 'Test Favorite Item',
    description: 'Desc',
    price: 100.0,
    category: ItemCategory.shoes,
    condition: ItemCondition.excellent,
    size: 'M',
    images: [],
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() async {
    fakeVM = FakeFavoritesViewModel();
    await GetIt.instance.reset();
    GetIt.instance
        .registerFactory<FavoritesViewModel>(() => fakeVM);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('shows loading indicator', (tester) async {
    fakeVM.emitLoading();

    await tester.pumpWidget(const MaterialApp(home: FavoritesScreen()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows empty message when no favorites', (tester) async {
    fakeVM.emitEmpty();

    await tester.pumpWidget(const MaterialApp(home: FavoritesScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No favorites yet!'), findsOneWidget);
  });

  testWidgets('shows favorite item', (tester) async {
    fakeVM.emitFavorites([testListing], ['1']);

    await tester.pumpWidget(const MaterialApp(home: FavoritesScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Test Favorite Item'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('tap heart calls toggleFavorite', (tester) async {
    fakeVM.emitFavorites([testListing], ['1']);

    await tester.pumpWidget(const MaterialApp(home: FavoritesScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pump();

    expect(fakeVM.toggleFavoriteCalled, true);
    expect(fakeVM.lastToggledId, '1');
  });
}
