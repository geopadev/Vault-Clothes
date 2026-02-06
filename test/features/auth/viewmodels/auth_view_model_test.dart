import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vault_clothes/features/auth/services/user_account_manager.dart';
import 'package:vault_clothes/features/auth/viewmodels/auth_view_model.dart';

@GenerateNiceMocks([
  MockSpec<UserAccountManager>(),
  MockSpec<User>(),
])
import 'auth_view_model_test.mocks.dart';

void main() {
  late AuthViewModel viewModel;
  late MockUserAccountManager mockManager;
  late StreamController<User?> authStateController;

  setUp(() {
    mockManager = MockUserAccountManager();
    authStateController = StreamController<User?>();
    when(mockManager.authStateChanges).thenAnswer((_) => authStateController.stream);
    
    viewModel = AuthViewModel(mockManager);
  });

  tearDown(() {
    authStateController.close();
  });

  group('AuthViewModel', () {
    test('initial state listens to auth changes', () async {
      final mockUser = MockUser();
      authStateController.add(mockUser);
      
      // Wait for stream to emit
      await Future.delayed(Duration.zero);
      
      expect(viewModel.currentUser, mockUser);
      expect(viewModel.isAuthenticated, true);
    });

    test('login calls manager.login', () async {
      await viewModel.login('t@t.com', 'pass');
      verify(mockManager.login('t@t.com', 'pass')).called(1);
      expect(viewModel.hasError, false);
    });

    test('login sets error on failure', () async {
      when(mockManager.login(any, any)).thenThrow(Exception('Auth Failed'));
      
      await viewModel.login('t@t.com', 'pass');
      
      expect(viewModel.hasError, true);
      expect(viewModel.error, contains('Auth Failed'));
    });

    test('register calls manager.register', () async {
      await viewModel.register('t@t.com', 'pass', 'Name');
      verify(mockManager.register(
        email: 't@t.com',
        password: 'pass',
        displayName: 'Name',
      )).called(1);
    });
  });
}
