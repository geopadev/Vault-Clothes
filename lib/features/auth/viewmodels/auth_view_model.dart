import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vault_clothes/core/viewmodels/base_view_model.dart';
import 'package:vault_clothes/features/auth/services/user_account_manager.dart';

class AuthViewModel extends BaseViewModel {
  final UserAccountManager _userAccountManager;
  StreamSubscription<User?>? _authSubscription;
  User? _currentUser;

  AuthViewModel(this._userAccountManager) {
    _authSubscription = _userAccountManager.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> login(String email, String password) async {
    await runSafe(() async {
      await _userAccountManager.login(email, password);
    });
  }

  Future<void> register(String email, String password, String displayName) async {
    await runSafe(() async {
      await _userAccountManager.register(
        email: email,
        password: password,
        displayName: displayName,
      );
    });
  }

  Future<void> logout() async {
    await runSafe(() async {
      await _userAccountManager.logout();
    });
  }
}
