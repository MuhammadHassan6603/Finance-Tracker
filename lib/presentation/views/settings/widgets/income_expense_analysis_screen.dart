import 'dart:math';

import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/viewmodels/transaction_viewmodel.dart';
import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';

class IncomeExpenseAnalysisScreen extends StatefulWidget {
  const IncomeExpenseAnalysisScreen({super.key});

  @override
  State<IncomeExpenseAnalysisScreen> createState() =>
      _IncomeExpenseAnalysisScreenState();
}

class _IncomeExpenseAnalysisScreenState
    extends State<IncomeExpenseAnalysisScreen> {
  String _selectedPeriod = '1M';
  final List<String> _periods = ['1M', '3M', '6M', '1Y'];

  DateTime get _startDate {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case '3M':
        return DateTime(now.year, now.month - 3, 1);
      case '6M':
        return DateTime(now.year, now.month - 6, 1);
      case '1Y':
        return DateTime(now.year - 1, now.month, 1);
      default:
        return DateTime(now.year, now.month - 1, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Scaffold(
      appBar: SharedAppbar(title: local.incomeAndExpenseAnalysis),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final local = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            local.financialOverview,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(16),
          _buildPeriodSelector(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const Gap(24),
          // _buildCategorySection(),
          // const Gap( 24),
          // _buildTrendSection(),
          // const Gap(24),
          _buildSavingsSection(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
              ),
              onSelected: (selected) {
                if (selected) setState(() => _selectedPeriod = period);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Income', Colors.green),
        const SizedBox(width: 24),
        _buildLegendItem('Expenses', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildSavingsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.savings,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).savingsAnalysis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSavingsAnalysis(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final transactionVM = context.watch<TransactionViewModel>();
    final endDate = DateTime.now();

    final totalIncome = transactionVM.getTotalByType(
      TransactionType.income,
      _startDate,
      endDate,
    );

    final totalExpense = transactionVM.getTotalByType(
      TransactionType.expense,
      _startDate,
      endDate,
    );

    final savings = totalIncome - totalExpense;
    final savingsRate = totalIncome > 0 ? (savings / totalIncome) * 100 : 0;
    final local = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: local.income,
            amount: totalIncome,
            icon: Icons.arrow_upward,
            color: Colors.green,
            elevation: 2,
          ),
        ),
        const Gap(5),
        Expanded(
          child: _SummaryCard(
            title: local.expense,
            amount: totalExpense,
            icon: Icons.arrow_downward,
            color: Colors.red,
            elevation: 2,
          ),
        ),
        const Gap(5),
        Expanded(
          child: _SummaryCard(
            title: local.savings,
            amount: savings,
            subtitle: '${savingsRate.toStringAsFixed(1)}%',
            icon: Icons.savings,
            color: Colors.blue,
            elevation: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPieChart(TransactionType type) {
    final transactionVM = context.watch<TransactionViewModel>();
    final endDate = DateTime.now();

    // Group transactions by category
    final transactions = transactionVM.transactions
        .where((t) =>
            t.type == type &&
            t.date.isAfter(_startDate) &&
            t.date.isBefore(endDate))
        .groupListsBy((t) => t.category);

    // Calculate total for each category
    final categoryTotals = transactions.map((category, transactions) {
      final total = transactions.fold(0.0, (sum, t) => sum + t.amount);
      return MapEntry(category, total);
    });

    final totalAmount =
        categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    // Convert to list and sort by amount
    final categories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        Text(
          type == TransactionType.income ? 'Income' : 'Expenses',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: PieChart(
            PieChartData(
              sections: categories.map((entry) {
                final percentage =
                    totalAmount > 0 ? (entry.value / totalAmount) * 100 : 0;
                return PieChartSectionData(
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  color: _getCategoryColor(entry.key),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...categories.take(3).map((entry) {
          final percentage =
              totalAmount > 0 ? (entry.value / totalAmount) * 100 : 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: _getCategoryColor(entry.key),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTrendChart() {
    final transactionVM = context.watch<TransactionViewModel>();
    final endDate = DateTime.now();

    // Generate monthly data points
    final monthlyData = <DateTime, Map<TransactionType, double>>{};
    var currentDate = _startDate;

    while (currentDate.isBefore(endDate)) {
      final monthEnd = DateTime(currentDate.year, currentDate.month + 1, 0);

      final income = transactionVM.getTotalByType(
        TransactionType.income,
        currentDate,
        monthEnd,
      );

      final expense = transactionVM.getTotalByType(
        TransactionType.expense,
        currentDate,
        monthEnd,
      );

      monthlyData[currentDate] = {
        TransactionType.income: income,
        TransactionType.expense: expense,
      };

      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    }

    final maxAmount =
        monthlyData.values.expand((map) => map.values).reduce(max) * 1.2;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${Helpers.storeCurrency(context)}$value',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                  final date = monthlyData.keys.elementAt(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.month}/${date.year.toString().substring(2)}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        minY: 0,
        maxY: maxAmount,
        lineBarsData: [
          _buildLineBarsData(monthlyData, TransactionType.income, Colors.green),
          _buildLineBarsData(monthlyData, TransactionType.expense, Colors.red),
        ],
      ),
    );
  }

  LineChartBarData _buildLineBarsData(
    Map<DateTime, Map<TransactionType, double>> data,
    TransactionType type,
    Color color,
  ) {
    return LineChartBarData(
      spots: data.entries.mapIndexed((index, entry) {
        return FlSpot(index.toDouble(), entry.value[type] ?? 0);
      }).toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: false),
    );
  }

  Widget _buildSavingsAnalysis() {
    final transactionVM = context.watch<TransactionViewModel>();
    final endDate = DateTime.now();

    final totalIncome = transactionVM.getTotalByType(
      TransactionType.income,
      _startDate,
      endDate,
    );

    final totalExpense = transactionVM.getTotalByType(
      TransactionType.expense,
      _startDate,
      endDate,
    );

    final savings = totalIncome - totalExpense;
    final savingsRate = totalIncome > 0 ? (savings / totalIncome) * 100 : 0;
    final local = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              local.savingsAnalysis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSavingsIndicator(
              local.savingsRate,
              savingsRate.toDouble(),
              target: 20,
            ),
            const SizedBox(height: 16),
            _buildSavingsIndicator(
              local.expenseRatio,
              totalIncome > 0 ? (totalExpense / totalIncome) * 100 : 0,
              target: 80,
              isLowerBetter: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsIndicator(
    String label,
    double value, {
    required double target,
    bool isLowerBetter = false,
  }) {
    final isGood = isLowerBetter ? value <= target : value >= target;
    final color = isGood ? Colors.green : Colors.orange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Row(
              children: [
                Text(
                  '${value.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  ' / ${target.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    // Generate a color based on the category name
    return Colors.primaries[category.hashCode % Colors.primaries.length];
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final double elevation;

  const _SummaryCard({
    required this.title,
    required this.amount,
    this.subtitle,
    required this.icon,
    required this.color,
    this.elevation = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontSize: 10),
                  ),
                ),
              ],
            ),
            const Gap(8),
            Text(
              '${Helpers.storeCurrency(context)}$amount',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            if (subtitle != null) ...[
              const Gap(4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color, fontWeight: FontWeight.w600, fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/*

  Widget _buildCategorySection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Category Breakdown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 350, // Increased height for better visibility
              child: Row(
                children: [
                  Expanded(
                      child: _buildCategoryPieChart(TransactionType.income)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildCategoryPieChart(TransactionType.expense)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Monthly Trends',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildTrendChart(),
            ),
            const SizedBox(height: 16),
            _buildTrendLegend(),
          ],
        ),
      ),
    );
  }
 */
