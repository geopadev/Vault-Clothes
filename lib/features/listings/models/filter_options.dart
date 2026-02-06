import 'package:vault_clothes/features/listings/models/listing_model.dart';

class FilterOptions {
  final String? searchQuery;
  final ItemCategory? category;
  final ItemCondition? condition;
  final double? minPrice;
  final double? maxPrice;
  final String? size;

  const FilterOptions({
    this.searchQuery,
    this.category,
    this.condition,
    this.minPrice,
    this.maxPrice,
    this.size,
  });

  FilterOptions copyWith({
    String? searchQuery,
    ItemCategory? category,
    ItemCondition? condition,
    double? minPrice,
    double? maxPrice,
    String? size,
  }) {
    return FilterOptions(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      size: size ?? this.size,
    );
  }
}
