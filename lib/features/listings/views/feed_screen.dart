import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vault_clothes/core/services/service_locator.dart';
import 'package:vault_clothes/features/auth/viewmodels/auth_view_model.dart';
import 'package:vault_clothes/features/listings/viewmodels/feed_view_model.dart';
import 'package:vault_clothes/features/listings/views/create_listing_screen.dart';
import 'package:vault_clothes/features/listings/views/listing_detail_screen.dart';
import 'package:vault_clothes/features/favorites/views/favorites_screen.dart';
import 'package:vault_clothes/features/favorites/views/widgets/favorite_button.dart';
import 'package:vault_clothes/features/favorites/viewmodels/favorites_view_model.dart';
import 'package:vault_clothes/features/search/views/search_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FeedViewModel>(
          create: (_) => getIt<FeedViewModel>(),
        ),
        ChangeNotifierProvider<FavoritesViewModel>(
          create: (_) => getIt<FavoritesViewModel>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Vault Clothes'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    getIt<AuthViewModel>().logout();
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateListingScreen()),
                );
              },
              child: const Icon(Icons.add),
            ),
            body: Consumer<FeedViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.listings.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.hasError) {
                  return Center(child: Text('Error: ${viewModel.error}'));
                }

                if (viewModel.listings.isEmpty) {
                  return const Center(
                    child: Text('No items found. Be the first to sell!'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {},
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: viewModel.listings.length,
                    itemBuilder: (context, index) {
                      final item = viewModel.listings[index];
                      final currency = NumberFormat.simpleCurrency();

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ListingDetailScreen(listing: item),
                            ),
                          );
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: item.images.isNotEmpty
                                        ? Image.network(
                                            item.images.first,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder: (_, __, ___) =>
                                                Container(color: Colors.grey[200]),
                                          )
                                        : Container(
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.titleSmall,
                                        ),
                                        Text(
                                          currency.format(item.price),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white70,
                                  ),
                                  child: FavoriteButton(listingId: item.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }
      ),
    );
  }
}
