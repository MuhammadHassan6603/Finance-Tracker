import 'package:flutter/foundation.dart';
import '../data/models/debt_model.dart';
import '../data/repositories/debt_repository.dart';
import 'auth_viewmodel.dart';
import 'dart:async';

class DebtViewModel extends ChangeNotifier {
  final DebtRepository _repository;
  final AuthViewModel _authViewModel;

  List<DebtModel> _debts = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  StreamSubscription<List<DebtModel>>? _subscription;

  DebtViewModel({
    required AuthViewModel authViewModel,
    DebtRepository? repository,
  })  : _authViewModel = authViewModel,
        _repository = repository ?? DebtRepository() {
    _init();
  }

  List<DebtModel> get debts => _debts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthViewModel get authViewModel => _authViewModel;

  double get totalDebt => _debts.fold(0.0, (sum, debt) => sum + debt.remainingAmount);
  double get totalMonthlyPayment => _debts.fold(0.0, (sum, debt) => sum + debt.minimumPayment);
  double get averageInterestRate {
    if (_debts.isEmpty) return 0.0;
    return _debts.fold(0.0, (sum, debt) => sum + debt.interestRate) / _debts.length;
  }

  List<DebtModel> get activeDebts => _debts.where((debt) => debt.isActive).toList();
  List<DebtModel> get paidOffDebts => _debts.where((debt) => !debt.isActive).toList();

  void _init() {
    if (_authViewModel.currentUser != null) {
      _loadDebts();
    }
    _authViewModel.addListener(_authStateChanged);
  }

  void _authStateChanged() {
    if (_authViewModel.currentUser != null) {
      _loadDebts();
    } else {
      _debts = [];
      notifyListeners();
    }
  }

  Future<void> _loadDebts() async {
    final userId = _authViewModel.currentUser?.id;
    if (userId == null || _disposed) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _subscription?.cancel();
      _subscription = _repository.getDebts(userId).listen(
        (debts) {
          if (_disposed) return;
          _debts = debts;
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
      _error = 'Failed to load debts';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addDebt(DebtModel debt) async {
    if (_disposed) return false;
    final user = _authViewModel.currentUser;
    if (user == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.addDebt(debt);
      return true;
    } catch (e) {
      _error = 'Failed to add debt: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> updateDebt(DebtModel debt) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateDebt(debt);
      return true;
    } catch (e) {
      _error = 'Failed to update debt: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> deleteDebt(String debtId) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deleteDebt(debtId);
      return true;
    } catch (e) {
      _error = 'Failed to delete debt: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> addPayment(String debtId, double amount) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.addPayment(debtId, amount);
      return true;
    } catch (e) {
      _error = 'Failed to add payment: ${e.toString()}';
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

  // Helper methods for debt analysis
  Map<DebtType, double> getDebtDistribution() {
    final distribution = <DebtType, double>{};
    for (final debt in _debts) {
      distribution[debt.type] = (distribution[debt.type] ?? 0) + debt.remainingAmount;
    }
    return distribution;
  }

  double getDebtToIncomeRatio(double monthlyIncome) {
    if (monthlyIncome <= 0) return double.infinity;
    return (totalMonthlyPayment / monthlyIncome) * 100;
  }

  List<DebtModel> getSortedByInterestRate({bool descending = true}) {
    final sorted = List<DebtModel>.from(_debts);
    sorted.sort((a, b) => descending
        ? b.interestRate.compareTo(a.interestRate)
        : a.interestRate.compareTo(b.interestRate));
    return sorted;
  }

  List<DebtModel> getSortedByRemainingAmount({bool descending = true}) {
    final sorted = List<DebtModel>.from(_debts);
    sorted.sort((a, b) => descending
        ? b.remainingAmount.compareTo(a.remainingAmount)
        : a.remainingAmount.compareTo(b.remainingAmount));
    return sorted;
  }
} 