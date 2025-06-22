import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/viewmodels/asset_liability_viewmodel.dart';
import 'package:finance_tracker/viewmodels/budget_viewmodel.dart';
import 'package:finance_tracker/viewmodels/transaction_viewmodel.dart';
import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class PastPerformanceScreen extends StatelessWidget {
  const PastPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Scaffold(
      appBar: SharedAppbar(title: local.pastPerformance),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNetWorthSection(context),
            const SizedBox(height: 24),
            _buildBudgetPerformanceSection(context),
            const SizedBox(height: 24),
            _buildTransactionTrendsSection(context),
            const SizedBox(height: 24),
            _buildFinancialHealthSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNetWorthSection(BuildContext context) {
    final assetLiabilityVM = context.watch<AssetLiabilityViewModel>();
    final netWorthHistory = assetLiabilityVM.netWorthHistory;
    final local = AppLocalizations.of(context);
    return _AnalysisCard(
      title: local.netWorthTrend,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: LineChart(
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
                            value.toInt() < netWorthHistory.length) {
                          final date = netWorthHistory[value.toInt()].date;
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
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: netWorthHistory.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.amount);
                    }).toList(),
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildGrowthIndicators(context, assetLiabilityVM),
        ],
      ),
    );
  }

  Widget _buildGrowthIndicators(
      BuildContext context, AssetLiabilityViewModel vm) {
    final local = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _GrowthIndicator(
          label: local.oneMonthGrowth,
          percentage: vm.oneMonthGrowth,
        ),
        _GrowthIndicator(
          label: local.sixMonthGrowth,
          percentage: vm.sixMonthGrowth,
        ),
        _GrowthIndicator(
          label: local.oneYearGrowth,
          percentage: vm.oneYearGrowth,
        ),
      ],
    );
  }

  Widget _buildBudgetPerformanceSection(BuildContext context) {
    final budgetVM = context.watch<BudgetViewModel>();
    final budgets = budgetVM.filteredBudgets;
    final local = AppLocalizations.of(context);
    return _AnalysisCard(
      title: local.budgetPerformance,
      child: Column(
        children: [
          for (final budget in budgets)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(budget.category),
                      Text(
                        '${(budget.spent / budget.amount * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: budget.spent > budget.amount
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: budget.spent / budget.amount,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budget.spent > budget.amount ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionTrendsSection(BuildContext context) {
    final transactionVM = context.watch<TransactionViewModel>();
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 6, 1);
    final local = AppLocalizations.of(context);

    return _AnalysisCard(
      title: local.incomeVsExpensesSixMonths,
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxAmount(transactionVM, sixMonthsAgo, now),
            barGroups: _generateBarGroups(transactionVM, sixMonthsAgo, now),
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
                    final month =
                        DateTime(now.year, now.month - (5 - value.toInt()));
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${month.month}/${month.year.toString().substring(2)}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxAmount(TransactionViewModel vm, DateTime start, DateTime end) {
    double maxIncome = 0;
    double maxExpense = 0;

    for (int i = 0; i < 6; i++) {
      final monthStart = DateTime(end.year, end.month - i, 1);
      final monthEnd = DateTime(end.year, end.month - i + 1, 0);

      final income =
          vm.getTotalByType(TransactionType.income, monthStart, monthEnd);
      final expense =
          vm.getTotalByType(TransactionType.expense, monthStart, monthEnd);

      maxIncome = maxIncome > income ? maxIncome : income;
      maxExpense = maxExpense > expense ? maxExpense : expense;
    }

    return (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.2;
  }

  List<BarChartGroupData> _generateBarGroups(
    TransactionViewModel vm,
    DateTime start,
    DateTime end,
  ) {
    final groups = <BarChartGroupData>[];

    for (int i = 0; i < 6; i++) {
      final monthStart = DateTime(end.year, end.month - i, 1);
      final monthEnd = DateTime(end.year, end.month - i + 1, 0);

      final income =
          vm.getTotalByType(TransactionType.income, monthStart, monthEnd);
      final expense =
          vm.getTotalByType(TransactionType.expense, monthStart, monthEnd);

      groups.add(BarChartGroupData(
        x: 5 - i,
        barRods: [
          BarChartRodData(
            toY: income,
            color: Colors.green,
            width: 12,
          ),
          BarChartRodData(
            toY: expense,
            color: Colors.red,
            width: 12,
          ),
        ],
      ));
    }

    return groups;
  }

  Widget _buildFinancialHealthSection(BuildContext context) {
    final assetLiabilityVM = context.watch<AssetLiabilityViewModel>();
    final local = AppLocalizations.of(context);

    return _AnalysisCard(
      title: local.financialHealthIndicators,
      child: Column(
        children: [
          _HealthIndicator(
            label: local.overallHealthScore,
            value: assetLiabilityVM.financialHealthScore * 100,
            status: assetLiabilityVM.financialHealthStatus,
            color: assetLiabilityVM.healthColor,
          ),
          const SizedBox(height: 16),
          _HealthIndicator(
            label: local.debtToAssetRatio,
            value: assetLiabilityVM.debtToAssetRatio * 100,
            status: assetLiabilityVM.debtToAssetRatio < 0.5
                ? local.good
                : local.needsAttention,
            color: assetLiabilityVM.debtToAssetRatio < 0.5
                ? Colors.green
                : Colors.orange,
          ),
          const SizedBox(height: 16),
          _HealthIndicator(
            label: local.investmentRate,
            value: assetLiabilityVM.investmentRate * 100,
            status: assetLiabilityVM.investmentRate > 0.2
                ? local.good
                : local.couldImprove,
            color: assetLiabilityVM.investmentRate > 0.2
                ? Colors.green
                : Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _AnalysisCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _GrowthIndicator extends StatelessWidget {
  final String label;
  final double percentage;

  const _GrowthIndicator({
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            color: percentage >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _HealthIndicator extends StatelessWidget {
  final String label;
  final double value;
  final String status;
  final Color color;

  const _HealthIndicator({
    required this.label,
    required this.value,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
