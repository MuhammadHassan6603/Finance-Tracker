import 'package:finance_tracker/viewmodels/transaction_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'dart:math' show min, max;
import '../data/models/transaction_model.dart';

class ProjectionViewModel extends ChangeNotifier {
  final TransactionViewModel _transactionVM;
  
  ProjectionViewModel({
    required TransactionViewModel transactionVM,
  }) : _transactionVM = transactionVM;

  // Calculate average monthly income
  double getAverageMonthlyIncome(DateTime startDate, DateTime endDate) {
    final transactions = _transactionVM.transactions
        .where((t) => t.type == TransactionType.income &&
            t.date.isAfter(startDate) &&
            t.date.isBefore(endDate))
        .toList();

    if (transactions.isEmpty) return 0;

    final totalIncome = transactions.fold(0.0, (sum, t) => sum + t.amount);
    final months = endDate.difference(startDate).inDays / 30;
    
    return totalIncome / months;
  }

  // Calculate average monthly expense
  double getAverageMonthlyExpense(DateTime startDate, DateTime endDate) {
    final transactions = _transactionVM.transactions
        .where((t) => t.type == TransactionType.expense &&
            t.date.isAfter(startDate) &&
            t.date.isBefore(endDate))
        .toList();

    if (transactions.isEmpty) return 0;

    final totalExpense = transactions.fold(0.0, (sum, t) => sum + t.amount);
    final months = endDate.difference(startDate).inDays / 30;
    
    return totalExpense / months;
  }

  // Calculate projected savings for next n months
  double getProjectedSavings(int months) {
    final now = DateTime.now();
    final sixMonthsAgo = now.subtract(const Duration(days: 180));
    
    final avgMonthlyIncome = getAverageMonthlyIncome(sixMonthsAgo, now);
    final avgMonthlyExpense = getAverageMonthlyExpense(sixMonthsAgo, now);
    
    return (avgMonthlyIncome - avgMonthlyExpense) * months;
  }

  // Get growth rate
  double getGrowthRate() {
    final now = DateTime.now();
    final sixMonthsAgo = now.subtract(const Duration(days: 180));
    
    final oldestTransactions = _transactionVM.transactions
        .where((t) => t.date.isAfter(sixMonthsAgo) &&
            t.date.isBefore(sixMonthsAgo.add(const Duration(days: 30))))
        .toList();

    final latestTransactions = _transactionVM.transactions
        .where((t) => t.date.isAfter(now.subtract(const Duration(days: 30))))
        .toList();

    if (oldestTransactions.isEmpty || latestTransactions.isEmpty) return 0;

    final oldestNet = oldestTransactions.fold(
        0.0,
        (sum, t) => sum +
            (t.type == TransactionType.income ? t.amount : -t.amount));
    final latestNet = latestTransactions.fold(
        0.0,
        (sum, t) => sum +
            (t.type == TransactionType.income ? t.amount : -t.amount));

    if (oldestNet == 0) return 0;
    return ((latestNet - oldestNet) / oldestNet) * 100;
  }

  // Get monthly net amounts for the past year
  List<MonthlyData> getMonthlyNetAmounts() {
    final now = DateTime.now();
    final oneYearAgo = DateTime(now.year - 1, now.month, 1);
    
    // Group transactions by month
    final monthlyTransactions = _transactionVM.transactions
        .where((t) => t.date.isAfter(oneYearAgo))
        .groupListsBy((t) => DateTime(t.date.year, t.date.month));

    // Calculate net amount for each month
    final monthlyData = monthlyTransactions.entries.map((entry) {
      final month = entry.key;
      final transactions = entry.value;
      
      final income = transactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
          
      final expense = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);
          
      return MonthlyData(
        date: month,
        income: income,
        expense: expense,
        netAmount: income - expense,
      );
    }).toList();

    // Sort by date
    monthlyData.sort((a, b) => a.date.compareTo(b.date));
    return monthlyData;
  }

  // Calculate trend line for future projections
  List<FlSpot> getProjectionSpots() {
    final monthlyData = getMonthlyNetAmounts();
    if (monthlyData.isEmpty) return [];

    // Calculate trend using linear regression
    final points = monthlyData.mapIndexed((index, data) {
      return Point(index.toDouble(), data.netAmount);
    }).toList();

    final regression = LinearRegression.compute(points);
    
    // Generate future points using the trend line
    final spots = <FlSpot>[];
    
    // Add historical points with validation
    for (var i = 0; i < monthlyData.length; i++) {
      final amount = monthlyData[i].netAmount;
      if (amount.isFinite && !amount.isNaN) {
        spots.add(FlSpot(i.toDouble(), amount));
      }
    }
    
    // Add projected points with validation
    for (var i = monthlyData.length; i < monthlyData.length + 6; i++) {
      final projectedValue = regression.predict(i.toDouble());
      if (projectedValue.isFinite && !projectedValue.isNaN) {
        spots.add(FlSpot(i.toDouble(), projectedValue));
      }
    }

    return spots;
  }

  // Get min and max values for chart scaling
  double getMinY() {
    final spots = getProjectionSpots();
    if (spots.isEmpty) return 0;
    final minValue = spots.map((s) => s.y).reduce((a, b) => min(a, b));
    // Ensure minimum is not too close to zero
    return minValue > -1 && minValue < 1 ? -1 : minValue * 1.2;
  }

  double getMaxY() {
    final spots = getProjectionSpots();
    if (spots.isEmpty) return 100; // Default value if no data
    final maxValue = spots.map((s) => s.y).reduce((a, b) => max(a, b));
    // Ensure maximum is not too close to zero
    return maxValue > -1 && maxValue < 1 ? 1 : maxValue * 1.2;
  }
}

class MonthlyData {
  final DateTime date;
  final double income;
  final double expense;
  final double netAmount;

  MonthlyData({
    required this.date,
    required this.income,
    required this.expense,
    required this.netAmount,
  });
}

// Simple linear regression implementation
class LinearRegression {
  final double slope;
  final double intercept;

  LinearRegression(this.slope, this.intercept);

  static LinearRegression compute(List<Point> points) {
    if (points.isEmpty) return LinearRegression(0, 0);

    final n = points.length;
    var sumX = 0.0;
    var sumY = 0.0;
    var sumXY = 0.0;
    var sumXX = 0.0;

    for (final point in points) {
      sumX += point.x;
      sumY += point.y;
      sumXY += point.x * point.y;
      sumXX += point.x * point.x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    return LinearRegression(slope, intercept);
  }

  double predict(double x) => slope * x + intercept;
}

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);
} 