import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../generated/l10n.dart';
import '../../../../viewmodels/transaction_viewmodel.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../widgets/custom_loader.dart';
import '../../dashboard/add_transaction_sheet_new.dart';
import '../../../../widgets/transaction_item.dart';
import '../../../../core/utils/motion_toast.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ToastUtils.showErrorToast(
              context,
              title: localization.error,
              description: viewModel.error!,
            );
            viewModel.clearError();
          });
        }

        return _buildContent(viewModel);
      },
    );
  }

  Widget _buildContent(TransactionViewModel viewModel) {
    final localization = AppLocalizations.of(context);

    if (viewModel.isLoading) {
      return const SizedBox();
    }

    if (viewModel.filteredTransactions.isEmpty) {
      return Center(child: Text(localization.noTransactionsFound));
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadTransactionsForMonth(viewModel.selectedMonth),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: viewModel.filteredTransactions.length,
        separatorBuilder: (context, index) => Divider(
          height: 0.1,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[200],
        ),
        itemBuilder: (context, index) {
          final transaction = viewModel.filteredTransactions[index];
          return _buildTransactionItem(context, transaction, viewModel);
        },
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionModel transaction,
    TransactionViewModel viewModel,
  ) {
    return InkWell(
      onTap: () => _showTransactionDetails(context, transaction, viewModel),
      child: TransactionItem(
        date: transaction.date,
        categoryIcon: _getIconForCategory(transaction.category),
        title: transaction.category,
        description: _buildDescription(transaction),
        amount: transaction.amount,
        isExpense: transaction.type == TransactionType.expense,
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    // Implement your category-to-icon mapping
    return Icons.receipt;
  }

  String _buildDescription(TransactionModel transaction) {
    String description = transaction.paymentMethod;
    if (transaction.description.isNotEmpty) {
      description += ' - ${transaction.description}';
    }
    return description;
  }

  void _showTransactionDetails(
    BuildContext context,
    TransactionModel transaction,
    TransactionViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Gap(24),
            _buildDetailRow(AppLocalizations.of(context).categoryLabel,
                transaction.category),
            _buildDetailRow(AppLocalizations.of(context).amountLabel,
                '₹${transaction.amount.toStringAsFixed(2)}'),
            _buildDetailRow(AppLocalizations.of(context).dateLabel,
                DateFormat('MMM d, yyyy').format(transaction.date)),
            _buildDetailRow(AppLocalizations.of(context).paymentMethod,
                transaction.paymentMethod),
            if (transaction.description.isNotEmpty)
              _buildDetailRow(AppLocalizations.of(context).settlement,
                  transaction.description),
            const Gap(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.edit,
                  label: AppLocalizations.of(context).edit,
                  onPressed: () =>
                      _editTransaction(context, transaction, viewModel),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.delete,
                  label: AppLocalizations.of(context).delete,
                  color: Colors.red,
                  onPressed: () =>
                      _deleteTransaction(context, transaction.id, viewModel),
                ),
              ],
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
      ),
    );
  }

  Future<void> _editTransaction(
    BuildContext context,
    TransactionModel transaction,
    TransactionViewModel viewModel,
  ) async {
    Navigator.pop(context);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddTransactionSheet(
        isEditing: true,
        transaction: transaction,
        onSave: (updatedTransaction) async {
          final success = await viewModel.updateTransaction(updatedTransaction);
          if (success && context.mounted) {
            ToastUtils.showSuccessToast(
              context,
              title: AppLocalizations.of(context).success,
              description:
                  AppLocalizations.of(context).transactionUpdatedSuccessfully,
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    String transactionId,
    TransactionViewModel viewModel,
  ) async {
    final local = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(local.deleteTransaction),
        content: Text(local.confirmDeleteTransaction),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(local.cancelButton),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteTransaction(transactionId);
              ToastUtils.showSuccessToast(
                context,
                title: local.success,
                description: local.transactionDeletedSuccessfully,
              );
              Navigator.pop(context);
            },
            child:
                Text(local.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}