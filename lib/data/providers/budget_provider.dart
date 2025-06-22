import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../repositories/budget_repository.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _repository;
  List<BudgetModel> _budgets = [];
  bool _isLoading = false;

  BudgetProvider({BudgetRepository? repository})
      : _repository = repository ?? BudgetRepository();

  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;
   double get totalBudget =>
      _budgets.fold(0, (sum, budget) => sum + budget.amount);
  double get totalSpent =>
      _budgets.fold(0, (sum, budget) => sum + budget.spent);
  double get remainingBudget => totalBudget - totalSpent;

  Future<void> loadBudgets(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // _budgets = await _repository.getBudgets(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createBudget(BudgetModel budget) async {
    try {
      // await _repository.createBudget(budget);
      _budgets.add(budget);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBudget(BudgetModel budget) async {
    try {
      await _repository.updateBudget(budget);
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await _repository.deleteBudget(id);
      _budgets.removeWhere((budget) => budget.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

 

  Future<void> addSpendingToCategory(String category, double amount) async {
    final index = _budgets.indexWhere((b) => b.category == category);
    if (index != -1) {
      final budget = _budgets[index];
      final updatedBudget = budget.copyWith(spent: budget.spent + amount);
      _budgets[index] = updatedBudget;
      notifyListeners();
      await _repository.updateBudget(updatedBudget);
    }
  }
}
