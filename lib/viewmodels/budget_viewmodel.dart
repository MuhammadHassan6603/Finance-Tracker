import 'dart:async';

import 'package:finance_tracker/core/constants/categories_list.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/console.dart';
import '../data/models/budget_model.dart';
import '../data/repositories/budget_repository.dart';
import 'auth_viewmodel.dart';
import 'transaction_viewmodel.dart';
import '../core/services/budget_notification_service.dart';
import '../core/services/notification_settings_service.dart';

class BudgetViewModel extends ChangeNotifier {
  final BudgetRepository _repository;
  final AuthViewModel _authViewModel;
  final TransactionViewModel _transactionViewModel;
  final BudgetNotificationService _notificationService;
  final NotificationSettingsService _settingsService;

  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  StreamSubscription<List<BudgetModel>>? _budgetsSubscription;
  DateTime _selectedMonth = DateTime.now();

  BudgetViewModel({
    required AuthViewModel authViewModel,
    required TransactionViewModel transactionViewModel,
    required NotificationSettingsService settingsService,
    BudgetRepository? repository,
    BudgetNotificationService? notificationService,
  })  : _authViewModel = authViewModel,
        _transactionViewModel = transactionViewModel,
        _settingsService = settingsService,
        _repository = repository ?? BudgetRepository(),
        _notificationService = notificationService ?? BudgetNotificationService() {
    _init();
  }

  AuthViewModel get authViewModel => _authViewModel;

  void _init() {
    if (_authViewModel.currentUser != null) {
      _loadBudgets();
    }
    _authViewModel.addListener(_authStateChanged);
  }

  void _authStateChanged() {
    if (_authViewModel.currentUser != null) {
      _loadBudgets();
    } else {
      _budgets = [];
      notifyListeners();
    }
  }

  // Public properties
  List<BudgetModel> get budgets => _budgets;

  bool get isLoading => _isLoading;

  String? get error => _error;

  double get totalBudget =>
      filteredBudgets.fold(0.0, (sum, b) => sum + b.amount);

  double get totalSpent {
    double total = 0.0;
    for (var budget in filteredBudgets) {
      total += getSpentForBudget(budget);
    }
    return total;
  }

  // New method to get spent amount for a specific budget
  double getSpentForBudget(BudgetModel budget) {
    if (!budget.isActive) return 0.0;

    // Only count transactions after this budget was created
    return _transactionViewModel.getTotalByTypeAndCategory(
      TransactionType.expense,
      budget.category,
      budget.createdAt, // Use budget creation date as start
      budget.endDate,
    );
  }

  double get remainingBudget => totalBudget - totalSpent;

  List<BudgetModel> get filteredBudgets => _budgets
      .where((b) =>
          b.startDate.month == _selectedMonth.month &&
          b.startDate.year == _selectedMonth.year)
      .toList();

  @override
  void dispose() {
    _budgetsSubscription?.cancel();
    _authViewModel.removeListener(_authStateChanged);
    _disposed = true;
    super.dispose();
  }

