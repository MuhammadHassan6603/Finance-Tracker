import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/credit_card_statement_model.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/credit_card_statement_repository.dart';
import '../data/models/account_card_model.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class CreditCardStatementViewModel extends ChangeNotifier {
  final CreditCardStatementRepository _repo = CreditCardStatementRepository();

  List<CreditCardStatementModel> _statements = [];
  bool isLoading = false;
  String? error;

  List<CreditCardStatementModel> get statements => _statements;

  Future<void> fetchStatements(String cardId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      print('Fetching statements for card: $cardId');
      _statements = await _repo.getStatementsForCard(cardId);
      print('Found ${_statements.length} statements for card: $cardId');
      for (final statement in _statements) {
        print('Statement: ${statement.id} - Period: ${statement.periodStart} to ${statement.periodEnd}');
      }
    } catch (e) {
      print('Error fetching statements for card $cardId: $e');
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<CreditCardStatementModel?> getCurrentStatement(String cardId) async {
    return await _repo.getCurrentStatementForCard(cardId);
  }

  Future<void> addOrUpdateStatement(CreditCardStatementModel statement) async {
    try {
      print('Adding/updating statement for card ${statement.cardId}');
      print('Statement details - Transactions: ${statement.transactions.length}, Repayments: ${statement.repayments.length}, Closing Balance: ${statement.closingBalance}');
      
      await _repo.createStatement(statement);
      await fetchStatements(statement.cardId);
      print('Successfully saved statement');
    } catch (e) {
      print('Error adding/updating statement: $e');
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> closeAndGenerateNewStatement({
    required String cardId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required List<TransactionModel> transactions,
    required List<TransactionModel> repayments,
    required double interestCharged,
    required double openingBalance,
    required double closingBalance,
  }) async {
    try {
      print('Creating new statement for card $cardId');
      print('Period: $periodStart to $periodEnd');
      print('Transactions: ${transactions.length}, Repayments: ${repayments.length}');
      print('Opening Balance: $openingBalance, Closing Balance: $closingBalance');
      
      final statement = CreditCardStatementModel(
        id: const Uuid().v4(),
        cardId: cardId,
        periodStart: periodStart,
        periodEnd: periodEnd,
        transactions: transactions,
        repayments: repayments,
        interestCharged: interestCharged,
        openingBalance: openingBalance,
        closingBalance: closingBalance,
        generatedAt: DateTime.now(),
      );
      await addOrUpdateStatement(statement);
      print('Successfully created statement');
    } catch (e) {
      print('Error creating statement: $e');
      error = e.toString();
      notifyListeners();
    }
  }

  /// Helper: Given a card and a date, return the statement period (start, end) that contains the date
  Map<String, DateTime> getStatementPeriodForDate(AccountCardModel card, DateTime date) {
    assert(card.firstStatementDate != null && card.statementDayOfMonth != null);
    DateTime periodStart = card.createdAt;
    DateTime periodEnd = card.firstStatementDate!;
    if (date.isBefore(periodEnd)) {
      return {'start': periodStart, 'end': periodEnd};
    }
    // For subsequent periods
    periodStart = periodEnd;
    while (true) {
      // Next period end is the next occurrence of statementDayOfMonth after periodStart
      DateTime nextEnd = _nextStatementDate(periodStart, card.statementDayOfMonth!);
      if (!date.isAfter(nextEnd)) {
        return {'start': periodStart, 'end': nextEnd};
      }
      periodStart = nextEnd;
    }
  }

  /// Helper: Given a start date and day-of-month, get the next statement date
  DateTime _nextStatementDate(DateTime after, int dayOfMonth) {
    int year = after.year;
    int month = after.month;
    // If after.day >= dayOfMonth, go to next month
    if (after.day >= dayOfMonth) {
      month += 1;
      if (month > 12) {
        month = 1;
        year += 1;
      }
    }
    // Clamp dayOfMonth to last day of month
    int lastDay = DateTime(year, month + 1, 0).day;
    int day = dayOfMonth > lastDay ? lastDay : dayOfMonth;
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Create initial statement for a card using correct period
  Future<void> createInitialStatementForCard(AccountCardModel card, double initialBalance) async {
    try {
      print('Creating initial statement for card ${card.id} with balance $initialBalance');
      final existingStatements = await _repo.getStatementsForCard(card.id);
      if (existingStatements.isEmpty) {
        final periodStart = card.createdAt;
        final periodEnd = card.firstStatementDate!;
        await closeAndGenerateNewStatement(
          cardId: card.id,
          periodStart: periodStart,
          periodEnd: periodEnd,
          transactions: [],
          repayments: [],
          interestCharged: 0.0,
          openingBalance: initialBalance,
          closingBalance: initialBalance,
        );
        print('Created initial statement for card ${card.id}');
      } else {
        print('Statement already exists for card ${card.id}');
      }
    } catch (e) {
      print('Error creating initial statement for card ${card.id}: $e');
    }
  }

  /// Call this on app open or transaction to ensure statements are up to date
  Future<void> checkAndCloseStatementsForCards(List<AccountCardModel> cards, List<TransactionModel> allTransactions) async {
    for (final card in cards.where((c) => c.type == 'Credit Card')) {
      try {
        // First, ensure there's an initial statement
        await createInitialStatementForCard(card, card.balance);
        final statements = await _repo.getStatementsForCard(card.id);
        if (statements.isEmpty) continue;
        // Sort by periodStart ascending
        statements.sort((a, b) => a.periodStart.compareTo(b.periodStart));
        DateTime now = DateTime.now();
        // Find the last statement
        CreditCardStatementModel lastStatement = statements.last;
        // If now is after last statement's periodEnd, generate new statements forward
        while (now.isAfter(lastStatement.periodEnd)) {
          // Gather transactions for the last statement period
          final periodTransactions = allTransactions.where((t) =>
            t.paymentMethod == card.name &&
            !t.date.isBefore(lastStatement.periodStart) &&
            t.date.isBefore(lastStatement.periodEnd) &&
            t.type == TransactionType.expense
          ).toList();
          final periodRepayments = allTransactions.where((t) =>
            t.paymentMethod == card.name &&
            !t.date.isBefore(lastStatement.periodStart) &&
            t.date.isBefore(lastStatement.periodEnd) &&
            t.type == TransactionType.income &&
            t.description.toLowerCase().contains('repay')
          ).toList();
          final spent = periodTransactions.fold(0.0, (sum, t) => sum + t.amount);
          final repaid = periodRepayments.fold(0.0, (sum, t) => sum + t.amount);
          double interest = 0.0;
          if (repaid < spent) {
            interest = 0.1 * (spent - repaid);
          }
          // Close last statement
          await closeAndGenerateNewStatement(
            cardId: card.id,
            periodStart: lastStatement.periodStart,
            periodEnd: lastStatement.periodEnd,
            transactions: periodTransactions,
            repayments: periodRepayments,
            interestCharged: interest,
            openingBalance: lastStatement.openingBalance,
            closingBalance: spent - repaid + interest,
          );
          // Start new statement
          final newPeriodStart = lastStatement.periodEnd;
          final newPeriodEnd = _nextStatementDate(newPeriodStart, card.statementDayOfMonth!);
          lastStatement = CreditCardStatementModel(
            id: const Uuid().v4(),
            cardId: card.id,
            periodStart: newPeriodStart,
            periodEnd: newPeriodEnd,
            transactions: [],
            repayments: [],
            interestCharged: 0.0,
            openingBalance: spent - repaid + interest,
            closingBalance: spent - repaid + interest,
            generatedAt: DateTime.now(),
          );
          await addOrUpdateStatement(lastStatement);
        }
      } catch (e) {
        print('Error processing statement for card ${card.name}: $e');
      }
    }
  }

  /// Assign a transaction to the correct statement period
  Future<void> updateStatementForTransaction(TransactionModel transaction, AccountCardModel card) async {
    try {
      final statements = await _repo.getStatementsForCard(card.id);
      // Find the statement whose period contains the transaction date
      CreditCardStatementModel? targetStatement = statements.firstWhereOrNull((s) =>
        !transaction.date.isBefore(s.periodStart) && transaction.date.isBefore(s.periodEnd)
      );
      // If not found, generate statements forward until the transaction fits
      if (targetStatement == null) {
        // Start from last statement
        statements.sort((a, b) => a.periodStart.compareTo(b.periodStart));
        CreditCardStatementModel last = statements.last;
        while (transaction.date.isAfter(last.periodEnd)) {
          final newPeriodStart = last.periodEnd;
          final newPeriodEnd = _nextStatementDate(newPeriodStart, card.statementDayOfMonth!);
          last = CreditCardStatementModel(
            id: const Uuid().v4(),
            cardId: card.id,
            periodStart: newPeriodStart,
            periodEnd: newPeriodEnd,
            transactions: [],
            repayments: [],
            interestCharged: 0.0,
            openingBalance: last.closingBalance,
            closingBalance: last.closingBalance,
            generatedAt: DateTime.now(),
          );
          await addOrUpdateStatement(last);
        }
        targetStatement = last;
      }
      // Add transaction to the correct list
      final isRepayment = transaction.type == TransactionType.income && transaction.description.toLowerCase().contains('repay');
      final updatedTransactions = List<TransactionModel>.from(targetStatement.transactions);
      final updatedRepayments = List<TransactionModel>.from(targetStatement.repayments);
      double closingBalance = targetStatement.closingBalance;
      if (isRepayment) {
        updatedRepayments.add(transaction);
        closingBalance -= transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        updatedTransactions.add(transaction);
        closingBalance += transaction.amount;
      }
      await addOrUpdateStatement(targetStatement.copyWith(
        transactions: updatedTransactions,
        repayments: updatedRepayments,
        closingBalance: closingBalance,
      ));
    } catch (e) {
      print('Error updating statement for transaction: $e');
    }
  }
} 