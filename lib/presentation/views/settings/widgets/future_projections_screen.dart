import 'dart:math';

import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/viewmodels/projection_viewmodel.dart';
import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class FutureProjectionsScreen extends StatelessWidget {
  const FutureProjectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: SharedAppbar(title: localizations.futureProjections),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(context),
            const SizedBox(height: 24),
            // _buildProjectionChart(context),
            // const SizedBox(height: 24),
            _buildProjectedSavings(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final projectionVM = context.watch<ProjectionViewModel>();
    final now = DateTime.now();
    final sixMonthsAgo = now.subtract(const Duration(days: 180));
    final localizations = AppLocalizations.of(context);
    final avgIncome = projectionVM.getAverageMonthlyIncome(sixMonthsAgo, now);
    final avgExpense = projectionVM.getAverageMonthlyExpense(sixMonthsAgo, now);
    final growthRate = projectionVM.getGrowthRate();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ProjectionCard(
                title: localizations.avgMonthlyIncome,
                amount: avgIncome,
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ProjectionCard(
                title: localizations.avgMonthlyExpense,
                amount: avgExpense,
                icon: Icons.trending_down,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ProjectionCard(
          title: localizations.growthRate,
          subtitle: localizations.sixMonthTrend,
          amount: growthRate,
          isPercentage: true,
          icon: Icons.show_chart,
          color: growthRate >= 0 ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  Widget _buildProjectedSavings(BuildContext context) {
    final projectionVM = context.watch<ProjectionViewModel>();
    final local = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          local.projectedSavings,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _ProjectionSavingsCard(
          months: 3,
          amount: projectionVM.getProjectedSavings(3),
        ),
        const SizedBox(height: 12),
        _ProjectionSavingsCard(
          months: 6,
          amount: projectionVM.getProjectedSavings(6),
        ),
        const SizedBox(height: 12),
        _ProjectionSavingsCard(
          months: 12,
          amount: projectionVM.getProjectedSavings(12),
        ),
      ],
    );
  }
}

class _ProjectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double amount;
  final bool isPercentage;
  final IconData icon;
  final Color color;

  const _ProjectionCard({
    required this.title,
    this.subtitle,
    required this.amount,
    this.isPercentage = false,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style:
                  Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            isPercentage
                ? '${amount.toStringAsFixed(1)}%'
                : '${Helpers.storeCurrency(context)}$amount',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ProjectionSavingsCard extends StatelessWidget {
  final int months;
  final double amount;

  const _ProjectionSavingsCard({
    required this.months,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$months Month${months > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                AppLocalizations.of(context).projectedSavings,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Text(
            '${Helpers.storeCurrency(context)}${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: amount >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/*
  Widget _buildProjectionChart(BuildContext context) {
    final projectionVM = context.watch<ProjectionViewModel>();
    final spots = projectionVM.getProjectionSpots();
    final monthlyData = projectionVM.getMonthlyNetAmounts();

    if (spots.isEmpty) {
      return const Center(
        child: Text('Not enough data for projections'),
      );
    }

    // Validate and filter out any invalid spots
    final validSpots = spots
        .where((spot) =>
            spot.x.isFinite &&
            spot.y.isFinite &&
            !spot.x.isNaN &&
            !spot.y.isNaN)
        .toList();

    if (validSpots.isEmpty) {
      return const Center(
        child: Text('Invalid data for projections'),
      );
    }

    // Calculate valid min/max values
    final yValues = validSpots.map((spot) => spot.y).toList();
    final minY = yValues.reduce(min);
    final maxY = yValues.reduce(max);

    // Add padding to min/max and ensure minimum difference
    final yDifference = maxY - minY;
    final yPadding = yDifference == 0 ? maxY.abs() * 0.1 : yDifference * 0.1;
    final safeMinY = minY - yPadding;
    final safeMaxY = maxY + yPadding;

    // Ensure minimum interval
    final interval = ((safeMaxY - safeMinY) / 5).abs();
    final safeInterval = interval < 1 ? 1.0 : interval;

    final historicalSpots = validSpots.sublist(0, monthlyData.length);
    final projectedSpots = validSpots.sublist(monthlyData.length - 1);

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          barGroups: validSpots.map((spot) {
            final isProjected = spot.x >= monthlyData.length - 1;
            return BarChartGroupData(
              x: spot.x.toInt(),
              barRods: [
                BarChartRodData(
                  toY: spot.y,
                  color: isProjected
                      ? Theme.of(context).primaryColor.withOpacity(0.5)
                      : Theme.of(context).primaryColor,
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  if (!value.isFinite || value.isNaN) return const Text('');

                  final index = value.toInt();
                  if (index >= monthlyData.length) {
                    final projectedMonth = monthlyData.last.date.add(
                      Duration(days: 30 * (index - monthlyData.length + 1)),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${projectedMonth.month}/${projectedMonth.year.toString().substring(2)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  if (index >= 0 && index < monthlyData.length) {
                    final month = monthlyData[index].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${month.month}/${month.year.toString().substring(2)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (safeMaxY - safeMinY) / 5,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  if (!value.isFinite || value.isNaN) return const Text('');
                  return Text(
                    '${Helpers.storeCurrency(context)}$value',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Theme.of(context).cardColor,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final isProjected = group.x >= monthlyData.length - 1;
                return BarTooltipItem(
                  '${isProjected ? "Projected: " : ""}${Helpers.storeCurrency(context)}${rod.toY}',
                  TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectionCharts(BuildContext context) {
    final projectionVM = context.watch<ProjectionViewModel>();
    final spots = projectionVM.getProjectionSpots();
    final monthlyData = projectionVM.getMonthlyNetAmounts();

    if (spots.isEmpty) {
      return const Center(
        child: Text('Not enough data for projections'),
      );
    }

    final historicalSpots = spots.sublist(0, monthlyData.length);
    final projectedSpots = spots.sublist(monthlyData.length - 1);

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1000,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= monthlyData.length) {
                    final projectedMonth = monthlyData.last.date.add(
                      Duration(
                          days: 30 * (value.toInt() - monthlyData.length + 1)),
                    );
                    return Text(
                      '${projectedMonth.month}/${projectedMonth.year.toString().substring(2)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    );
                  }
                  if (value.toInt() < monthlyData.length) {
                    final month = monthlyData[value.toInt()].date;
                    return Text(
                      '${month.month}/${month.year.toString().substring(2)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1000,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${Helpers.storeCurrency(context)}$value',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          minY: projectionVM.getMinY(),
          maxY: projectionVM.getMaxY(),
          lineBarsData: [
            // Historical data line
            LineChartBarData(
              spots: historicalSpots,
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Theme.of(context).primaryColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
            // Projected data line (dashed)
            LineChartBarData(
              spots: projectedSpots,
              isCurved: true,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              dashArray: [5, 5], // Make the projection line dashed
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Theme.of(context).cardColor,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final isProjected = spot.x >= monthlyData.length - 1;
                  return LineTooltipItem(
                    '${isProjected ? "Projected: " : ""}${Helpers.storeCurrency(context)}${spot.y}',
                    TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
 */