  Future<void> _loadBudgets() async {
    final userId = _authViewModel.currentUser?.id;
    if (userId == null || _disposed) return;

    try {
      _isLoading = true;
      _error = null;
      if (!_disposed) notifyListeners();

      _budgetsSubscription?.cancel();
      _budgetsSubscription = _repository.getBudgetsByUser(userId).listen(
        (budgets) {
          if (_disposed) return;
          _budgets = budgets;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          if (_disposed) return;
          console('Budget stream error: $error', type: DebugType.error);
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      if (_disposed) return;
      console('Budget load error: $e', type: DebugType.error);
      _error = 'Failed to load budgets';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBudget(BudgetModel budget) async {
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

      // Check if a budget already exists for this category in the current month
      final existingBudget = _budgets.any((b) =>
          b.category == budget.category &&
          b.startDate.month == budget.startDate.month &&
          b.startDate.year == budget.startDate.year);

      if (existingBudget) {
        _error =
            'A budget for this category already exists in the selected month';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _repository.addBudget(budget);
      
      // Only send notifications if budget limits notifications are enabled
      if (_settingsService.budgetLimitsEnabled) {
        await _notificationService.sendBudgetUpdateNotification(budget, 'created');
        
        final now = DateTime.now();
        if (budget.startDate.isAfter(now) || 
            (budget.startDate.year == now.year && budget.startDate.month == now.month)) {
          await _notificationService.scheduleMonthlyBudgetSummary([budget]);
          await _notificationService.scheduleWeeklyBudgetCheckIn();
        }
      }
      
      return true;
    } catch (e) {
      console('Budget creation error: $e', type: DebugType.error);
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> updateBudget(BudgetModel budget) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateBudget(budget);
      
      // Send notification for budget update
      await _notificationService.sendBudgetUpdateNotification(budget, 'updated');
      
      // Check budget status and send appropriate alerts
      final currentSpent = getSpentForBudget(budget);
      await _notificationService.checkBudgetStatus(budget, currentSpent);
      
      return true;
    } catch (e) {
      console('Budget update error: $e', type: DebugType.error);
      _error = 'Failed to update budget: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> deleteBudget(String budgetId) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get the budget before deletion
      final budget = _budgets.firstWhere((b) => b.id == budgetId);

      // Delete the budget from Firestore
      await _repository.deleteBudget(budgetId);

      // Remove from local state
      _budgets.removeWhere((b) => b.id == budgetId);

      // Send notification for budget deletion
      await _notificationService.sendBudgetUpdateNotification(budget, 'deleted');
      
      // Cancel all notifications for this budget
      await _notificationService.cancelBudgetNotifications(budgetId);

      notifyListeners();
      return true;
    } catch (e) {
      console('Budget deletion error: $e', type: DebugType.error);
      _error = 'Failed to delete budget: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reloadBudgets() {
    if (!_isLoading && !_disposed) {
      _loadBudgets();
    }
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
  }

  double getTotalBudget() {
    // Sum of all category budgets for selected month
    return filteredBudgets.fold(0.0, (sum, budget) => sum + budget.amount);
  }

  List<String> getBudgetCategories() {
    return filteredBudgets.map((budget) => budget.category).toList();
  }

  double getBudgetForCategory(String category) {
    final budget = filteredBudgets.firstWhere(
      (budget) => budget.category == category,
      orElse: () => BudgetModel(
        id: '',
        userId: '',
        category: category,
        amount: 0.0,
        spent: 0.0,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        periodType: 'monthly',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        icon: '',
        iconFontFamily: 'Material',
        isActive: true,
      ),
    );
    return budget.amount;
  }

  double getSpentForCategory(String category) {
    final budget = filteredBudgets.firstWhere(
      (b) => b.category == category && b.isActive,
      orElse: () => BudgetModel(
          id: '',
          userId: '',
          category: category,
          amount: 0.0,
          icon: '',
          iconFontFamily: '',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          periodType: 'monthly',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
    );

    if (budget == null) return 0.0;

    return _transactionViewModel.getTotalByTypeAndCategory(
      TransactionType.expense,
      category,
      budget.createdAt, // Use budget creation date as start
      DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0),
    );
  }

  Future<void> addSpendingToCategory(String category, double amount) async {
    try {
      // Find the active budget for this category in the current month
      final budgetIndex = _budgets.indexWhere(
        (b) =>
            b.category == category &&
            b.startDate.month == DateTime.now().month &&
            b.startDate.year == DateTime.now().year &&
            b.isActive,
      );

      if (budgetIndex == -1) {
        // Create new budget if doesn't exist
        final categoryData = CategoryList.categories.firstWhere(
          (cat) => cat['title'] == category,
          orElse: () => {'icon': Icons.category, 'title': category},
        );

        final newBudget = BudgetModel(
          id: const Uuid().v4(),
          userId: _authViewModel.currentUser?.id ?? '',
          category: category,
          amount: 0.0,
          icon: categoryData['icon'].toString(),
          iconFontFamily: 'MaterialIcons',
          startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
          endDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
          periodType: 'monthly',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        );

        // Add to Firestore
        await _repository.addBudget(newBudget);

        // Add to local state
        _budgets.add(newBudget);
        notifyListeners();
      }
    } catch (e) {
      console('Error updating budget spending: $e', type: DebugType.error);
      _error = 'Failed to update budget spending';
      notifyListeners();
    }
  }

  // Add method to get budget status for a category
  Map<String, dynamic> getBudgetStatusForCategory(String category) {
    final budget = getBudgetForCategory(category);
    final spent = getSpentForCategory(category);

    return {
      'budget': budget,
      'spent': spent,
      'remaining': budget - spent,
      'percentage': budget > 0 ? (spent / budget) * 100 : 0,
    };
  }

  // Add method to get available budget for a category
  double getAvailableBudgetForCategory(String category) {
    final budget = getBudgetForCategory(category);
    final spent = getSpentForCategory(category);
    return budget - spent;
  }

  // Add public getter for selectedMonth
  DateTime get selectedMonth => _selectedMonth;

  // Add a helper method to check if a budget exists for a category
  bool isBudgetExistsForCategory(String category, DateTime date) {
    return _budgets.any((b) =>
        b.category == category &&
        b.startDate.month == date.month &&
        b.startDate.year == date.year);
  }

  // Add this method to check if a category has an active budget
  bool hasBudgetForCategory(String category) {
    return filteredBudgets.any((b) => b.category == category && b.isActive);
  }

  // Add method to check budget status and send notifications
  Future<void> checkBudgetStatusAndNotify() async {
    if (_disposed || !_settingsService.budgetLimitsEnabled) return;
    
    for (final budget in filteredBudgets) {
      if (budget.isActive) {
        final currentSpent = getSpentForBudget(budget);
        await _notificationService.checkBudgetStatus(budget, currentSpent);
      }
    }
  }
}
