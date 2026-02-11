import 'package:get_it/get_it.dart';
import 'package:vault_clothes/core/services/database_connector.dart';
import 'package:vault_clothes/core/services/firestore_database_connector.dart';
import 'package:vault_clothes/features/auth/services/account_authentication.dart';
import 'package:vault_clothes/features/auth/services/user_account_manager.dart';
import 'package:vault_clothes/features/auth/viewmodels/auth_view_model.dart';
import 'package:vault_clothes/core/services/storage_service.dart';
import 'package:vault_clothes/features/favorites/services/favorites_service.dart';
import 'package:vault_clothes/features/favorites/viewmodels/favorites_view_model.dart';
import 'package:vault_clothes/features/listings/services/listing_service.dart';
import 'package:vault_clothes/features/listings/viewmodels/feed_view_model.dart';
import 'package:vault_clothes/features/listings/viewmodels/listing_view_model.dart';
import 'package:vault_clothes/features/search/viewmodels/search_view_model.dart';

final getIt = GetIt.instance;

/// Setup dependency injection for the app.
void setupLocator() {
  // Services
  getIt.registerLazySingleton<DatabaseConnector>(
    () => FirestoreDatabaseConnector(),
  );
  getIt.registerLazySingleton<AccountAuthentication>(
    () => AccountAuthentication(),
  );
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  getIt.registerLazySingleton<ListingService>(() => ListingService(getIt()));
  getIt.registerLazySingleton<FavoritesService>(
    () => FavoritesService(
      getIt<DatabaseConnector>(),
      getIt<AccountAuthentication>(),
      getIt<ListingService>(),
    ),
  );

  // Managers
  getIt.registerLazySingleton<UserAccountManager>(
    () => UserAccountManager(getIt(), getIt()),
  );

  // ViewModels
  getIt.registerFactory<AuthViewModel>(() => AuthViewModel(getIt()));
  getIt.registerFactory<ListingViewModel>(
    () => ListingViewModel(getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<FeedViewModel>(() => FeedViewModel(getIt()));
  getIt.registerFactory<SearchViewModel>(() => SearchViewModel(getIt()));
  getIt.registerFactory<FavoritesViewModel>(() => FavoritesViewModel(getIt()));
}
