import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_clothes/core/services/service_locator.dart';
import 'package:vault_clothes/features/favorites/viewmodels/favorites_view_model.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/listings/views/listing_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<FavoritesViewModel>(),
      child: const _FavoritesScreenContent(),
    );
  }
}

class _FavoritesScreenContent extends StatelessWidget {
  const _FavoritesScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FavoritesViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: StreamBuilder<List<ListingModel>>(
        stream: viewModel.favoritesStream,
        builder: (context, snapshot) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text('Error: ${viewModel.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No favorites yet!'));
          }

          final listings = snapshot.data!;
          return ListView.builder(
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final item = listings[index];
              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[300],
                  child: item.images.isNotEmpty
                      ? Image.network(item.images.first, fit: BoxFit.cover)
                      : const Icon(Icons.image),
                ),
                title: Text(item.title),
                subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () => viewModel.toggleFavorite(item.id),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ListingDetailScreen(listing: item),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
