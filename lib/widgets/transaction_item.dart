import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/theme_constants.dart';

class TransactionItem extends StatelessWidget {
  final DateTime date;
  final IconData categoryIcon;
  final String title;
  final String description;
  final double amount;
  final bool isExpense;

  const TransactionItem({
    super.key,
    required this.date,
    required this.categoryIcon,
    required this.title,
    required this.description,
    required this.amount,
    this.isExpense = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDarkMode ? ThemeConstants.surfaceDark : Colors.white,
      child: Row(
        children: [
          // Date Column
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('MMM').format(date).substring(0, 3),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDarkMode
                          ? ThemeConstants.textSecondaryDark
                          : ThemeConstants.textSecondaryLight,
                    ),
              ),
              Text(
                date.day.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? ThemeConstants.textPrimaryDark
                          : ThemeConstants.textPrimaryLight,
                    ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Category Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? ThemeConstants.cardDark : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              categoryIcon,
              color: isDarkMode
                  ? ThemeConstants.textPrimaryDark
                  : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Title and Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? ThemeConstants.textPrimaryDark
                            : ThemeConstants.textPrimaryLight,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? ThemeConstants.textSecondaryDark
                            : ThemeConstants.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '${isExpense ? "-" : "+"} ${Helpers.storeCurrency(context)}${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isExpense
                      ? ThemeConstants.negativeColor
                      : ThemeConstants.positiveColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
