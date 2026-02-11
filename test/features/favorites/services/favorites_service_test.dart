import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vault_clothes/core/services/database_connector.dart';
import 'package:vault_clothes/features/auth/services/account_authentication.dart';
import 'package:vault_clothes/features/favorites/services/favorites_service.dart';
import 'package:vault_clothes/features/listings/services/listing_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

@GenerateNiceMocks([
  MockSpec<DatabaseConnector>(),
  MockSpec<AccountAuthentication>(),
  MockSpec<ListingService>(),
  MockSpec<User>(),
])
import 'favorites_service_test.mocks.dart';

void main() {
  late FavoritesService service;
  late MockDatabaseConnector mockDb;
  late MockAccountAuthentication mockAuth;
  late MockListingService mockListingService;
  late MockUser mockUser;

  setUp(() {
    mockDb = MockDatabaseConnector();
    mockAuth = MockAccountAuthentication();
    mockListingService = MockListingService();
    mockUser = MockUser();

    service = FavoritesService(mockDb, mockAuth, mockListingService);
  });

  group('FavoritesService', () {
    test('toggleFavorite throws if not logged in', () async {
      when(mockAuth.currentUser).thenReturn(null);
      expect(() => service.toggleFavorite('123'), throwsException);
    });

    test('toggleFavorite saves document when not already favorited', () async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('uid');
      when(mockDb.getDocument(any, '123')).thenAnswer((_) async => null);
      when(mockDb.saveDocument(any, any, any)).thenAnswer((_) async {});

      await service.toggleFavorite('123');

      verify(mockDb.saveDocument('users/uid/favorites', '123', any)).called(1);
    });

    test('toggleFavorite deletes document when already favorited', () async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('uid');
      when(mockDb.getDocument(any, '123'))
          .thenAnswer((_) async => {'id': '123'});
      when(mockDb.deleteDocument(any, any)).thenAnswer((_) async {});

      await service.toggleFavorite('123');

      verify(mockDb.deleteDocument('users/uid/favorites', '123')).called(1);
    });

    test('getFavoriteIdsStream returns stream of listing IDs', () {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('uid');

      final mockData = [
        {'listingId': '1', 'createdAt': '2023-01-01T00:00:00.000'},
        {'listingId': '2', 'createdAt': '2023-01-02T00:00:00.000'},
      ];

      when(mockDb.collectionStream(
        any,
        orderBy: anyNamed('orderBy'),
        descending: anyNamed('descending'),
      )).thenAnswer((_) => Stream.value(mockData));

      expect(service.getFavoriteIdsStream(), emits(['1', '2']));
    });

    test('getFavoriteIdsStream returns empty when not logged in', () {
      when(mockAuth.currentUser).thenReturn(null);
      expect(service.getFavoriteIdsStream(), emits([]));
    });
  });
}
