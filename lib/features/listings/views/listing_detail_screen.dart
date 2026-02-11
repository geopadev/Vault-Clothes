import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vault_clothes/core/services/service_locator.dart';
import 'package:vault_clothes/features/favorites/viewmodels/favorites_view_model.dart';
import 'package:vault_clothes/features/favorites/views/widgets/favorite_button.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/trust/views/public_profile_screen.dart';

class ListingDetailScreen extends StatelessWidget {
  final ListingModel listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency();

    return ChangeNotifierProvider<FavoritesViewModel>(
      create: (_) => getIt<FavoritesViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Details'),
          actions: [
            FavoriteButton(listingId: listing.id),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (listing.images.isNotEmpty)
                Image.network(
                  listing.images.first,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                )
              else
                Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Text(
                          currencyFormat.format(listing.price),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text(listing.size)),
                        Chip(label: Text(listing.condition.name)),
                        Chip(label: Text(listing.category.name)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(listing.description),

                    const SizedBox(height: 32),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PublicProfileScreen(
                                sellerId: listing.sellerId,
                                sellerName: 'Loading...', // Name will load in screen
                              ),
                            ),
                          );
                        },
                        child: const Text('View Seller Profile'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement Buy/Chat
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment/Chat not implemented yet'),
                            ),
                          );
                        },
                        child: const Text('Contact Seller'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
