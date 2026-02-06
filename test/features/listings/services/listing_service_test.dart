import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vault_clothes/core/services/database_connector.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/listings/services/listing_service.dart';

@GenerateNiceMocks([MockSpec<DatabaseConnector>()])
import 'listing_service_test.mocks.dart';

void main() {
  late ListingService service;
  late MockDatabaseConnector mockDb;

  setUp(() {
    mockDb = MockDatabaseConnector();
    service = ListingService(mockDb);
  });

  group('ListingService', () {
    final tListing = ListingModel(
      id: '1',
      sellerId: 'user1',
      title: 'Shirt',
      description: 'Nice shirt',
      price: 10.0,
      images: [],
      category: ItemCategory.top,
      condition: ItemCondition.newWithOptions,
      size: 'M',
      createdAt: DateTime.now(),
    );

    test('createListing calls saveDocument', () async {
      await service.createListing(tListing);
      verify(mockDb.saveDocument('listings', '1', any)).called(1);
    });

    test('getListing returns ListingModel on success', () async {
      when(
        mockDb.getDocument('listings', '1'),
      ).thenAnswer((_) async => tListing.toJson());

      final result = await service.getListing('1');

      expect(result, isNotNull);
      expect(result!.title, 'Shirt');
    });

    test('getFeed returns list of models', () async {
      when(
        mockDb.collectionStream(
          'listings',
          orderBy: 'createdAt',
          descending: true,
        ),
      ).thenAnswer((_) => Stream.value([tListing.toJson()]));

      final stream = service.getFeed();
      final list = await stream.first;

      expect(list, isA<List<ListingModel>>());
      expect(list.first.title, 'Shirt');
    });
  });
}
