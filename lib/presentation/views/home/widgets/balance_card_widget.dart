import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../viewmodels/asset_liability_viewmodel.dart';
import '../../../../core/utils/helpers.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final vm = context.watch<AssetLiabilityViewModel>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Get cash and bank balances from assets
    final cashBalance = vm.assets
        .where((a) => a.type == 'Cash')
        .fold(0.0, (sum, item) => sum + item.amount);

    final bankBalance = vm.assets
        .where((a) => a.type == 'Bank')
        .fold(0.0, (sum, item) => sum + item.amount);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? ThemeConstants.cardDark : Colors.white,
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.black12,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.availableBalance,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? ThemeConstants.textPrimaryDark
                        : ThemeConstants.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BalanceItem(
                  title: localization.cashLabel,
                  amount: '${Helpers.storeCurrency(context)}$cashBalance',
                  textColor: ThemeConstants.primaryColor,
                ),
                _BalanceItem(
                  title: localization.bankLabel,
                  amount: '${Helpers.storeCurrency(context)}$bankBalance',
                  textColor: ThemeConstants.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String title;
  final String amount;
  final Color textColor;

  const _BalanceItem({
    required this.title,
    required this.amount,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDarkMode
                ? ThemeConstants.textSecondaryDark
                : ThemeConstants.textSecondaryLight,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
