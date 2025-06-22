import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  TransactionProvider({TransactionRepository? repository})
      : _repository = repository ?? TransactionRepository();

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadTransactions(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // _transactions = await _repository.getTransactions(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _repository.addTransaction(transaction);
      _transactions.insert(0, transaction);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      _transactions.removeWhere((transaction) => transaction.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  double get totalIncome => _transactions
      .where((transaction) => transaction.type == TransactionType.income)
      .fold(0, (sum, transaction) => sum + transaction.amount);

  double get totalExpenses => _transactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .fold(0, (sum, transaction) => sum + transaction.amount);

  double get balance => totalIncome - totalExpenses;
}
