import 'package:get_it/get_it.dart';
import 'package:vault_clothes/core/services/database_connector.dart';
import 'package:vault_clothes/core/services/firestore_database_connector.dart';
import 'package:vault_clothes/features/auth/services/account_authentication.dart';
import 'package:vault_clothes/features/auth/services/user_account_manager.dart';
import 'package:vault_clothes/features/auth/viewmodels/auth_view_model.dart';

final getIt = GetIt.instance;

/// Setup dependency injection for the app.
void setupLocator() {
  // Services
  getIt.registerLazySingleton<DatabaseConnector>(() => FirestoreDatabaseConnector());
  getIt.registerLazySingleton<AccountAuthentication>(() => AccountAuthentication());

  // Managers
  getIt.registerLazySingleton<UserAccountManager>(
    () => UserAccountManager(getIt(), getIt()),
  );

  // ViewModels
  getIt.registerFactory<AuthViewModel>(() => AuthViewModel(getIt()));
}
