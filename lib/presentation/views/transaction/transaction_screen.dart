import 'package:finance_tracker/presentation/views/transaction/widgets/report_transaction_tab.dart';
import 'package:finance_tracker/presentation/views/transaction/widgets/settle_up_view_tab.dart';
import 'package:finance_tracker/presentation/views/transaction/widgets/transaction_monthly_selector.dart';
import 'package:finance_tracker/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/theme_constants.dart';
import '../../../generated/l10n.dart';
import '../../../viewmodels/transaction_viewmodel.dart';
import '../../../widgets/summary_card_widget.dart';
import 'widgets/transactions_tab.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

// Change the enum definition to be outside the state class
enum FilterOption { categories, dates, amounts }

class _TransactionScreenState extends State<TransactionScreen> {
  DateTime _focusedDay = DateTime.now();
  int _selectedTabIndex = 0;
  late List<String> _tabs;
  bool _didLoadInitial = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabs = [
      AppLocalizations.of(context).transactionsTitle,
      AppLocalizations.of(context).report,
      AppLocalizations.of(context).settleUp,
    ];
    if (!_didLoadInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TransactionViewModel>().setSelectedMonth(_focusedDay);
      });
      _didLoadInitial = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Month Selector
            TransactionMonthSelector(
              focusedDay: _focusedDay,
              onMonthChanged: (newDate) async {
                setState(() => _focusedDay = newDate);
                // FIXED: Now properly awaits the Future
                await context.read<TransactionViewModel>().setSelectedMonth(newDate);
              },
            ),

            // Summary Cards
            Consumer<TransactionViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading && viewModel.transactions.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: CustomLoadingOverlay(),
                    ),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: SummaryCardWidget(
                              title: localization.incomeLabel,
                              amount: viewModel.totalIncome.toString(),
                              textColor: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SummaryCardWidget(
                              title: localization.expenseLabel,
                              amount: viewModel.totalExpense.toString(),
                              textColor: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SummaryCardWidget(
                              title: localization.available,
                              amount: viewModel.availableBalance.toString(),
                              textColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),

            // Tab Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: _tabs.asMap().entries.map((entry) {
                  final isSelected = _selectedTabIndex == entry.key;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _selectedTabIndex = entry.key;
                          });
                          // Refresh data when tab changes
                          await context.read<TransactionViewModel>().refreshCurrentMonth();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).brightness == Brightness.dark
                                  ? ThemeConstants.surfaceDark
                                  : Colors.white,
                          foregroundColor: isSelected
                              ? Colors.white
                              : Theme.of(context).brightness == Brightness.dark
                                  ? ThemeConstants.textPrimaryDark
                                  : ThemeConstants.textPrimaryLight,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                            ),
                          ),
                        ),
                        child: Text(
                          entry.value,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? ThemeConstants.textPrimaryDark
                                            : ThemeConstants.textPrimaryLight,
                                  ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Tab Content
            Expanded(
              child: _selectedTabIndex == 0
                  ? const TransactionsTab()
                  : _selectedTabIndex == 1
                      ? const ReportTransactionTab()
                      : const SettleUpViewTab(),
            ),
          ],
        ),
      ),
    );
  }
}