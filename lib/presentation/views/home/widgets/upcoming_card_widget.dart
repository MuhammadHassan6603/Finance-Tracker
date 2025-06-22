import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../viewmodels/asset_liability_viewmodel.dart';
import '../../../../core/utils/helpers.dart';

class UpcomingPaymentsCard extends StatelessWidget {
  const UpcomingPaymentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final vm = context.watch<AssetLiabilityViewModel>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Get upcoming payments from liabilities
    final upcomingPayments = vm.liabilities
        .where((l) => l.isActive)
        .map((l) => _PaymentItemData(
              date: l.nextPaymentDate,
              title: l.name,
              amount: l.type == 'Credit Card' ? l.amount : l.monthlyPayment,
              type: l.type,
            ))
        .toList();

    // Sort by date
    upcomingPayments.sort((a, b) => a.date.compareTo(b.date));

    // Take only the next 3 upcoming payments
    final nextPayments = upcomingPayments.take(3).toList();

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
                  localization.upcomingPayments,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? ThemeConstants.textPrimaryDark
                        : ThemeConstants.textPrimaryLight,
                  ),
                ),
                if (upcomingPayments.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllUpcomingPaymentsScreen(
                            payments: upcomingPayments,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      localization.viewAll,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (nextPayments.isEmpty)
              Text(localization.noUpcomingPayments)
            else
              ...nextPayments.map((payment) => Column(
                    children: [
                      _PaymentItem(
                        date: DateFormat('dd MMM y').format(payment.date),
                        title: payment.title,
                        amount:
                            '${Helpers.storeCurrency(context)}${payment.amount}',
                        subtitle: payment.type,
                        textColor: ThemeConstants.negativeColor,
                      ),
                      const SizedBox(height: 12),
                    ],
                  )),
          ],
        ),
      ),
    );
  }
}

class AllUpcomingPaymentsScreen extends StatelessWidget {
  final List<_PaymentItemData> payments;

  const AllUpcomingPaymentsScreen({
    super.key,
    required this.payments,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.upcomingPayments),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isDarkMode ? ThemeConstants.cardDark : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payment.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? ThemeConstants.textPrimaryDark
                                        : ThemeConstants.textPrimaryLight,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              payment.type,
                              style: TextStyle(
                                color: isDarkMode
                                    ? ThemeConstants.textSecondaryDark
                                    : ThemeConstants.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${Helpers.storeCurrency(context)}${payment.amount}',
                            style: TextStyle(
                              color: ThemeConstants.negativeColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM y').format(payment.date),
                            style: TextStyle(
                              color: isDarkMode
                                  ? ThemeConstants.textSecondaryDark
                                  : ThemeConstants.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PaymentItemData {
  final DateTime date;
  final String title;
  final double amount;
  final String type;

  _PaymentItemData({
    required this.date,
    required this.title,
    required this.amount,
    required this.type,
  });
}

class _PaymentItem extends StatelessWidget {
  final String date;
  final String title;
  final String subtitle;
  final String amount;
  final Color textColor;

  const _PaymentItem({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode
                    ? ThemeConstants.textPrimaryDark
                    : ThemeConstants.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isDarkMode
                    ? ThemeConstants.textSecondaryDark
                    : ThemeConstants.textSecondaryLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
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
