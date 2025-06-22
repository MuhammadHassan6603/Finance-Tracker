import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/transaction_model.dart';
import '../core/constants/console.dart';
import '../data/repositories/split_transaction_repo.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'package:rxdart/rxdart.dart'; // Ensure rxdart is imported if used elsewhere

class SplitTransactionViewModel extends ChangeNotifier {
  final SplitTransactionRepository _repository;
  final AuthViewModel _authViewModel;

  List<TransactionModel> _splitTransactions = [];
  Map<String, List<SplitData>> _groupedSplitData = {};
  bool _isLoading = false;
  String? _error;
  // Only need one subscription now for the split transactions stream
  StreamSubscription<List<TransactionModel>>? _splitTransactionsSubscription;
  // The grouped data is derived from _splitTransactions, not a separate stream
  bool _disposed = false;

  SplitTransactionViewModel({
    SplitTransactionRepository? repository,
    required AuthViewModel authViewModel,
  })  : _repository = repository ?? SplitTransactionRepository(),
        _authViewModel = authViewModel;

  // Getters
  List<TransactionModel> get splitTransactions => _splitTransactions;
  Map<String, List<SplitData>> get groupedSplitData => _groupedSplitData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get total amount owed by each person
  Map<String, double> get totalAmountsByPerson {
    Map<String, double> totals = {};
    _groupedSplitData.forEach((person, splits) {
      totals[person] = splits.fold(0.0, (sum, split) => sum + split.amount);
    });
    return totals;
  }

  // Get list of unique people
  List<String> get peopleList => _groupedSplitData.keys.toList();

  @override
  void dispose() {
    _splitTransactionsSubscription?.cancel();
    _disposed = true;
    super.dispose();
  }

  // Load split transactions and then group them
  Future<void> loadSplitTransactions() async {
    final userId = _authViewModel.currentUser?.id;
    if (userId == null || _disposed) return;

    try {
      _isLoading = true;
      if (!_disposed) notifyListeners();

      // Cancel previous subscription before creating a new one
      _splitTransactionsSubscription?.cancel();

      _splitTransactionsSubscription =
          _repository.getSplitTransactions(userId).listen((transactions) {
        if (_disposed) return;
        _splitTransactions = transactions;
        // --- Group the fetched transactions ---
        _groupedSplitData = SplitTransactionRepository.groupSplitDataByPerson(transactions);
        // -------------------------------------
        _isLoading = false;
        notifyListeners();
      }, onError: (error) {
        if (_disposed) return;
        console('Error in split transactions stream: $error',
            type: DebugType.error);
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      if (_disposed) return;
      console('Error loading split transactions: $e', type: DebugType.error);
      _error = 'Failed to load split transactions. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get splits for a specific person
  List<SplitData> getSplitsForPerson(String personName) {
    return _groupedSplitData[personName] ?? [];
  }

  // Get total amount for a specific person
  double getTotalForPerson(String personName) {
    final splits = getSplitsForPerson(personName);
    return splits.fold(0.0, (sum, split) => sum + split.amount);
  }

  // Update split data for a transaction
  Future<bool> updateSplitData(
      String transactionId, List<Map<String, dynamic>>? splitWith) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      notifyListeners();

      await _repository.updateSplitData(transactionId, splitWith);
      console('Successfully updated split data for transaction: $transactionId',
          type: DebugType.info);
      // The stream listener for getSplitTransactions will automatically
      // update _splitTransactions and _groupedSplitData after the repository operation.
      return true;
    } catch (e) {
      console('Error updating split data: $e', type: DebugType.error);
      _error = e.toString();
      notifyListeners(); // Notify on error
      return false;
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify after loading state changes
    }
  }

  // Remove split data from a transaction
  Future<bool> removeSplitData(String transactionId) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      notifyListeners();

      await _repository.removeSplitData(transactionId);
      console(
          'Successfully removed split data from transaction: $transactionId',
          type: DebugType.info);
      // The stream listener will update the data automatically.
      return true;
    } catch (e) {
      console('Error removing split data: $e', type: DebugType.error);
      _error = e.toString();
      notifyListeners(); // Notify on error
      return false;
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify after loading state changes
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reload data (only need to load split transactions, grouping is automatic)
  Future<void> reloadData() async {
    if (!_isLoading && !_disposed) {
      await loadSplitTransactions();
    }
  }

  // Filter transactions by person (uses the already loaded _splitTransactions)
  List<TransactionModel> getTransactionsByPerson(String personName) {
    return _splitTransactions.where((transaction) {
      if (transaction.splitWith == null) return false;
      return transaction.splitWith!
          .any((split) => (split['name'] as String?) == personName);
    }).toList();
  }

  // Get split percentage for a person in a specific transaction
  double getSplitPercentage(String transactionId, String personName) {
    // Find the transaction in the currently loaded list
    final transaction = _splitTransactions.firstWhere(
      (t) => t.id == transactionId,
      orElse: () {
         // Handle case where transaction is not found in the current list
         console('Transaction $transactionId not found in loaded split transactions.', type: DebugType.error);
         // Depending on requirements, you might fetch it specifically or return a default.
         return TransactionModel(id: transactionId, userId: '', amount: 0, type: TransactionType.expense, category: '', description: '', date: DateTime.now(), paymentMethod: ''); // Return a dummy or throw
      },
    );

    if (transaction.splitWith == null) return 0.0;

    final split = transaction.splitWith!.firstWhere(
      (s) => (s['name'] as String?) == personName,
      orElse: () => <String, dynamic>{}, // Return empty map if split not found
    );

    return (split['percentage'] as num?)?.toDouble() ?? 0.0; // Safely access percentage
  }
}
