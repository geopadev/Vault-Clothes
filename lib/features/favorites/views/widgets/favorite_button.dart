import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_clothes/features/favorites/viewmodels/favorites_view_model.dart';

/// A reusable heart-toggle button.
/// Expects a [FavoritesViewModel] to be available via Provider above this widget.
class FavoriteButton extends StatelessWidget {
  final String listingId;
  final Color? color;

  const FavoriteButton({super.key, required this.listingId, this.color});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesViewModel>(
      builder: (context, viewModel, child) {
        final isFav = viewModel.isFavorite(listingId);
        return IconButton(
          icon: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? Colors.red : (color ?? Colors.grey),
          ),
          onPressed: () => viewModel.toggleFavorite(listingId),
        );
      },
    );
  }
}
