import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vault_clothes/core/services/database_connector.dart';
import 'package:vault_clothes/features/auth/services/account_authentication.dart';
import 'package:vault_clothes/features/auth/services/user_account_manager.dart';

@GenerateNiceMocks([
  MockSpec<AccountAuthentication>(),
  MockSpec<DatabaseConnector>(),
  MockSpec<UserCredential>(),
  MockSpec<User>(),
])
import 'user_account_manager_test.mocks.dart';

void main() {
  late UserAccountManager manager;
  late MockAccountAuthentication mockAuth;
  late MockDatabaseConnector mockDb;

  setUp(() {
    mockAuth = MockAccountAuthentication();
    mockDb = MockDatabaseConnector();
    manager = UserAccountManager(mockAuth, mockDb);
  });

  group('UserAccountManager', () {
    test('login calls auth.signIn', () async {
      await manager.login('test@test.com', 'password');
      verify(mockAuth.signIn('test@test.com', 'password')).called(1);
    });

    test('register creates auth user and firestore document', () async {
      final mockCredential = MockUserCredential();
      final mockUser = MockUser();

      when(mockAuth.register(any, any)).thenAnswer((_) async => mockCredential);
      when(mockCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('123');

      await manager.register(
        email: 'test@test.com',
        password: 'password',
        displayName: 'Test User',
      );

      verify(mockAuth.register('test@test.com', 'password')).called(1);
      verify(
        mockDb.saveDocument(
          'users',
          '123',
          argThat(
            predicate<Map<String, dynamic>>(
              (map) =>
                  map['email'] == 'test@test.com' &&
                  map['displayName'] == 'Test User',
            ),
          ),
        ),
      ).called(1);
    });

    test('register throws if user is null', () async {
      final mockCredential = MockUserCredential();
      when(mockAuth.register(any, any)).thenAnswer((_) async => mockCredential);
      when(mockCredential.user).thenReturn(null);

      expect(
        () => manager.register(email: 't', password: 'p'),
        throwsException,
      );
    });
  });
}
