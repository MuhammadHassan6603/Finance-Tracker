import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/constants/theme_constants.dart';

class DonutChartWidget extends StatelessWidget {
  final double income;
  final double expense;

  const DonutChartWidget({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final total = income + expense;
    final incomePercent = total > 0 ? (income / total) * 100 : 50.0;
    final expensePercent = total > 0 ? (expense / total) * 100 : 50.0;

    return PieChart(
      swapAnimationCurve: Curves.easeInOut,
      swapAnimationDuration: const Duration(milliseconds: 800),
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 30,
        sections: [
          PieChartSectionData(
            value: incomePercent,
            color: ThemeConstants.positiveColor,
            title: '',
            radius: 20,
          ),
          PieChartSectionData(
            value: expensePercent,
            color: ThemeConstants.negativeColor,
            title: '',
            radius: 20,
          ),
        ],
      ),
    );
  }
}
