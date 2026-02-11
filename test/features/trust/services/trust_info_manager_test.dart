import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vault_clothes/core/services/database_connector.dart';
import 'package:vault_clothes/features/trust/services/trust_info_manager.dart';
import 'package:vault_clothes/features/trust/models/trust_info_model.dart';

@GenerateNiceMocks([MockSpec<DatabaseConnector>()])
import 'trust_info_manager_test.mocks.dart';

void main() {
  late TrustInfoManager manager;
  late MockDatabaseConnector mockDb;

  setUp(() {
    mockDb = MockDatabaseConnector();
    manager = TrustInfoManager(mockDb);
  });

  group('getTrustInfo', () {
    test('returns default trust info when no data exists', () async {
      when(mockDb.getDocument(any, any)).thenAnswer((_) async => null);

      final result = await manager.getTrustInfo('seller1');

      expect(result.averageRating, 0.0);
      expect(result.verificationLevel, VerificationLevel.unverified);
    });

    test('returns parsed trust info when data exists (String date)', () async {
      final mockData = {
        'sellerId': 'seller1',
        'averageRating': 4.5,
        'totalReviews': 10,
        'totalSales': 5,
        'memberSince': DateTime(2023, 1, 1).toIso8601String(),
        'verificationLevel': 'verified',
      };
      when(mockDb.getDocument('users/seller1/trust', 'info'))
          .thenAnswer((_) async => mockData);

      final result = await manager.getTrustInfo('seller1');

      expect(result.averageRating, 4.5);
      expect(result.verificationLevel, VerificationLevel.verified);
      expect(result.memberSince, DateTime(2023, 1, 1));
    });

    test('handles Timestamp date correctly', () async {
      final date = DateTime(2023, 1, 1);
      final mockData = {
        'sellerId': 'seller1',
        'averageRating': 4.5,
        'totalReviews': 10,
        'totalSales': 5,
        'memberSince': Timestamp.fromDate(date),
        'verificationLevel': 'verified',
      };
      // We must use a mutable map because the manager modifies it
      when(mockDb.getDocument('users/seller1/trust', 'info'))
          .thenAnswer((_) async => Map<String, dynamic>.from(mockData));

      final result = await manager.getTrustInfo('seller1');

      expect(result.memberSince, date);
    });
  });

  group('getReviews', () {
    test('returns parsed reviews from stream', () async {
      final date = DateTime(2023, 1, 1);
      final mockReview = {
        'id': 'r1',
        'reviewerId': 'u1',
        'reviewerName': 'Bob',
        'sellerId': 'seller1',
        'orderId': 'o1',
        'rating': 5,
        'comment': 'Great!',
        'createdAt': Timestamp.fromDate(date),
      };

      when(mockDb.collectionStream(
        'users/seller1/reviews',
        orderBy: anyNamed('orderBy'),
        descending: anyNamed('descending'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) => Stream.value([mockReview]));

      final results = await manager.getReviews('seller1');

      expect(results.length, 1);
      expect(results.first.comment, 'Great!');
      expect(results.first.createdAt, date);
    });
  });
}
