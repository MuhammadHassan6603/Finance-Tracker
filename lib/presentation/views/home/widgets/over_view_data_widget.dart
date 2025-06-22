import 'package:auto_size_text/auto_size_text.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../viewmodels/transaction_viewmodel.dart';
import '../../../../widgets/donut_card_widget.dart';
import '../../../../core/utils/helpers.dart';

class DataOverViewCard extends StatefulWidget {
  const DataOverViewCard({super.key});

  @override
  State<DataOverViewCard> createState() => _DataOverViewCardState();
}

class _DataOverViewCardState extends State<DataOverViewCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  void _loadTransactions() {
    final viewModel = context.read<TransactionViewModel>();
    if (!viewModel.isLoading) {
      viewModel.loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final vm = context.watch<TransactionViewModel>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Get last 30 days totals
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));

    final income =
        vm.getTotalByType(TransactionType.income, startDate, endDate);
    final expense =
        vm.getTotalByType(TransactionType.expense, startDate, endDate);
    final savings = income - expense;

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
                  localization.last30Days,
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
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: DonutChartWidget(
                    income: income,
                    expense: expense,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _SummaryItem(
                        label: localization.incomeLabel,
                        amount: '$income',
                        textColor: ThemeConstants.positiveColor,
                      ),
                      const SizedBox(height: 8),
                      _SummaryItem(
                        label: localization.expenseLabel,
                        amount: '$expense',
                        textColor: ThemeConstants.negativeColor,
                      ),
                      const SizedBox(height: 8),
                      _SummaryItem(
                        label: localization.savingsLabel,
                        amount: '$savings',
                        textColor: savings >= 0
                            ? ThemeConstants.positiveColor
                            : ThemeConstants.negativeColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color textColor;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode
                ? ThemeConstants.textPrimaryDark
                : ThemeConstants.textPrimaryLight,
          ),
        ),
        AutoSizeText(
          '${Helpers.storeCurrency(context)}$amount',
          maxLines: 1,
          minFontSize: 10,
          maxFontSize: 14,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
