import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../viewmodels/asset_liability_viewmodel.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({super.key});

  double _calculateYearlyGrowth(List<NetWorthHistory> history) {
    if (history.length < 2) return 0.0;
    final current = history.last.amount;
    final previous = history.first.amount;
    if (previous == 0) return 0.0;
    return ((current - previous) / previous.abs()) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final vm = context.watch<AssetLiabilityViewModel>();
    final growth = _calculateYearlyGrowth(vm.netWorthHistory);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? Colors.white.withOpacity(0.15)
        : Colors.white.withOpacity(0.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.yearlyGrowth,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${growth.toStringAsFixed(1)}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localization.vsLastYear,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: growth.abs() / 100,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              growth >= 0 ? Colors.greenAccent : Colors.redAccent,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
