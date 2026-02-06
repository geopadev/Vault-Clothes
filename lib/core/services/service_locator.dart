import 'package:get_it/get_it.dart';
import 'package:vault_clothes/core/services/database_connector.dart';
import 'package:vault_clothes/core/services/firestore_database_connector.dart';

final getIt = GetIt.instance;

/// Setup dependency injection for the app.
void setupLocator() {
  // Services
  getIt.registerLazySingleton<DatabaseConnector>(() => FirestoreDatabaseConnector());

  // Managers
  // getIt.registerLazySingleton<UserAccountManager>(() => UserAccountManager(getIt()));
  // ...
}
