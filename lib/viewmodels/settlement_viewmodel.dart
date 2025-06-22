import 'dart:async';

import 'package:flutter/foundation.dart';
import '../data/repositories/settlement_repository.dart';
import '../data/models/settlement_model.dart';
import '../core/constants/console.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import '../data/repositories/settlement_repository.dart';
import '../data/models/settlement_model.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/split_transaction_repo.dart';
import '../core/constants/console.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

class SettlementViewModel extends ChangeNotifier {
  final SettlementRepository _repository;
  final SplitTransactionRepository _splitRepository;
  final AuthViewModel _authViewModel;

  List<SettlementModel> _settlements = [];
  List<TransactionModel> _splitTransactions = [];
  Map<String, List<SplitData>> _groupedSplitData = {};
  Map<String, double> _totalAmountsByPerson = {};

  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<SettlementModel>>? _settlementsSubscription;
  StreamSubscription<List<TransactionModel>>? _splitTransactionsSubscription;
  bool _disposed = false;

  SettlementViewModel({
    SettlementRepository? repository,
    SplitTransactionRepository? splitRepository,
    required AuthViewModel authViewModel,
  })  : _repository = repository ?? SettlementRepository(),
        _splitRepository = splitRepository ?? SplitTransactionRepository(),
        _authViewModel = authViewModel;

  // Existing getters
  List<SettlementModel> get settlements => _settlements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // New getters for split data
  List<TransactionModel> get splitTransactions => _splitTransactions;
  Map<String, List<SplitData>> get groupedSplitData => _groupedSplitData;
  Map<String, double> get totalAmountsByPerson => _totalAmountsByPerson;
  List<String> get peopleList => _groupedSplitData.keys.toList();

  // Combined data getter - settlements + split data
  Map<String, Map<String, dynamic>> get combinedSettlementData {
    Map<String, Map<String, dynamic>> combined = {};

    // Add manual settlements
    for (var settlement in _settlements) {
      final key = settlement.title;
      if (combined.containsKey(key)) {
        // If person already exists, add to their total
        combined[key]!['totalAmount'] =
            (combined[key]!['totalAmount'] as double) + settlement.amount;
        (combined[key]!['settlements'] as List<SettlementModel>)
            .add(settlement);
      } else {
        combined[key] = {
          'totalAmount': settlement.amount,
          'isOwed': settlement.isOwed,
          'settlements': [settlement],
          'splitTransactions': <TransactionModel>[],
          'splitAmount': 0.0,
        };
      }
    }

    // Add split transaction data
    _groupedSplitData.forEach((person, splits) {
      final splitAmount = splits.fold(0.0, (sum, split) => sum + split.amount);

      if (combined.containsKey(person)) {
        combined[person]!['splitAmount'] = splitAmount;
        combined[person]!['splitTransactions'] = _splitTransactions
            .where((t) => t.splitWith?.any((s) => s['name'] == person) == true)
            .toList();
        // Update total amount
        combined[person]!['totalAmount'] =
            (combined[person]!['totalAmount'] as double) + splitAmount;
      } else {
        combined[person] = {
          'totalAmount': splitAmount,
          'isOwed': true, // Split transactions are typically owed to you
          'settlements': <SettlementModel>[],
          'splitTransactions': _splitTransactions
              .where(
                  (t) => t.splitWith?.any((s) => s['name'] == person) == true)
              .toList(),
          'splitAmount': splitAmount,
        };
      }
    });

    return combined;
  }

  @override
  void dispose() {
    _settlementsSubscription?.cancel();
    _splitTransactionsSubscription?.cancel();
    _disposed = true;
    super.dispose();
  }

