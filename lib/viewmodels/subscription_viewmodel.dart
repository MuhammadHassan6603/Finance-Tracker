import 'package:flutter/foundation.dart';
import '../data/models/subscription_model.dart';
import '../data/repositories/subscription_repository.dart';
import 'auth_viewmodel.dart';
import 'dart:async';

class SubscriptionViewModel extends ChangeNotifier {
  final SubscriptionRepository _repository;
  final AuthViewModel _authViewModel;

  SubscriptionModel? _currentSubscription;
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  StreamSubscription? _subscription;

  SubscriptionViewModel({
    required AuthViewModel authViewModel,
    SubscriptionRepository? repository,
  })  : _authViewModel = authViewModel,
        _repository = repository ?? SubscriptionRepository() {
    _init();
  }

  SubscriptionModel? get currentSubscription => _currentSubscription;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _init() {
    if (_authViewModel.currentUser != null) {
      _loadSubscription();
    }
    _authViewModel.addListener(_authStateChanged);
  }

  void _authStateChanged() {
    if (_authViewModel.currentUser != null) {
      _loadSubscription();
    } else {
      _currentSubscription = null;
      notifyListeners();
    }
  }

  Future<void> _loadSubscription() async {
    final userId = _authViewModel.currentUser?.id;
    if (userId == null || _disposed) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _subscription?.cancel();
      _subscription = _repository.getCurrentSubscription(userId).listen(
        (subscription) {
          if (_disposed) return;
          _currentSubscription = subscription;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          if (_disposed) return;
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      if (_disposed) return;
      _error = 'Failed to load subscription';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSubscription(
    SubscriptionType type,
    double amount,
    DateTime endDate,
  ) async {
    if (_disposed) return false;
    final userId = _authViewModel.currentUser?.id;
    if (userId == null) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final subscription = SubscriptionModel(
        id: _currentSubscription?.id ?? '',
        userId: userId,
        type: type,
        startDate: DateTime.now(),
        endDate: endDate,
        isActive: true,
        amount: amount,
        currency: 'USD', // You might want to make this dynamic
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.saveSubscription(subscription);
      return true;
    } catch (e) {
      _error = 'Failed to update subscription: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _authViewModel.removeListener(_authStateChanged);
    _disposed = true;
    super.dispose();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 