import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/trust/models/review_model.dart';
import 'package:vault_clothes/features/trust/models/trust_info_model.dart';
import 'package:vault_clothes/features/trust/viewmodels/profile_view_model.dart';
import 'package:vault_clothes/features/trust/views/public_profile_screen.dart';

// Since we can't easily generate mocks for ViewModel (it extends ChangeNotifier),
// we create a Fake like in other tests.
class FakeProfileViewModel extends ChangeNotifier implements ProfileViewModel {
  @override
  bool isLoading = false;
  
  @override
  bool hasError = false;
  
  @override
  String? error;

  @override
  TrustInfoModel? trustInfo;

  @override
  List<ReviewModel> reviews = [];

  @override
  List<ListingModel> listings = [];
  
  @override
  String sellerName = 'Test Seller';

  @override
  List<ListingModel> get activeListings => listings.where((l) => !l.isSold).toList();
  
  @override
  List<ListingModel> get soldListings => listings.where((l) => l.isSold).toList();

  @override
  Future<void> loadProfile(String sellerId) async {
    // No-op for fake
  }
  
  @override
  void setBusy(bool value) {
    isLoading = value;
    notifyListeners();
  }

  @override
  void setError(dynamic error) {
    hasError = true;
    this.error = error.toString();
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeProfileViewModel fakeViewModel;

  setUp(() async {
    await GetIt.instance.reset();
    fakeViewModel = FakeProfileViewModel();
    GetIt.instance.registerFactory<ProfileViewModel>(() => fakeViewModel);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  final testTrustInfo = TrustInfoModel(
    sellerId: 's1',
    averageRating: 4.5,
    totalReviews: 10,
    totalSales: 5,
    memberSince: DateTime(2023),
    verificationLevel: VerificationLevel.verified,
  );

  testWidgets('PublicProfileScreen shows loading indicator', (tester) async {
    fakeViewModel.isLoading = true;
    
    await tester.pumpWidget(const MaterialApp(
      home: PublicProfileScreen(sellerId: 's1', sellerName: 'Seller'),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('PublicProfileScreen shows trust info and name', (tester) async {
    fakeViewModel.trustInfo = testTrustInfo;
    fakeViewModel.sellerName = 'Super Seller';
    
    await tester.pumpWidget(const MaterialApp(
      home: PublicProfileScreen(sellerId: 's1', sellerName: 'Seller'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Super Seller'), findsWidgets); // Appbar and body
    expect(find.text('4.5 (10)'), findsOneWidget);
    expect(find.byIcon(Icons.verified), findsOneWidget);
  });

  testWidgets('PublicProfileScreen shows tabs', (tester) async {
    fakeViewModel.trustInfo = testTrustInfo;
    
    await tester.pumpWidget(const MaterialApp(
      home: PublicProfileScreen(sellerId: 's1', sellerName: 'Seller'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Listings'), findsOneWidget);
    expect(find.text('Reviews'), findsOneWidget);
  });
}
