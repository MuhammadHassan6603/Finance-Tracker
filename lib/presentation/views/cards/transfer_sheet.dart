import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../viewmodels/account_card_viewmodel.dart';
import '../../../core/utils/motion_toast.dart';

class TransferSheet extends StatefulWidget {
  const TransferSheet({super.key});

  @override
  State<TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<TransferSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _fromAccountId;
  String? _toAccountId;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<AccountCardViewModel>();
    final accountCards = viewModel.accountCards;

    return Material(
      color: isDarkMode ? ThemeConstants.surfaceDark : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Transfer Money',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? ThemeConstants.textPrimaryDark
                            : ThemeConstants.textPrimaryLight,
                      ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'From Account',
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(
                      color: isDarkMode
                          ? ThemeConstants.textSecondaryDark
                          : ThemeConstants.textSecondaryLight,
                    ),
                  ),
                  value: _fromAccountId,
                  items: accountCards.map((card) {
                    return DropdownMenuItem(
                      value: card.id,
                      child: Text('${card.name} (₹${card.balance.toStringAsFixed(2)})'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _fromAccountId = value),
                  validator: (value) =>
                      value == null ? 'Please select an account' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'To Account',
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(
                      color: isDarkMode
                          ? ThemeConstants.textSecondaryDark
                          : ThemeConstants.textSecondaryLight,
                    ),
                  ),
                  value: _toAccountId,
                  items: accountCards
                      .where((card) => card.id != _fromAccountId)
                      .map((card) {
                    return DropdownMenuItem(
                      value: card.id,
                      child: Text('${card.name} (₹${card.balance.toStringAsFixed(2)})'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _toAccountId = value),
                  validator: (value) =>
                      value == null ? 'Please select an account' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: const OutlineInputBorder(),
                    prefixText: '₹ ',
                    labelStyle: TextStyle(
                      color: isDarkMode
                          ? ThemeConstants.textSecondaryDark
                          : ThemeConstants.textSecondaryLight,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter amount';
                    }
                    final amount = double.tryParse(value!);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    
                    // Check if source account has enough balance
                    if (_fromAccountId != null) {
                      final sourceAccount = accountCards.firstWhere(
                        (card) => card.id == _fromAccountId,
                        orElse: () => accountCards.first,
                      );
                      if (amount > sourceAccount.balance) {
                        return 'Insufficient balance';
                      }
                    }
                    
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Note (Optional)',
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(
                      color: isDarkMode
                          ? ThemeConstants.textSecondaryDark
                          : ThemeConstants.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _transfer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Transfer'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _transfer() async {
    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = context.read<AccountCardViewModel>();
      final amount = double.parse(_amountController.text);
      final note = _noteController.text;
      
      try {
        // Get source and destination accounts
        final sourceAccount = viewModel.accountCards.firstWhere(
          (card) => card.id == _fromAccountId,
        );
        
        final destinationAccount = viewModel.accountCards.firstWhere(
          (card) => card.id == _toAccountId,
        );
        
        // Update source account (decrease balance)
        final updatedSourceAccount = sourceAccount.copyWith(
          balance: sourceAccount.balance - amount,
        );
        
        // Update destination account (increase balance)
        final updatedDestinationAccount = destinationAccount.copyWith(
          balance: destinationAccount.balance + amount,
        );
        
        // Save both accounts
        final sourceSuccess = await viewModel.updateAccountCard(updatedSourceAccount);
        final destinationSuccess = await viewModel.updateAccountCard(updatedDestinationAccount);
        
        if (sourceSuccess && destinationSuccess && mounted) {
          Navigator.pop(context);
          ToastUtils.showSuccessToast(
            context,
            title: 'Success',
            description: 'Transfer completed successfully',
          );
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showErrorToast(
            context,
            title: 'Error',
            description: e.toString(),
          );
        }
      }
    }
  }
} 