import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:vault_clothes/core/viewmodels/base_view_model.dart';
import 'package:vault_clothes/features/listings/models/filter_options.dart';
import 'package:vault_clothes/features/listings/models/listing_model.dart';
import 'package:vault_clothes/features/listings/services/listing_service.dart';

class SearchViewModel extends BaseViewModel {
  final ListingService _listingService;

  // State
  FilterOptions _filterOptions = const FilterOptions();
  List<ListingModel> _results = [];
  bool _isSearching = false;

  // Subjects
  final _searchSubject = BehaviorSubject<FilterOptions>();
  StreamSubscription? _subscription;

  // Getters
  List<ListingModel> get results => _results;
  FilterOptions get filterOptions => _filterOptions;
  bool get isSearching => _isSearching;

  SearchViewModel(this._listingService) {
    _initSearchListener();
  }

  void _initSearchListener() {
    // Debounce search inputs to avoid spamming (even if client-side, good practice for future API)
    _subscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap((options) {
          _isSearching = true;
          notifyListeners();
          return _listingService.searchListings(options);
        })
        .listen(
          (listings) {
            _results = listings;
            _isSearching = false;
            setLoading(false); // In case we used global loading
            notifyListeners();
          },
          onError: (e) {
            _isSearching = false;
            setError(e.toString());
          },
        );
  }

  void updateSearchQuery(String query) {
    _filterOptions = _filterOptions.copyWith(searchQuery: query);
    _searchSubject.add(_filterOptions);
  }

  void updateFilters(FilterOptions newFilters) {
    _filterOptions = newFilters;
    _searchSubject.add(_filterOptions);
  }

  void clearFilters() {
    _filterOptions = const FilterOptions();
    _searchSubject.add(_filterOptions);
  }

  @override
  void dispose() {
    _searchSubject.close();
    _subscription?.cancel();
    super.dispose();
  }
}
