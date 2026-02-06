import 'package:firebase_auth/firebase_auth.dart';
import 'package:vault_clothes/core/services/database_connector.dart';
import 'package:vault_clothes/features/auth/models/user_model.dart';
import 'package:vault_clothes/features/auth/services/account_authentication.dart';

class UserAccountManager {
  final AccountAuthentication _auth;
  final DatabaseConnector _db;

  UserAccountManager(this._auth, this._db);

  Stream<User?> get authStateChanges => _auth.authStateChanges;

  Future<void> login(String email, String password) async {
    await _auth.signIn(email, password);
  }

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // 1. Create Auth User
    final credential = await _auth.register(email, password);
    final user = credential.user;

    if (user == null) {
      throw Exception('Registration failed: User is null');
    }

    // 2. Create Firestore User Profile
    final newUser = UserModel(
      uid: user.uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );

    // Using "users" collection as per plan
    await _db.saveDocument('users', user.uid, newUser.toJson());
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