  Future<void> _loadSettlements() async {
    final userId = _authViewModel.currentUser?.id;
    if (userId == null || _disposed) return;

    try {
      _isLoading = true;
      if (!_disposed) notifyListeners();

      _settlementsSubscription?.cancel();

      _settlementsSubscription =
          _repository.getSettlements(userId).listen((settlements) {
        if (_disposed) return;
        _settlements = settlements;
        _updateCombinedData();
      }, onError: (error) {
        if (_disposed) return;
        console('Error in settlements stream: $error', type: DebugType.error);
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      if (_disposed) return;
      console('Error loading settlements: $e', type: DebugType.error);
      _error = 'Failed to load settlements. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSplitTransactions() async {
    final userId = _authViewModel.currentUser?.id;
    if (userId == null || _disposed) return;

    try {
      _splitTransactionsSubscription?.cancel();

      _splitTransactionsSubscription =
          _splitRepository.getSplitTransactions(userId).listen((transactions) {
        if (_disposed) return;
        _splitTransactions = transactions;
        _groupedSplitData =
            SplitTransactionRepository.groupSplitDataByPerson(transactions);
        _totalAmountsByPerson = {};
        _groupedSplitData.forEach((person, splits) {
          _totalAmountsByPerson[person] =
              splits.fold(0.0, (sum, split) => sum + split.amount);
        });
        _updateCombinedData();
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

  void _updateCombinedData() {
    _isLoading = false;
    notifyListeners();
  }

  // Initialize both data streams
  Future<void> initializeData() async {
    await Future.wait([
      _loadSettlements(),
      _loadSplitTransactions(),
    ]);
  }

  // Existing settlement methods
  Future<bool> addSettlement({
    required String title,
    required double amount,
    required bool isOwed,
    required List<String> participants,
  }) async {
    if (_disposed) return false;
    final userId = _authViewModel.currentUser?.id;
    if (userId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final newSettlement = SettlementModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: title,
        amount: amount,
        isOwed: isOwed,
        relatedTransactions: [],
        participants: participants,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.addSettlement(newSettlement);
      console('Successfully added settlement: ${newSettlement.id}',
          type: DebugType.info);
      return true;
    } catch (e) {
      console('Error adding settlement: $e', type: DebugType.error);
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSettlement(String id) async {
    try {
      await _repository.deleteSettlement(id);
      _settlements.removeWhere((s) => s.id == id);
      console('Deleted settlement: $id', type: DebugType.info);
      notifyListeners();
    } catch (e) {
      console('Error deleting settlement: $e', type: DebugType.error);
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsPaid(String id) async {
    try {
      await _repository.markAsPaid(id);
      final index = _settlements.indexWhere((s) => s.id == id);
      if (index != -1) {
        _settlements[index] = _settlements[index].copyWith(isOwed: false);
        console('Marked settlement as paid: $id', type: DebugType.info);
        notifyListeners();
      }
    } catch (e) {
      console('Error marking settlement as paid: $e', type: DebugType.error);
      _error = e.toString();
      notifyListeners();
    }
  }

  // New methods for split transaction management
  Future<bool> updateSplitData(
      String transactionId, List<Map<String, dynamic>>? splitWith) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      notifyListeners();

      await _splitRepository.updateSplitData(transactionId, splitWith);
      console('Successfully updated split data for transaction: $transactionId',
          type: DebugType.info);
      return true;
    } catch (e) {
      console('Error updating split data: $e', type: DebugType.error);
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeSplitData(String transactionId) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      notifyListeners();

      await _splitRepository.removeSplitData(transactionId);
      console(
          'Successfully removed split data from transaction: $transactionId',
          type: DebugType.info);
      return true;
    } catch (e) {
      console('Error removing split data: $e', type: DebugType.error);
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Utility methods
  List<SplitData> getSplitsForPerson(String personName) {
    return _groupedSplitData[personName] ?? [];
  }

  double getTotalForPerson(String personName) {
    final splits = getSplitsForPerson(personName);
    return splits.fold(0.0, (sum, split) => sum + split.amount);
  }

  List<TransactionModel> getTransactionsByPerson(String personName) {
    return _splitTransactions.where((transaction) {
      if (transaction.splitWith == null) return false;
      return transaction.splitWith!
          .any((split) => (split['name'] as String?) == personName);
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> reLoadSettlement() async {
    if (!_isLoading && !_disposed) {
      await initializeData();
    }
  }

  // Create settlement from split data
  Future<bool> createSettlementFromSplit(String personName) async {
    final splitAmount = getTotalForPerson(personName);
    if (splitAmount <= 0) return false;

    return await addSettlement(
      title: personName,
      amount: splitAmount,
      isOwed: false, // They owe you from split transactions
      participants: [personName],
    );
  }
}
/*

class SettlementViewModel extends ChangeNotifier {
  final SettlementRepository _repository;
  final AuthViewModel _authViewModel;
  List<SettlementModel> _settlements = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<SettlementModel>>? _settlementsSubscription;
  bool _disposed = false;

  SettlementViewModel({
    SettlementRepository? repository,
    required AuthViewModel authViewModel,
  })  : _repository = repository ?? SettlementRepository(),
        _authViewModel = authViewModel;

  List<SettlementModel> get settlements => _settlements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _settlementsSubscription?.cancel();
    _disposed = true;
    super.dispose();
  }

  Future<void> _loadSettlements() async {
    final userId = _authViewModel.currentUser?.id;
    if (userId == null || _disposed) return;

    try {
      _isLoading = true;
      if (!_disposed) notifyListeners();

      _settlementsSubscription?.cancel();

      _settlementsSubscription =
          _repository.getSettlements(userId).listen((settlements) {
        if (_disposed) return;
        _settlements = settlements;
        _isLoading = false;
        notifyListeners();
      }, onError: (error) {
        if (_disposed) return;
        console('Error in settlements stream: $error', type: DebugType.error);
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      if (_disposed) return;
      console('Error loading settlements: $e', type: DebugType.error);
      _error = 'Failed to load settlements. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSettlement({
    required String title,
    required double amount,
    required bool isOwed,
    required List<String> participants,
  }) async {
    if (_disposed) return false;
    final userId = _authViewModel.currentUser?.id;
    if (userId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final newSettlement = SettlementModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: title,
        amount: amount,
        isOwed: isOwed,
        relatedTransactions: [],
        participants: participants,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.addSettlement(newSettlement);
      console('Successfully added settlement: ${newSettlement.id}',
          type: DebugType.info);
      return true;
    } catch (e) {
      console('Error adding settlement: $e', type: DebugType.error);
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSettlement(String id) async {
    try {
      await _repository.deleteSettlement(id);
      _settlements.removeWhere((s) => s.id == id);
      console('Deleted settlement: $id', type: DebugType.info);
      notifyListeners();
    } catch (e) {
      console('Error deleting settlement: $e', type: DebugType.error);
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsPaid(String id) async {
    try {
      await _repository.markAsPaid(id);
      final index = _settlements.indexWhere((s) => s.id == id);
      if (index != -1) {
        _settlements[index] = _settlements[index].copyWith(isOwed: false);
        console('Marked settlement as paid: $id', type: DebugType.info);
        notifyListeners();
      }
    } catch (e) {
      console('Error marking settlement as paid: $e', type: DebugType.error);
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> reLoadSettlement() async {
    if (!_isLoading && !_disposed) {
      await _loadSettlements();
    }
  }
}
 */
