import 'package:finance_tracker/core/services/recurring_transaction_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/models/transaction_model.dart';
import 'package:collection/collection.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../core/services/notification_settings_service.dart';
import '../viewmodels/account_card_viewmodel.dart';
import '../viewmodels/credit_card_statement_viewmodel.dart';
import '../data/repositories/account_card_repository.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _repository;
  final AuthViewModel _authViewModel;
  final RecurringTransactionNotificationService? _notificationService;
  final NotificationSettingsService _settingsService;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  DateTime _selectedMonth = DateTime.now();

  // Total tracking variables
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  double _availableBalance = 0.0;

  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  TransactionType? _filterType;
  String? _filterPaymentMethod;

  TransactionViewModel({
    required AuthViewModel authViewModel,
    required NotificationSettingsService settingsService,
    TransactionRepository? repository,
    RecurringTransactionNotificationService? notificationService,
  })  : _authViewModel = authViewModel,
        _settingsService = settingsService,
        _repository = repository ?? TransactionRepository(),
        _notificationService = notificationService {
    _init();
  }

  // Getters
  List<TransactionModel> get transactions {
    print('[TransactionViewModel] get transactions: count = \\${_transactions.length}');
    return _transactions;
  }
  bool get isLoading {
    print('[TransactionViewModel] get isLoading: \\$_isLoading');
    return _isLoading;
  }
  String? get error {
    print('[TransactionViewModel] get error: \\$_error');
    return _error;
  }
  String? get currentUserId {
    print('[TransactionViewModel] get currentUserId: \\${_authViewModel.currentUser?.id}');
    return _authViewModel.currentUser?.id;
  }
  DateTime get selectedMonth {
    print('[TransactionViewModel] get selectedMonth: \\$_selectedMonth');
    return _selectedMonth;
  }

  // Filtered transactions for selected month
  List<TransactionModel> get filteredTransactions {
    final filtered = _transactions
      .where((t) =>
          t.date.month == _selectedMonth.month &&
          t.date.year == _selectedMonth.year)
      .toList();
    print('[TransactionViewModel] get filteredTransactions: month=\\${_selectedMonth.month}, year=\\${_selectedMonth.year}, count=\\${filtered.length}');
    return filtered;
  }

  // Monthly totals
  double get totalIncome => filteredTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => filteredTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get availableBalance => totalIncome - totalExpense;

  void _init() {
    print('[TransactionViewModel] _init called');
    if (_authViewModel.currentUser != null) {
      loadTransactionsForMonth(_selectedMonth);
    }
  }

  Future<void> setSelectedMonth(DateTime month) async {
    print('[TransactionViewModel] setSelectedMonth: month=\\${month.month}, year=\\${month.year}');
    _selectedMonth = DateTime(month.year, month.month, 1);
    await loadTransactionsForMonth(_selectedMonth);
    notifyListeners();
  }

  Future<void> loadTransactionsForMonth(DateTime month) async {
    print('[TransactionViewModel] loadTransactionsForMonth: month=\\${month.month}, year=\\${month.year}');
    if (currentUserId == null) {
      print('[TransactionViewModel] No current user ID available');
      return;
    }
    try {
      _setLoading(true);
      _error = null;

      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      print('[TransactionViewModel] Fetching from repo: startDate=\\$startDate, endDate=\\$endDate');

      final transactions = await _repository.getTransactions(
        userId: currentUserId!,
        startDate: startDate,
        endDate: endDate,
      );

      print('[TransactionViewModel] Loaded \\${transactions.length} transactions from repo');

      _transactions = transactions;
      notifyListeners();
    } catch (e) {
      print('[TransactionViewModel] Error loading transactions: \\$e');
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshCurrentMonth() async {
    print('[TransactionViewModel] refreshCurrentMonth called');
    await loadTransactionsForMonth(_selectedMonth);
  }

  Map<String, dynamic> getMonthlyStatistics() {
    final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    // Get category breakdown
    final categoryBreakdown = groupBy(
      filteredTransactions.where((t) => t.type == TransactionType.expense),
      (TransactionModel t) => t.category,
    ).map((category, transactions) => MapEntry(
          category,
          transactions.fold(0.0, (sum, t) => sum + t.amount),
        ));

    // Get previous month comparison
    final previousMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    final previousMonthStats = _getPreviousMonthComparison(previousMonth);

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': availableBalance,
      'transactionCount': filteredTransactions.length,
      'startDate': startDate,
      'endDate': endDate,
      'categoryBreakdown': categoryBreakdown,
      'previousMonth': previousMonthStats,
    };
  }

  Map<String, double> _getPreviousMonthComparison(DateTime previousMonth) {
    final previousTransactions = _transactions.where((t) =>
        t.date.month == previousMonth.month &&
        t.date.year == previousMonth.year);

    final previousIncome = previousTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final previousExpense = previousTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final previousBalance = previousIncome - previousExpense;

    return {
      'incomeChange': totalIncome > 0 && previousIncome > 0
          ? ((totalIncome - previousIncome) / previousIncome) * 100
          : 0.0,
      'expenseChange': totalExpense > 0 && previousExpense > 0
          ? ((totalExpense - previousExpense) / previousExpense) * 100
          : 0.0,
      'balanceChange': availableBalance != 0 && previousBalance != 0
          ? ((availableBalance - previousBalance) / previousBalance.abs()) * 100
          : 0.0,
    };
  }

  Future<void> loadTransactions({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? paymentMethod,
  }) async {
    if (currentUserId == null) return;

    try {
      _setLoading(true);
      _error = null;

      _startDate = startDate ?? _startDate;
      _endDate = endDate ?? _endDate;

      _transactions = await _repository.getTransactions(
        userId: currentUserId!,
        startDate: _startDate,
        endDate: _endDate,
        type: type,
        paymentMethod: paymentMethod,
      );

      _calculateTotals(transactions);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<List<TransactionModel>> getTransactionsByPaymentMethod(
      String paymentMethod) async {
    if (currentUserId == null) return [];

    try {
      return await _repository.getTransactions(
        userId: currentUserId!,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<TransactionModel>> getRecurringTransactions() async {
    if (currentUserId == null) return [];

    try {
      final transactions = await _repository.getTransactions(
        userId: currentUserId!,
      );
      return transactions.where((t) => t.isRecurring).toList();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> _loadTotals() async {
    if (currentUserId == null) return;

    try {
      final transactions =
          await _repository.getTransactions(userId: currentUserId!);
      _calculateTotals(transactions);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _calculateTotals(List<TransactionModel> transactions) {
    _totalIncome = 0.0;
    _totalExpense = 0.0;

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        _totalIncome += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        _totalExpense += transaction.amount;
      }
    }

    _availableBalance = _totalIncome - _totalExpense;
    notifyListeners();
  }

  Future<bool> addTransaction(TransactionModel transaction) async {
    print('[TransactionViewModel] addTransaction called');
    if (currentUserId == null) return false;

    try {
      _setLoading(true);
      _error = null;

      final newTransaction = await _repository.addTransaction(
        transaction.copyWith(userId: currentUserId),
      );

      // Update totals based on transaction type
      if (transaction.type == TransactionType.income) {
        _totalIncome += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        _totalExpense += transaction.amount;
      }
      _availableBalance = _totalIncome - _totalExpense;

      _transactions.insert(0, newTransaction);

      // Update credit card statement if needed
      if (transaction.paymentMethod.isNotEmpty) {
        try {
          await _updateStatementForTransaction(transaction);
        } catch (e) {
          print('Error updating statement for transaction: $e');
          // Don't fail the transaction if statement update fails
        }
      }

      // Only schedule notifications if bill payment notifications are enabled
      if (transaction.isRecurring && 
          _notificationService != null && 
          _settingsService.billPaymentEnabled) {
        try {
          await _notificationService!
              .scheduleRecurringTransactionNotifications(newTransaction);
        } catch (notificationError) {
          print('Error scheduling notification: $notificationError');
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _updateStatementForTransaction(TransactionModel transaction) async {
    try {
      print('Updating statement for transaction: ${transaction.description} - ${transaction.amount}');
      
      // Get card information from the repository
      final accountCardRepo = AccountCardRepository();
      final cardsStream = accountCardRepo.getAccountCards(currentUserId!);
      final cards = await cardsStream.first;
      final card = cards.firstWhereOrNull((c) => c.name == transaction.paymentMethod && c.type == 'Credit Card');
      
      if (card != null) {
        print('Found credit card: ${card.name} with ID: ${card.id}');
        final statementVM = CreditCardStatementViewModel();
        final currentStatement = await statementVM.getCurrentStatement(card.id);
        
        if (currentStatement != null) {
          print('Found current statement for card ${card.name}');
          final isRepayment = transaction.type == TransactionType.income && 
                             transaction.description.toLowerCase().contains('repay');
          
          final updatedTransactions = List<TransactionModel>.from(currentStatement.transactions);
          final updatedRepayments = List<TransactionModel>.from(currentStatement.repayments);
          double closingBalance = currentStatement.closingBalance;
          
          if (isRepayment) {
            print('Adding repayment transaction: ${transaction.amount}');
            updatedRepayments.add(transaction);
            closingBalance -= transaction.amount;
          } else if (transaction.type == TransactionType.expense) {
            print('Adding expense transaction: ${transaction.amount}');
            updatedTransactions.add(transaction);
            closingBalance += transaction.amount;
          }
          
          print('Updated statement - Transactions: ${updatedTransactions.length}, Repayments: ${updatedRepayments.length}, Closing Balance: $closingBalance');
          
          await statementVM.addOrUpdateStatement(currentStatement.copyWith(
            transactions: updatedTransactions,
            repayments: updatedRepayments,
            closingBalance: closingBalance,
          ));
          
          print('Successfully updated statement for card ${card.name}');
        } else {
          print('No current statement found for card ${card.name} - creating initial statement');
          // Create initial statement if none exists
          await statementVM.createInitialStatementForCard(card, card.balance);
          // Try to update again
          await _updateStatementForTransaction(transaction);
        }
      } else {
        print('No credit card found for payment method: ${transaction.paymentMethod}');
        print('Available cards: ${cards.map((c) => '${c.name} (${c.type})').join(', ')}');
      }
    } catch (e) {
      print('Error in _updateStatementForTransaction: $e');
      rethrow;
    }
  }

  void handleError(Object error, StackTrace stackTrace) {
    _error = error.toString();
    notifyListeners();
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    print('[TransactionViewModel] updateTransaction called');
    try {
      _setLoading(true);
      _error = null;

      await _repository.updateTransaction(transaction);

      // Reload all transactions to recalculate totals
      await loadTransactionsForMonth(_selectedMonth);

      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      }

      // Update notifications if it's a recurring transaction and notification service is available
      if (_notificationService != null) {
        try {
          if (transaction.isRecurring) {
            await _notificationService!
                .updateRecurringNotifications(transaction);
          } else {
            // Cancel notifications if it's no longer recurring
            await _notificationService!
                .cancelRecurringNotifications(transaction.id!);
          }
        } catch (notificationError) {
          print('Error updating notifications: $notificationError');
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTransaction(String id) async {
    print('[TransactionViewModel] deleteTransaction called');
    try {
      _setLoading(true);
      _error = null;

      // Find the transaction before removing it
      final deletedTransaction = _transactions.firstWhere((t) => t.id == id);

      await _repository.deleteTransaction(id);

      // Update totals based on deleted transaction
      if (deletedTransaction.type == TransactionType.income) {
        _totalIncome -= deletedTransaction.amount;
      } else if (deletedTransaction.type == TransactionType.expense) {
        _totalExpense -= deletedTransaction.amount;
      }
      _availableBalance = _totalIncome - _totalExpense;

      _transactions.removeWhere((t) => t.id == id);

      // Cancel notifications if it was a recurring transaction and notification service is available
      if (deletedTransaction.isRecurring && _notificationService != null) {
        try {
          await _notificationService!.cancelRecurringNotifications(id);
        } catch (notificationError) {
          print('Error cancelling notifications: $notificationError');
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, double>> getCategoryTotals({
    required DateTime startDate,
    required DateTime endDate,
    required TransactionType type,
  }) async {
    if (currentUserId == null) return {};

    try {
      return await _repository.getCategoryTotals(
        userId: currentUserId!,
        startDate: startDate,
        endDate: endDate,
        type: type,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }

  void _setLoading(bool value) {
    print('[TransactionViewModel] _setLoading: value=\\$value');
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    print('[TransactionViewModel] clearError called');
    _error = null;
    notifyListeners();
  }

  double getTotalByType(TransactionType type, DateTime start, DateTime end) {
    return _transactions
        .where((t) =>
            t.type == type && t.date.isAfter(start) && t.date.isBefore(end))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalByTypeAndCategory(
    TransactionType type,
    String category,
    DateTime startDate,
    DateTime endDate,
  ) {
    return transactions
        .where((t) =>
            t.type == type &&
            t.category == category &&
            t.date.isAfter(startDate) &&
            t.date.isBefore(endDate))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<TransactionModel> getTransactionsInRange(
      DateTime startDate, DateTime endDate) {
    return transactions.where((transaction) {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end =
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      return transaction.date
              .isAfter(start.subtract(const Duration(seconds: 1))) &&
          transaction.date.isBefore(end.add(const Duration(seconds: 1)));
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<TransactionModel> getTransactionsByTypeInRange(
    TransactionType type,
    DateTime startDate,
    DateTime endDate,
  ) {
    return getTransactionsInRange(startDate, endDate)
        .where((t) => t.type == type)
        .toList();
  }

  double getTotalByTypeInRange(
    TransactionType type,
    DateTime startDate,
    DateTime endDate,
  ) {
    return getTransactionsByTypeInRange(type, startDate, endDate)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  Map<String, List<TransactionModel>> getTransactionsByCategoryInRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final transactionsInRange = getTransactionsInRange(startDate, endDate);
    return groupBy(transactionsInRange, (TransactionModel t) => t.category);
  }

  Map<String, double> getTotalByCategoryInRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final groupedTransactions =
        getTransactionsByCategoryInRange(startDate, endDate);
    return groupedTransactions.map(
      (category, transactions) => MapEntry(
        category,
        transactions.fold(0.0, (sum, t) => sum + t.amount),
      ),
    );
  }

  Future<bool> processRecurringTransaction(
      TransactionModel recurringTransaction) async {
    if (!recurringTransaction.isRecurring) return false;

    try {
      final newTransaction = recurringTransaction.copyWith(
        id: null,
        date: DateTime.now(),
        isRecurring: false,
        recurringFrequency: null,
      );

      final success = await addTransaction(newTransaction);

      if (success && _notificationService != null) {
        try {
          await _notificationService!
              .sendRecurringTransactionProcessedNotification(newTransaction);
        } catch (notificationError) {
          print('Error sending processed notification: $notificationError');
        }
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> getNotificationStats() async {
    if (_notificationService == null) {
      return {
        'pendingNotifications': 0,
        'recurringTransactions': 0,
        'scheduledReminders': 0,
        'scheduledProcessing': 0,
      };
    }

    try {
      final pendingNotifications =
          await _notificationService!.getPendingNotifications();
      final recurringTransactions = await getRecurringTransactions();

      return {
        'pendingNotifications': pendingNotifications.length,
        'recurringTransactions': recurringTransactions.length,
        'scheduledReminders': pendingNotifications
            .where((n) => n['payload']?.contains('recurring_reminder') ?? false)
            .length,
        'scheduledProcessing': pendingNotifications
            .where(
                (n) => n['payload']?.contains('recurring_processed') ?? false)
            .length,
      };
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {
        'pendingNotifications': 0,
        'recurringTransactions': 0,
        'scheduledReminders': 0,
        'scheduledProcessing': 0,
      };
    }
  }

  Future<void> checkAndProcessDueTransactions() async {
    if (_notificationService != null) {
      try {
        await _notificationService!.checkAndProcessDueTransactions();
      } catch (e) {
        print('Error checking and processing due transactions: $e');
      }
    }
  }

  Future<void> refreshTransactions() async {
    await loadTransactionsForMonth(_selectedMonth);
  }

  @override
  void dispose() {
    _disposed = true;
    // Cancel all recurring notifications when view model is disposed
    if (_notificationService != null) {
      try {
        _notificationService!.cancelAllRecurringNotifications();
      } catch (e) {
        print('Error cancelling notifications during dispose: $e');
      }
    }
    super.dispose();
  }
}