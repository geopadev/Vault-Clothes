import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vault_clothes/features/favorites/services/favorites_service.dart';
import 'package:vault_clothes/features/favorites/viewmodels/favorites_view_model.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';

@GenerateNiceMocks([MockSpec<FavoritesService>()])
import 'favorites_view_model_test.mocks.dart';

void main() {
  late FavoritesViewModel viewModel;
  late MockFavoritesService mockService;

  final testListing = ListingModel(
    id: '1',
    sellerId: 'user1',
    title: 'Test Item',
    description: 'Desc',
    price: 10.0,
    category: ItemCategory.top,
    condition: ItemCondition.good,
    size: 'M',
    images: [],
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockService = MockFavoritesService();
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('initial state loads favorites from stream', () async {
    when(mockService.getFavoriteIdsStream())
        .thenAnswer((_) => Stream.value(['1']));
    when(mockService.getFavoriteListings(['1']))
        .thenAnswer((_) async => [testListing]);

    viewModel = FavoritesViewModel(mockService);

    expect(viewModel.isLoading, true);

    // Allow stream to process
    await Future.delayed(const Duration(milliseconds: 50));

    expect(viewModel.isLoading, false);
    expect(viewModel.isFavorite('1'), true);
    expect(viewModel.isFavorite('999'), false);
  });

  test('toggleFavorite delegates to service', () async {
    when(mockService.getFavoriteIdsStream())
        .thenAnswer((_) => Stream.value([]));
    when(mockService.toggleFavorite(any)).thenAnswer((_) async {});

    viewModel = FavoritesViewModel(mockService);
    await Future.delayed(const Duration(milliseconds: 50));

    await viewModel.toggleFavorite('1');

    verify(mockService.toggleFavorite('1')).called(1);
  });

  test('empty favorites stream produces empty list', () async {
    when(mockService.getFavoriteIdsStream())
        .thenAnswer((_) => Stream.value([]));

    viewModel = FavoritesViewModel(mockService);
    await Future.delayed(const Duration(milliseconds: 50));

    expect(viewModel.isLoading, false);
    expect(viewModel.isFavorite('1'), false);
  });
}
