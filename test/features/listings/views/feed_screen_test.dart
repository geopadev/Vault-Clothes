import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vault_clothes/features/auth/viewmodels/auth_view_model.dart';
import 'package:vault_clothes/features/favorites/viewmodels/favorites_view_model.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/listings/viewmodels/feed_view_model.dart';
import 'package:vault_clothes/features/listings/views/feed_screen.dart';

/// Fake FeedViewModel with real ChangeNotifier behavior.
class FakeFeedViewModel extends ChangeNotifier implements FeedViewModel {
  bool _isLoading = false;
  String? _error;
  List<ListingModel> _listings = [];

  @override
  bool get isLoading => _isLoading;
  @override
  String? get error => _error;
  @override
  bool get hasError => _error != null;
  @override
  List<ListingModel> get listings => _listings;

  @override
  void setLoading(bool value) => _isLoading = value;
  @override
  void setError(String? value) => _error = value;
  @override
  Future<void> runSafe(Future<void> Function() action) async {}

  void configure({
    bool loading = false,
    String? error,
    List<ListingModel> listings = const [],
  }) {
    _isLoading = loading;
    _error = error;
    _listings = listings;
    notifyListeners();
  }
}

/// Fake FavoritesViewModel.
class FakeFavoritesViewModel extends ChangeNotifier
    implements FavoritesViewModel {
  @override
  bool get isLoading => false;
  @override
  String? get error => null;
  @override
  bool get hasError => false;
  @override
  Stream<List<ListingModel>> get favoritesStream =>
      BehaviorSubject<List<ListingModel>>.seeded([]).stream;
  @override
  bool isFavorite(String listingId) => false;
  @override
  Future<void> toggleFavorite(String listingId) async {}
  @override
  void setLoading(bool value) {}
  @override
  void setError(String? value) {}
  @override
  Future<void> runSafe(Future<void> Function() action) async {}
}

/// Fake AuthViewModel.
class FakeAuthViewModel extends ChangeNotifier implements AuthViewModel {
  @override
  bool get isLoading => false;
  @override
  String? get error => null;
  @override
  bool get hasError => false;
  @override
  User? get currentUser => null;
  @override
  bool get isAuthenticated => false;
  @override
  Future<void> login(String email, String password) async {}
  @override
  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {}
  @override
  Future<void> logout() async {}
  @override
  void setLoading(bool value) {}
  @override
  void setError(String? value) {}
  @override
  Future<void> runSafe(Future<void> Function() action) async {}
}

void main() {
  late FakeFeedViewModel fakeFeedVM;
  late FakeFavoritesViewModel fakeFavVM;
  late FakeAuthViewModel fakeAuthVM;

  setUp(() async {
    fakeFeedVM = FakeFeedViewModel();
    fakeFavVM = FakeFavoritesViewModel();
    fakeAuthVM = FakeAuthViewModel();

    await GetIt.instance.reset();
    GetIt.instance
        .registerFactory<FeedViewModel>(() => fakeFeedVM);
    GetIt.instance
        .registerFactory<FavoritesViewModel>(() => fakeFavVM);
    GetIt.instance
        .registerFactory<AuthViewModel>(() => fakeAuthVM);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('FeedScreen shows loading indicator', (tester) async {
    fakeFeedVM.configure(loading: true);

    await tester.pumpWidget(const MaterialApp(home: FeedScreen()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('FeedScreen shows error message', (tester) async {
    fakeFeedVM.configure(error: 'Network Error');

    await tester.pumpWidget(const MaterialApp(home: FeedScreen()));
    await tester.pump();

    expect(find.text('Error: Network Error'), findsOneWidget);
  });

  testWidgets('FeedScreen shows empty state', (tester) async {
    fakeFeedVM.configure();

    await tester.pumpWidget(const MaterialApp(home: FeedScreen()));
    await tester.pump();

    expect(
      find.text('No items found. Be the first to sell!'),
      findsOneWidget,
    );
  });
}
