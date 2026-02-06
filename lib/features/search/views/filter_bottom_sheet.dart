import 'package:flutter/material.dart';
import 'package:vault_clothes/features/listings/models/filter_options.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/search/viewmodels/search_view_model.dart';
import 'package:provider/provider.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterOptions initialFilters;

  const FilterBottomSheet({super.key, required this.initialFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterOptions _currentFilters;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: Theme.of(context).textTheme.headlineSmall),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentFilters = const FilterOptions();
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const Divider(),

          // Category
          DropdownButtonFormField<ItemCategory>(
            value: _currentFilters.category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: ItemCategory.values.map((c) {
              return DropdownMenuItem(value: c, child: Text(c.name));
            }).toList(),
            onChanged: (v) => setState(() {
              _currentFilters = _currentFilters.copyWith(category: v);
            }),
          ),

          const SizedBox(height: 16),

          // Condition
          DropdownButtonFormField<ItemCondition>(
            value: _currentFilters.condition,
            decoration: const InputDecoration(labelText: 'Condition'),
            items: ItemCondition.values.map((c) {
              return DropdownMenuItem(value: c, child: Text(c.name));
            }).toList(),
            onChanged: (v) => setState(() {
              _currentFilters = _currentFilters.copyWith(condition: v);
            }),
          ),

          const SizedBox(height: 16),

          // Size
          TextFormField(
            initialValue: _currentFilters.size,
            decoration: const InputDecoration(labelText: 'Size (Exact Match)'),
            onChanged: (v) => setState(() {
              _currentFilters = _currentFilters.copyWith(
                size: v.isEmpty ? null : v,
              );
            }),
          ),

          const SizedBox(height: 16),

          // Price Range (Simplified)
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _currentFilters.minPrice?.toString(),
                  decoration: const InputDecoration(labelText: 'Min Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() {
                    _currentFilters = _currentFilters.copyWith(
                      minPrice: double.tryParse(v),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: _currentFilters.maxPrice?.toString(),
                  decoration: const InputDecoration(labelText: 'Max Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() {
                    _currentFilters = _currentFilters.copyWith(
                      maxPrice: double.tryParse(v),
                    );
                  }),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _currentFilters);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
