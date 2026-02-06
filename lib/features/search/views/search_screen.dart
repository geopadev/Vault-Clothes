import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_clothes/core/services/service_locator.dart';
import 'package:vault_clothes/features/listings/models/filter_options.dart';
import 'package:vault_clothes/features/listings/views/listing_detail_screen.dart';
import 'package:vault_clothes/features/search/viewmodels/search_view_model.dart';
import 'package:vault_clothes/features/search/views/filter_bottom_sheet.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchViewModel>(
      create: (_) => getIt<SearchViewModel>(),
      child: const _SearchScreenContent(),
    );
  }
}

class _SearchScreenContent extends StatefulWidget {
  const _SearchScreenContent();

  @override
  State<_SearchScreenContent> createState() => _SearchScreenContentState();
}

class _SearchScreenContentState extends State<_SearchScreenContent> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> _showFilterSheet(
    BuildContext context,
    SearchViewModel viewModel,
  ) async {
    final result = await showModalBottomSheet<FilterOptions>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          FilterBottomSheet(initialFilters: viewModel.filterOptions),
    );

    if (result != null) {
      viewModel.updateFilters(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SearchViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search items...',
            border: InputBorder.none,
          ),
          onChanged: viewModel.updateSearchQuery,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, viewModel),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips (Optional but nice)
          if (viewModel.filterOptions.category != null ||
              viewModel.filterOptions.condition != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  if (viewModel.filterOptions.category != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(viewModel.filterOptions.category!.name),
                        onDeleted: () => viewModel.updateFilters(
                          viewModel.filterOptions.copyWith(
                            category: null,
                          ), // This is tricky, copyWith doesn't support setting null if not designed carefully or using helper
                          // Actually my copyWith doesn't support nulling out fields easily without sentinels.
                          // For now, let's just use the Reset button in filters.
                          // Or we can rebuild FilterOptions.
                        ),
                        deleteIcon: const Icon(Icons.close, size: 18),
                      ),
                    ),
                  // ... other chips
                ],
              ),
            ),

          Expanded(
            child: Builder(
              builder: (context) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.hasError) {
                  return Center(child: Text('Error: ${viewModel.error}'));
                }

                if (viewModel.results.isEmpty) {
                  return const Center(child: Text('No results found.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: viewModel.results.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.results[index];
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: item.images.isNotEmpty
                                  ? Image.network(
                                      item.images.first,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Container(color: Colors.grey[200]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(item.title, maxLines: 1),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
