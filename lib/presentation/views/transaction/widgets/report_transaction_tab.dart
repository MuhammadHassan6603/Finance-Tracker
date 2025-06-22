import 'package:collection/collection.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/presentation/views/transaction/widgets/report_item_widget.dart';
import 'package:finance_tracker/presentation/views/transaction/widgets/transaction_chart_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../viewmodels/transaction_viewmodel.dart';

class ReportTransactionTab extends StatefulWidget {
  const ReportTransactionTab({super.key});

  @override
  State<ReportTransactionTab> createState() => _ReportTransactionTabState();
}

class _ReportTransactionTabState extends State<ReportTransactionTab> {
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final vm = context.read<TransactionViewModel>();
    // await vm.loadTransactions(
    //   startDate: vm.startDate,
    //   endDate: vm.endDate,
    // );
  }

  List<PieChartSectionData> _buildChartSections(
      Map<String, double> categoryTotals, bool isDarkMode) {
    final colors = _getChartColors(isDarkMode);

    return categoryTotals.entries
        .mapIndexed(
          (index, entry) => PieChartSectionData(
            color: colors[index % colors.length],
            value: entry.value,
            title: '',
            radius: index == _touchedIndex ? 50 : 40,
            titlePositionPercentageOffset: 0.5,
            borderSide: BorderSide(
              color: isDarkMode ? ThemeConstants.surfaceDark : Colors.white,
              width: 2,
            ),
          ),
        )
        .toList();
  }

  List<Color> _getChartColors(bool isDarkMode) => isDarkMode
      ? [
          Colors.blue.shade300,
          Colors.green.shade300,
          Colors.orange.shade300,
          Colors.red.shade300,
          Colors.purple.shade300,
        ]
      : [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.red,
          Colors.purple,
        ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final local = AppLocalizations.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          TransactionChartWidget(
            title: local.spendingByCategory,
            chart: FutureBuilder<Map<String, double>>(
              future: vm.getCategoryTotals(
                startDate: DateTime.now().subtract(const Duration(days: 30)),
                endDate: DateTime.now(),
                type: TransactionType.expense,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('${local.error}: ${snapshot.error}'));
                }

                final categoryTotals = snapshot.data ?? {};

                if (categoryTotals.isEmpty) {
                  return Center(
                    child: Text(
                        textAlign: TextAlign.center,
                        local.noExpenseDataAvailable),
                  );
                }

                return PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          _touchedIndex =
                              response?.touchedSection?.touchedSectionIndex ??
                                  -1;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: _buildChartSections(categoryTotals,
                        Theme.of(context).brightness == Brightness.dark),
                  ),
                );
              },
            ),
          ),
          _buildReportSection(
            title: local.financialSummary,
            child: Column(
              children: [
                ReportItemWidget(
                  label: local.totalIncome,
                  value: vm.totalIncome.toStringAsFixed(2),
                ),
                ReportItemWidget(
                  label: local.totalExpenses,
                  value: vm.totalExpense.toStringAsFixed(2),
                ),
                ReportItemWidget(
                  label: local.netSavings,
                  value: vm.availableBalance.toStringAsFixed(2),
                  textColor:
                      vm.availableBalance >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection({required String title, required Widget child}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? ThemeConstants.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemeConstants.primaryColor,
              ),
            ),
            const Gap(12),
            child,
          ],
        ),
      ),
    );
  }
}
