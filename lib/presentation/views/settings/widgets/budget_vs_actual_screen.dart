import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/viewmodels/budget_viewmodel.dart';
import 'package:finance_tracker/viewmodels/transaction_viewmodel.dart';
import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:collection/collection.dart';

class BudgetVsActualScreen extends StatefulWidget {
  const BudgetVsActualScreen({super.key});

  @override
  State<BudgetVsActualScreen> createState() => _BudgetVsActualScreenState();
}

class _BudgetVsActualScreenState extends State<BudgetVsActualScreen> {
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
    return Scaffold(
      appBar: SharedAppbar(title: AppLocalizations.of(context).budgetVsActual),
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
        children: [
          Text(
            AppLocalizations.of(context).budgetPerformance,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(16),
          _buildPeriodSelector(),
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

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOverallSummary(),
          const SizedBox(height: 24),
          _buildCategoryComparison(),
          // const SizedBox(height: 24),
          // _buildMonthlyTrend(),
        ],
      ),
    );
  }

  Widget _buildOverallSummary() {
    return Consumer2<BudgetViewModel, TransactionViewModel>(
      builder: (context, budgetVM, transactionVM, _) {
        final totalBudget = budgetVM.getTotalBudget();
        final totalExpenses = transactionVM.getTotalByType(
          TransactionType.expense,
          _startDate,
          DateTime.now(),
        );
        final variance = totalBudget - totalExpenses;
        final percentage =
            totalBudget > 0 ? (totalExpenses / totalBudget) * 100 : 0;
        final local = AppLocalizations.of(context);
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
                      Icons.analytics,
                      color: Theme.of(context).primaryColor,
                    ),
                    const Gap(8),
                    Text(
                      local.overallPerformance,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const Gap(24),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        local.totalBudget,
                        totalBudget,
                        Icons.account_balance_wallet,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        local.actualExpenses,
                        totalExpenses,
                        Icons.money_off,
                        Colors.red,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        local.variance,
                        variance,
                        Icons.compare_arrows,
                        variance >= 0 ? Colors.green : Colors.red,
                        showSign: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProgressIndicator(percentage.toDouble()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(
    String title,
    double amount,
    IconData icon,
    Color color, {
    bool showSign = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const Gap(8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const Gap(8),
        Text(
          showSign && amount >= 0
              ? '+${Helpers.storeCurrency(context)}$amount'
              : '${Helpers.storeCurrency(context)}$amount',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(double percentage) {
    final color = percentage <= 100 ? Colors.green : Colors.red;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).budgetUtilization,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (percentage / 100).clamp(0.0, 1.0),
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildCategoryComparison() {
    return Consumer2<BudgetViewModel, TransactionViewModel>(
      builder: (context, budgetVM, transactionVM, _) {
        final categories = budgetVM.getBudgetCategories();

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
                      Icons.category,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).categoryBreakdown,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...categories.map((category) {
                  final budget = budgetVM.getBudgetForCategory(category);
                  final actual = transactionVM.getTotalByTypeAndCategory(
                    TransactionType.expense,
                    category,
                    _startDate,
                    DateTime.now(),
                  );
                  final percentage = budget > 0 ? (actual / budget) * 100 : 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildCategoryItem(
                      category,
                      budget,
                      actual,
                      percentage.toDouble(),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(
    String category,
    double budget,
    double actual,
    double percentage,
  ) {
    final color = percentage <= 100 ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                '${AppLocalizations.of(context).budgetTitle}: ${Helpers.storeCurrency(context)}$budget',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Expanded(
              child: Text(
                '${AppLocalizations.of(context).actual}: ${Helpers.storeCurrency(context)}$actual',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (percentage / 100).clamp(0.0, 1.0),
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildTrendChart() {
    return Consumer2<BudgetViewModel, TransactionViewModel>(
      builder: (context, budgetVM, transactionVM, _) {
        final monthlyData = <DateTime, Map<String, double>>{};
        var currentDate = _startDate;
        final endDate = DateTime.now();

        while (currentDate.isBefore(endDate)) {
          final monthEnd = DateTime(currentDate.year, currentDate.month + 1, 0);

          final budget = budgetVM.getTotalBudget();
          final actual = transactionVM.getTotalByType(
            TransactionType.expense,
            currentDate,
            monthEnd,
          );

          monthlyData[currentDate] = {
            'budget': budget,
            'actual': actual,
          };

          currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
        }

        final maxAmount = monthlyData.values
                .expand((map) => map.values)
                .reduce((a, b) => a > b ? a : b) *
            1.2;

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
                    if (value.toInt() >= 0 &&
                        value.toInt() < monthlyData.length) {
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
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            minY: 0,
            maxY: maxAmount,
            lineBarsData: [
              _buildLineData(monthlyData, 'budget', Colors.blue),
              _buildLineData(monthlyData, 'actual', Colors.red),
            ],
          ),
        );
      },
    );
  }

  LineChartBarData _buildLineData(
    Map<DateTime, Map<String, double>> data,
    String key,
    Color color,
  ) {
    return LineChartBarData(
      spots: data.entries.mapIndexed((index, entry) {
        return FlSpot(index.toDouble(), entry.value[key] ?? 0);
      }).toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: false),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Budget', Colors.blue),
        const SizedBox(width: 24),
        _buildLegendItem('Actual', Colors.red),
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
}
/*

  Widget _buildMonthlyTrend() {
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
                  'Monthly Trend',
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
            _buildChartLegend(),
          ],
        ),
      ),
    );
  }
 */
