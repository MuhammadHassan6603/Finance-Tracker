import 'dart:io';
import 'package:finance_tracker/core/utils/motion_toast.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:finance_tracker/viewmodels/transaction_viewmodel.dart';
import 'package:finance_tracker/viewmodels/budget_viewmodel.dart';
import 'package:finance_tracker/viewmodels/asset_liability_viewmodel.dart';
import 'package:finance_tracker/core/utils/helpers.dart';

class DownloadReportsScreen extends StatefulWidget {
  const DownloadReportsScreen({super.key});

  @override
  State<DownloadReportsScreen> createState() => _DownloadReportsScreenState();
}

class _DownloadReportsScreenState extends State<DownloadReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppbar(title: AppLocalizations.of(context).downloadReports),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeSelector(),
            const SizedBox(height: 24),
            _buildReportTypes(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    final local = AppLocalizations.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              local.selectDateRange,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    AppLocalizations.of(context).startDate,
                    _startDate,
                    (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    AppLocalizations.of(context).endDate,
                    _endDate,
                    (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickDateButton(local.last30Days, 30),
                _buildQuickDateButton(local.last90Days, 90),
                _buildQuickDateButton(local.thisYear, 365),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime value,
    Function(DateTime) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              Helpers.formatDate(value),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(String label, int days) {
    return TextButton(
      onPressed: () {
        setState(() {
          _endDate = DateTime.now();
          _startDate = _endDate.subtract(Duration(days: days));
        });
      },
      child: Text(label),
    );
  }

  Widget _buildReportTypes() {
    final local = AppLocalizations.of(context);
    return Column(
      children: [
        _buildReportCard(
          local.transactionsReport,
          local.detailedListOfAllTransactions,
          Icons.receipt_long,
          _generateTransactionsReport,
        ),
        const SizedBox(height: 16),
        _buildReportCard(
          local.budgetReport,
          local.budgetVsActualSpendingAnalysis,
          Icons.account_balance_wallet,
          _generateBudgetReport,
        ),
        const SizedBox(height: 16),
        _buildReportCard(
          local.assetsLiabilitiesReport,
          local.netWorthAndFinancialPosition,
          Icons.analytics,
          _generateAssetsLiabilitiesReport,
        ),
        const SizedBox(height: 16),
        _buildReportCard(
          local.completeFinancialReport,
          local.comprehensiveFinancialSummary,
          Icons.summarize,
          _generateCompleteReport,
        ),
      ],
    );
  }

  Widget _buildReportCard(
    String title,
    String subtitle,
    IconData icon,
    Future<void> Function() onGenerate,
  ) {
    final local = AppLocalizations.of(context);
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed:
                  _isLoading ? null : () => _handleReportGeneration(onGenerate),
              child: Text(_isLoading ? local.generating : local.generateReport),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleReportGeneration(
      Future<void> Function() generateFunction) async {
    if (_isLoading) return;

    final permission = await _checkStoragePermission();
    if (!permission) {
      if (mounted) {
        ToastUtils.showErrorToast(context,
            title: 'Permissions',
            description: 'Storage permission is required to save reports');
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      await generateFunction();
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(context,
            title: 'Error',
            description: 'Error generating report: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<void> _generateTransactionsReport() async {
    final transactionVM = context.read<TransactionViewModel>();
    final transactions =
        transactionVM.getTransactionsInRange(_startDate, _endDate);

    final csvData = [
      [
        'Date',
        'Category',
        'Type',
        'Amount',
        'Description',
        'Payment Method',
        'Recurring',
        'Created At'
      ],
      ...transactions.map((t) => [
            Helpers.formatDate(t.date),
            t.category,
            t.type.toString().split('.').last,
            t.amount,
            t.description,
            t.paymentMethod,
            t.isRecurring ? 'Yes' : 'No',
            Helpers.formatDate(t.createdAt),
          ]),
    ];

    await _saveAndShareReport(csvData, 'transactions_report');
  }

  Future<void> _generateBudgetReport() async {
    final budgetVM = context.read<BudgetViewModel>();
    final transactionVM = context.read<TransactionViewModel>();

    final budgets = budgetVM.budgets;
    final csvData = [
      [
        'Category',
        'Period Type',
        'Budget Amount',
        'Spent',
        'Remaining',
        'Progress %',
        'Start Date',
        'End Date',
        'Status'
      ],
      ...budgets.map((b) {
        final progress = b.progress * 100;

        return [
          b.category,
          b.periodType,
          b.amount,
          b.spent,
          b.remaining,
          '${progress.toStringAsFixed(1)}%',
          Helpers.formatDate(b.startDate),
          Helpers.formatDate(b.endDate),
          b.isActive ? 'Active' : 'Inactive',
        ];
      }),
    ];

    await _saveAndShareReport(csvData, 'budget_report');
  }

  Future<void> _generateAssetsLiabilitiesReport() async {
    final assetLiabilityVM = context.read<AssetLiabilityViewModel>();

    final assets = assetLiabilityVM.assets;
    final liabilities = assetLiabilityVM.liabilities;

    final csvData = [
      [
        'Type',
        'Name',
        'Category Type',
        'Amount',
        'Start Date',
        'Interest Rate',
        'Payment Schedule',
        'Status',
        'Last Updated'
      ],
      ...assets.map((a) => [
            'Asset',
            a.name,
            a.type,
            a.amount,
            Helpers.formatDate(a.startDate),
            a.interestRate != null ? '${a.interestRate}%' : 'N/A',
            a.paymentSchedule ?? 'N/A',
            a.isActive ? 'Active' : 'Inactive',
            Helpers.formatDate(a.updatedAt),
          ]),
      ...liabilities.map((l) => [
            'Liability',
            l.name,
            l.type,
            l.amount,
            Helpers.formatDate(l.startDate),
            l.interestRate != null ? '${l.interestRate}%' : 'N/A',
            l.paymentSchedule ?? 'N/A',
            l.isActive ? 'Active' : 'Inactive',
            Helpers.formatDate(l.updatedAt),
          ]),
      [],
      ['Summary'],
      ['Total Assets', assetLiabilityVM.totalAssets],
      ['Total Liabilities', assetLiabilityVM.totalLiabilities],
      ['Net Worth', assetLiabilityVM.netWorth],
      [],
      ['Monthly Payments'],
      ...liabilities
          .where((l) => l.isActive && l.paymentSchedule == 'Monthly')
          .map((l) => [
                l.name,
                'Monthly Payment',
                l.monthlyPayment,
                'EMI',
                l.emi,
              ]),
    ];

    await _saveAndShareReport(csvData, 'assets_liabilities_report');
  }

  Future<void> _generateCompleteReport() async {
    final reports = await Future.wait([
      _generateReportData('Transactions', _getTransactionsData),
      _generateReportData('Budgets', _getBudgetData),
      _generateReportData('Assets & Liabilities', _getAssetsLiabilitiesData),
      _generateReportData('Performance Analysis', _getPerformanceData),
    ]);

    final allData = [
      ['Financial Report'],
      [
        'Period:',
        '${Helpers.formatDate(_startDate)} to ${Helpers.formatDate(_endDate)}'
      ],
      ['Generated:', Helpers.formatDate(DateTime.now())],
      [],
      ...reports.expand((report) => [...report, [], []]).toList(),
    ];

    await _saveAndShareReport(allData, 'complete_financial_report');
  }

  Future<List<List<dynamic>>> _generateReportData(
    String title,
    Future<List<List<dynamic>>> Function() dataGenerator,
  ) async {
    return [
      [title],
      [],
      ...await dataGenerator(),
    ];
  }

  Future<List<List<dynamic>>> _getTransactionsData() async {
    final transactionVM = context.read<TransactionViewModel>();
    final transactions =
        transactionVM.getTransactionsInRange(_startDate, _endDate);

    return [
      [
        'Date',
        'Category',
        'Type',
        'Amount',
        'Description',
        'Payment Method',
        'Recurring',
        'Created At'
      ],
      ...transactions.map((t) => [
            Helpers.formatDate(t.date),
            t.category,
            t.type.toString().split('.').last,
            t.amount,
            t.description,
            t.paymentMethod,
            t.isRecurring ? 'Yes' : 'No',
            Helpers.formatDate(t.createdAt),
          ]),
    ];
  }

  Future<List<List<dynamic>>> _getBudgetData() async {
    final budgetVM = context.read<BudgetViewModel>();

    return [
      [
        'Category',
        'Period Type',
        'Budget Amount',
        'Spent',
        'Remaining',
        'Progress %',
        'Start Date',
        'End Date',
        'Status'
      ],
      ...budgetVM.budgets.map((b) {
        final progress = b.progress * 100;

        return [
          b.category,
          b.periodType,
          b.amount,
          b.spent,
          b.remaining,
          '${progress.toStringAsFixed(1)}%',
          Helpers.formatDate(b.startDate),
          Helpers.formatDate(b.endDate),
          b.isActive ? 'Active' : 'Inactive',
        ];
      }),
    ];
  }

  Future<List<List<dynamic>>> _getAssetsLiabilitiesData() async {
    final assetLiabilityVM = context.read<AssetLiabilityViewModel>();

    return [
      [
        'Type',
        'Name',
        'Category Type',
        'Amount',
        'Start Date',
        'Interest Rate',
        'Payment Schedule',
        'Status',
        'Last Updated'
      ],
      ...assetLiabilityVM.assets.map((a) => [
            'Asset',
            a.name,
            a.type,
            a.amount,
            Helpers.formatDate(a.startDate),
            a.interestRate != null ? '${a.interestRate}%' : 'N/A',
            a.paymentSchedule ?? 'N/A',
            a.isActive ? 'Active' : 'Inactive',
            Helpers.formatDate(a.updatedAt),
          ]),
      ...assetLiabilityVM.liabilities.map((l) => [
            'Liability',
            l.name,
            l.type,
            l.amount,
            Helpers.formatDate(l.startDate),
            l.interestRate != null ? '${l.interestRate}%' : 'N/A',
            l.paymentSchedule ?? 'N/A',
            l.isActive ? 'Active' : 'Inactive',
            Helpers.formatDate(l.updatedAt),
          ]),
      [],
      ['Summary'],
      ['Total Assets', assetLiabilityVM.totalAssets],
      ['Total Liabilities', assetLiabilityVM.totalLiabilities],
      ['Net Worth', assetLiabilityVM.netWorth],
    ];
  }

  Future<List<List<dynamic>>> _getPerformanceData() async {
    final assetLiabilityVM = context.read<AssetLiabilityViewModel>();
    final assets = assetLiabilityVM.assets;

    return [
      ['Asset Performance Analysis'],
      [
        'Asset Name',
        'Current Value',
        'Initial Amount',
        'Performance %',
        'Last Updated'
      ],
      ...assets.map((a) => [
            a.name,
            a.currentValue,
            a.amount,
            '${a.performancePercentage.toStringAsFixed(2)}%',
            Helpers.formatDate(a.updatedAt),
          ]),
      [],
      ['Historical Performance (Last 6 Months)'],
      ...assets.map((a) {
        final history = a.getPerformanceHistory(6);
        return [
          a.name,
          ...history.entries.map((e) => '${e.key}: ${e.value}'),
        ];
      }),
    ];
  }

  Future<void> _saveAndShareReport(
      List<List<dynamic>> csvData, String filename) async {
    final csv = const ListToCsvConverter().convert(csvData);
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/$filename-${DateTime.now().millisecondsSinceEpoch}.csv');

    await file.writeAsString(csv);

    if (mounted) {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Financial Report',
      );
    }
  }
}
