import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/widgets/app_header_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/viewmodels/asset_liability_viewmodel.dart';

class NetWorthDisplay extends StatelessWidget {
  const NetWorthDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Consumer<AssetLiabilityViewModel>(
      builder: (context, viewModel, child) {
        final oneMonth = viewModel.oneMonthGrowth;
        final sixMonth = viewModel.sixMonthGrowth;
        final oneYear = viewModel.oneYearGrowth;
        final netWorth = viewModel.netWorth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(10),
            Wrap(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              runSpacing: 8,
              children: [
                _buildGrowthChip(local.oneMonthGrowth, oneMonth),
                const SizedBox(width: 8),
                _buildGrowthChip(local.sixMonthGrowth, sixMonth),
                const SizedBox(width: 8),
                _buildGrowthChip(local.oneYearGrowth, oneYear),
              ],
            ),
            const Gap(20),
            AppHeaderText(
                text:
                    '${Helpers.storeCurrency(context)}${netWorth.toStringAsFixed(2)}',
                fontSize: 24),
            Divider(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade300,
                indent: 0.5,
                endIndent: 0.5)
          ],
        );
      },
    );
  }

  Widget _buildGrowthChip(String period, double percentage) {
    final color = percentage >= 0 ? Colors.green : Colors.red;
    final symbol = percentage >= 0 ? '↑' : '↓';
    final value = '${percentage.abs().toStringAsFixed(1)}%';

    return Builder(builder: (context) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          '$period $symbol $value',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    });
  }
}
