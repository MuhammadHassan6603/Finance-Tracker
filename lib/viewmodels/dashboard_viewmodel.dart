import 'package:flutter/foundation.dart';
import '../data/providers/transaction_provider.dart';
import '../data/providers/budget_provider.dart';
import '../data/models/transaction_model.dart';
import '../data/models/budget_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final TransactionProvider _transactionProvider;
  final BudgetProvider _budgetProvider;
  bool _isLoading = false;

  DashboardViewModel({
    TransactionProvider? transactionProvider,
    BudgetProvider? budgetProvider,
  })  : _transactionProvider = transactionProvider ?? TransactionProvider(),
        _budgetProvider = budgetProvider ?? BudgetProvider();

  bool get isLoading => _isLoading;
  List<TransactionModel> get recentTransactions =>
      _transactionProvider.transactions.take(5).toList();
  double get totalBalance => _transactionProvider.balance;
  double get monthlyIncome => _transactionProvider.totalIncome;
  double get monthlyExpenses => _transactionProvider.totalExpenses;
  List<BudgetModel> get budgets => _budgetProvider.budgets;
  double get totalBudget => _budgetProvider.totalBudget;
  double get remainingBudget => _budgetProvider.remainingBudget;

  Future<void> loadDashboardData(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.wait([
        _transactionProvider.loadTransactions(userId),
        _budgetProvider.loadBudgets(userId),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
