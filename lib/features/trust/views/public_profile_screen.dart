import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vault_clothes/core/services/service_locator.dart';
import 'package:vault_clothes/features/trust/models/trust_info_model.dart';
import 'package:vault_clothes/features/trust/viewmodels/profile_view_model.dart';
import 'package:vault_clothes/features/trust/views/widgets/review_card.dart';
import 'package:vault_clothes/features/listings/views/listing_detail_screen.dart';

class PublicProfileScreen extends StatefulWidget {
  final String sellerId;
  final String? sellerName; // Optional initial name

  const PublicProfileScreen({
    super.key,
    required this.sellerId,
    this.sellerName,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => getIt<ProfileViewModel>()..loadProfile(widget.sellerId),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          // Use viewmodel name if available, else widget param, else 'Loading...'
          final name = viewModel.sellerName.isNotEmpty 
              ? viewModel.sellerName 
              : (widget.sellerName ?? 'Seller Profile');

          return Scaffold(
            appBar: AppBar(
              title: Text(name),
            ),
            body: Builder(
              builder: (context) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.hasError) {
                  return Center(child: Text('Error: ${viewModel.error}'));
                }

                final trust = viewModel.trustInfo;
                if (trust == null) {
                  return const Center(child: Text('Profile not found'));
                }

                return NestedScrollView(
                  headerSliverBuilder: (context, _) {
                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[300],
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(name,
                                      style: Theme.of(context).textTheme.headlineSmall),
                                  if (trust.verificationLevel != VerificationLevel.unverified) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.verified, color: Colors.blue, size: 20),
                                  ]
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${trust.averageRating.toStringAsFixed(1)} (${trust.totalReviews})',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Member since ${DateFormat.y().format(trust.memberSince)}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: _tabController,
                            labelColor: Theme.of(context).primaryColor,
                            unselectedLabelColor: Colors.grey,
                            tabs: const [
                              Tab(text: 'Listings'),
                              Tab(text: 'Reviews'),
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildListingsTab(viewModel),
                      _buildReviewsTab(viewModel),
                    ],
                  ),
                );
              }
            ),
          );
        },
      ),
    );
  }

  Widget _buildListingsTab(ProfileViewModel viewModel) {
    // Show active listings primarily
    final listings = viewModel.activeListings;

    if (listings.isEmpty) {
       // Check if we have sold listings to show? 
       // For now just show active empty state
       if (viewModel.soldListings.isNotEmpty) {
           return Center(
             child: Text('No active listings. ${viewModel.soldListings.length} sold items available in history.'),
           );
       }
       return const Center(child: Text('No active listings'));
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final item = listings[index];
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
             child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Expanded(
                      child: item.images.isNotEmpty
                        ? Image.network(item.images.first, fit: BoxFit.cover, width: double.infinity)
                        : Container(color: Colors.grey[300], child: const Icon(Icons.image)),
                   ),
                   Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                           Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                   )
                ],
             ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(ProfileViewModel viewModel) {
    if (viewModel.reviews.isEmpty) {
      return const Center(child: Text('No reviews yet'));
    }
    return ListView.builder(
      itemCount: viewModel.reviews.length,
      itemBuilder: (context, index) {
        return ReviewCard(review: viewModel.reviews[index]);
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
