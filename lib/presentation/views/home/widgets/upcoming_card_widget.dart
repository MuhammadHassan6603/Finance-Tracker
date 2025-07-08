import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../viewmodels/asset_liability_viewmodel.dart';
import '../../../../viewmodels/account_card_viewmodel.dart';
import '../../../../viewmodels/credit_card_statement_viewmodel.dart';
import '../../../../core/utils/helpers.dart';

class UpcomingPaymentsCard extends StatelessWidget {
  const UpcomingPaymentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final vm = context.watch<AssetLiabilityViewModel>();
    final accountCardVM = context.watch<AccountCardViewModel>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<_PaymentItemData>>(
      future: _getAllUpcomingPayments(context, vm, accountCardVM),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(
              color: isDarkMode ? ThemeConstants.cardDark : Colors.white,
              border: Border.all(
                color: isDarkMode ? Colors.grey[800]! : Colors.black12,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final upcomingPayments = snapshot.data ?? [];
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
                            textColor: payment.type == 'Statement Cycle Ends' 
                                ? Colors.orange 
                                : ThemeConstants.negativeColor,
                            daysLeft: payment.daysLeft,
                          ),
                          const SizedBox(height: 12),
                        ],
                      )),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<_PaymentItemData>> _getAllUpcomingPayments(
    BuildContext context,
    AssetLiabilityViewModel vm,
    AccountCardViewModel accountCardVM,
  ) async {
    // Get regular upcoming payments from liabilities (without due date details)
    final regularPayments = vm.liabilities
        .where((l) => l.isActive && l.type != 'Credit Card') // Exclude credit card liabilities
        .map((l) => _PaymentItemData(
              date: l.nextPaymentDate,
              title: l.name,
              amount: l.amount, // Use the actual amount instead of monthlyPayment
              type: l.type,
              dueDate: null, // No due date for regular payments
              daysLeft: null, // No days remaining for regular payments
            ))
        .toList();

    // Get credit card statement due dates (with detailed due date info)
    final creditCardPayments = await _getCreditCardStatementDueDates(context, accountCardVM, vm);
    
    // Combine both types of payments
    final upcomingPayments = [...regularPayments, ...creditCardPayments];

    // Sort by date
    upcomingPayments.sort((a, b) => a.date.compareTo(b.date));
    
    return upcomingPayments;
  }

    Future<List<_PaymentItemData>> _getCreditCardStatementDueDates(
    BuildContext context,
    AccountCardViewModel accountCardVM,
    AssetLiabilityViewModel assetLiabilityVM,
  ) async {
    final List<_PaymentItemData> creditCardPayments = [];
    final statementVM = CreditCardStatementViewModel();
    
    // Get all credit cards
    final creditCards = accountCardVM.accountCards.where((card) => card.type == 'Credit Card').toList();
    
    for (final card in creditCards) {
      try {
        // Get the actual credit card liability for this card
        final cardLiabilities = assetLiabilityVM.liabilities
            .where((l) => l.type == 'Credit Card' && l.cardId == card.id && l.isActive)
            .toList();
        
        // Calculate total outstanding amount for this card
        final totalOutstanding = cardLiabilities.fold(0.0, (sum, l) => sum + l.amount);
        
        // Only show if there's an outstanding amount
        if (totalOutstanding > 0) {
          final currentStatement = await statementVM.getCurrentStatement(card.id);
          if (currentStatement != null) {
            final now = DateTime.now();
            final dueDate = currentStatement.periodEnd;
            
            // Only show if due date is in the future
            if (dueDate.isAfter(now)) {
              final daysLeft = dueDate.difference(now).inDays;
              
              // Show ONE entry per credit card with the actual outstanding amount
              creditCardPayments.add(_PaymentItemData(
                date: dueDate,
                title: '${card.name} Statement Due',
                amount: totalOutstanding,
                type: 'Statement Cycle Ends',
                dueDate: dueDate,
                daysLeft: daysLeft,
              ));
            }
          }
        }
      } catch (e) {
        debugPrint('Error getting statement due date for card ${card.name}: $e');
      }
    }
    
    return creditCardPayments;
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
                            if (payment.daysLeft != null && payment.type == 'Statement Cycle Ends') ...[
                              const SizedBox(height: 4),
                              Text(
                                '${payment.daysLeft} days remaining',
                                style: TextStyle(
                                  color: payment.daysLeft! <= 7 
                                      ? Colors.red 
                                      : payment.daysLeft! <= 14 
                                          ? Colors.orange 
                                          : Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${Helpers.storeCurrency(context)}${payment.amount}',
                            style: TextStyle(
                              color: payment.type == 'Statement Cycle Ends' 
                                  ? Colors.orange 
                                  : ThemeConstants.negativeColor,
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
  final DateTime? dueDate;
  final int? daysLeft;

  _PaymentItemData({
    required this.date,
    required this.title,
    required this.amount,
    required this.type,
    this.dueDate,
    this.daysLeft,
  });
}

class _PaymentItem extends StatelessWidget {
  final String date;
  final String title;
  final String subtitle;
  final String amount;
  final Color textColor;
  final int? daysLeft;

  const _PaymentItem({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.textColor,
    this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode
                      ? ThemeConstants.textPrimaryDark
                      : ThemeConstants.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
              if (daysLeft != null && subtitle == 'Statement Cycle Ends') ...[
                const SizedBox(height: 2),
                Text(
                  '${daysLeft} days remaining',
                  style: TextStyle(
                    color: daysLeft! <= 7 
                        ? Colors.red 
                        : daysLeft! <= 14 
                            ? Colors.orange 
                            : Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              date,
              style: TextStyle(
                color: isDarkMode
                    ? ThemeConstants.textSecondaryDark
                    : ThemeConstants.textSecondaryLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
