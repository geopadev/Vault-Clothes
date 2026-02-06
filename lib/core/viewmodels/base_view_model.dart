import 'package:flutter/foundation.dart';

/// Base class for all ViewModels in the Vault-Clothes app.
/// Enforces consistent state management (loading, error, success).
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  @protected
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @protected
  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  /// Helper to run a future with automatic loading/error state management.
  @protected
  Future<void> runSafe(Future<void> Function() action) async {
    try {
      setLoading(true);
      setError(null);
      await action();
    } catch (e) {
      setError(e.toString());
      // Log error to analytics/crashlytics here
    } finally {
      setLoading(false);
    }
  }
}
