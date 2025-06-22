import 'package:flutter/foundation.dart';
import '../data/models/retirement_model.dart';
import '../data/repositories/retirement_repository.dart';
import 'auth_viewmodel.dart';
import 'dart:async';

class RetirementViewModel extends ChangeNotifier {
  final RetirementRepository _repository;
  final AuthViewModel _authViewModel;

  RetirementModel? _retirementPlan;
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  StreamSubscription? _subscription;

  RetirementViewModel({
    required AuthViewModel authViewModel,
    RetirementRepository? repository,
  })  : _authViewModel = authViewModel,
        _repository = repository ?? RetirementRepository() {
    _init();
  }

  RetirementModel? get retirementPlan => _retirementPlan;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthViewModel get authViewModel => _authViewModel;

  void _init() {
    if (_authViewModel.currentUser != null) {
      _loadRetirementPlan();
    }
    _authViewModel.addListener(_authStateChanged);
  }

  void _authStateChanged() {
    if (_authViewModel.currentUser != null) {
      _loadRetirementPlan();
    } else {
      _retirementPlan = null;
      notifyListeners();
    }
  }

  Future<void> _loadRetirementPlan() async {
    final userId = _authViewModel.currentUser?.id;
    if (userId == null || _disposed) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _subscription?.cancel();
      _subscription = _repository.getRetirementPlan(userId).listen(
        (plan) {
          if (_disposed) return;
          _retirementPlan = plan;
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
      _error = 'Failed to load retirement plan';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveRetirementPlan(RetirementModel plan) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.saveRetirementPlan(plan);
      return true;
    } catch (e) {
      _error = 'Failed to save retirement plan: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> deleteRetirementPlan() async {
    if (_disposed || _retirementPlan == null) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deleteRetirementPlan(_retirementPlan!.id);
      return true;
    } catch (e) {
      _error = 'Failed to delete retirement plan: ${e.toString()}';
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
