import 'package:finance_tracker/core/constants/theme_constants.dart';
import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/data/models/asset_liability_model.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/transaction_viewmodel.dart';
import '../../../../viewmodels/budget_viewmodel.dart';
import '../../../../viewmodels/asset_liability_viewmodel.dart';
import '../../../../widgets/custom_text_field.dart';

class ActivitySearchScreen extends StatefulWidget {
  const ActivitySearchScreen({super.key});

  @override
  State<ActivitySearchScreen> createState() => _ActivitySearchScreenState();
}

class _ActivitySearchScreenState extends State<ActivitySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTabIndex = 0;
  String _searchQuery = '';

  List<Map<String, dynamic>> _getCombinedResults(BuildContext context) {
    final transactionVm = context.read<TransactionViewModel>();
    final budgetVm = context.read<BudgetViewModel>();
    final assetVm = context.read<AssetLiabilityViewModel>();

    switch (_selectedTabIndex) {
      case 0: // Transactions
        return transactionVm.transactions
            .map((t) => {
                  'type': 'transaction',
                  'title': t.category,
                  'category': t.category,
                  'amount': t.amount,
                  'date': t.date,
                  'isIncome': t.type == TransactionType.income,
                  'icon': t.type == TransactionType.income
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                })
            .toList();

      case 1: // Budgets
        return budgetVm.filteredBudgets
            .map((b) => {
                  'type': 'budget',
                  'title': b.category,
                  'amount': b.amount,
                  'spent': b.spent,
                  'remaining': b.remaining,
                  'startDate': b.startDate,
                  'icon': Icons.account_balance_wallet,
                })
            .toList();

      case 2: // Portfolio
        return [
          ...assetVm.assets.map((a) => _mapAssetLiability(a, true)),
          ...assetVm.liabilities.map((l) => _mapAssetLiability(l, false)),
        ];

      default:
        return [];
    }
  }

  Map<String, dynamic> _mapAssetLiability(
          AssetLiabilityModel item, bool isAsset) =>
      {
        'type': 'portfolio',
        'title': item.name,
        'amount': item.amount,
        'isAsset': isAsset,
        'date': item.updatedAt,
        'icon': isAsset ? Icons.trending_up : Icons.trending_down,
      };

  List<Map<String, dynamic>> _filterResults(List<Map<String, dynamic>> items) {
    if (_searchQuery.isEmpty) return items;

    final query = _searchQuery.toLowerCase();
    return items.where((item) {
      switch (item['type']) {
        case 'transaction':
          return item['title'].toLowerCase().contains(query) ||
              item['category'].toLowerCase().contains(query) ||
              item['amount'].toString().contains(query);

        case 'budget':
          return item['title'].toLowerCase().contains(query) ||
              item['amount'].toString().contains(query);

        case 'portfolio':
          return item['title'].toLowerCase().contains(query) ||
              item['amount'].toString().contains(query);

        default:
          return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filterResults(_getCombinedResults(context));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final local = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: ThemeConstants.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: CustomTextField(
            controller: _searchController,
            hintText: 'Search across all activities...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Iconsax.close_circle_bold),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          bottom: TabBar(
            dividerColor: Colors.white,
            dividerHeight: 0,
            onTap: (index) => setState(() => _selectedTabIndex = index),
            indicatorColor: ThemeConstants.primaryColor,
            tabs: [
              Tab(text: local.transactionsTitle),
              Tab(text: local.budgetTitle),
              Tab(text: local.portfolio),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildResultsList(results, 'transaction', isDarkMode),
            _buildResultsList(results, 'budget', isDarkMode),
            _buildResultsList(results, 'portfolio', isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(
      List<Map<String, dynamic>> results, String type, bool isDarkMode) {
    final filtered = results.where((item) => item['type'] == type).toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return ListTile(
          leading: Icon(item['icon'], color: _getIconColor(item)),
          title: Text(item['title']),
          subtitle: _buildSubtitle(item),
          trailing: _buildTrailing(item, isDarkMode),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        );
      },
    );
  }

  Color _getIconColor(Map<String, dynamic> item) {
    switch (item['type']) {
      case 'transaction':
        return item['isIncome'] ? Colors.green : Colors.red;
      case 'budget':
        return Colors.blue;
      case 'portfolio':
        return item['isAsset'] ? Colors.green : Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSubtitle(Map<String, dynamic> item) {
    switch (item['type']) {
      case 'transaction':
        return Text(
          '${DateFormat('dd MMM yyyy').format(item['date'])} • ${item['category']}',
          style: TextStyle(color: Colors.grey[600]),
        );

      case 'budget':
        return Text(
          'Budget: ${Helpers.storeCurrency(context)}${item['amount'].toStringAsFixed(2)}\n'
          'Spent: ${Helpers.storeCurrency(context)}${item['spent'].toStringAsFixed(2)}',
          style: TextStyle(color: Colors.grey[600]),
        );

      case 'portfolio':
        return Text(
          '${item['isAsset'] ? 'Asset' : 'Liability'} • '
          '${DateFormat('dd MMM yyyy').format(item['date'])}',
          style: TextStyle(color: Colors.grey[600]),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTrailing(Map<String, dynamic> item, bool isDarkMode) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: _getTrailingColor(item, isDarkMode),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (item['type'] == 'budget')
          Text(
            'Remaining: ${Helpers.storeCurrency(context)}${item['remaining'].toStringAsFixed(2)}',
            style: textStyle.copyWith(fontSize: 12),
          ),
        Text(
          '${Helpers.storeCurrency(context)}${item['amount'].toStringAsFixed(2)}',
          style: textStyle,
        ),
      ],
    );
  }

  Color _getTrailingColor(Map<String, dynamic> item, bool isDarkMode) {
    switch (item['type']) {
      case 'transaction':
        return item['isIncome'] ? Colors.green : Colors.red;
      case 'budget':
        return isDarkMode ? Colors.blue[200]! : Colors.blue[800]!;
      case 'portfolio':
        return item['isAsset'] ? Colors.green : Colors.red;
      default:
        return isDarkMode ? Colors.white : Colors.black;
    }
  }
}
