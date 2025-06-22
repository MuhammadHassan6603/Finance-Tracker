import 'package:finance_tracker/data/models/debt_model.dart';
import 'package:finance_tracker/viewmodels/debt_viewmodel.dart';
import 'package:finance_tracker/widgets/app_header_text.dart';
import 'package:finance_tracker/widgets/custom_text_field.dart';
import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/helpers.dart';

class DebtRepaymentScreen extends StatelessWidget {
  const DebtRepaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppbar(title: 'Debt Repayment Plan'),
      body: Consumer<DebtViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDebtSummary(context, viewModel),
                const SizedBox(height: 24),
                _buildDebtList(context, viewModel),
                const SizedBox(height: 24),
                _buildDebtAnalysis(context, viewModel),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDebtSummary(BuildContext context, DebtViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeaderText(text: 'Debt Summary', fontSize: 20),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  context,
                  'Total Debt',
                  '${Helpers.storeCurrency(context)}${viewModel.totalDebt}',
                  Icons.account_balance,
                ),
                _buildSummaryItem(
                  context,
                  'Monthly Payment',
                  '${Helpers.storeCurrency(context)}${viewModel.totalMonthlyPayment}',
                  Icons.calendar_today,
                ),
                _buildSummaryItem(
                  context,
                  'Avg Interest',
                  '${viewModel.averageInterestRate.toStringAsFixed(1)}%',
                  Icons.percent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const Gap(8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Gap(4),
        AppHeaderText(text: value, fontSize: 14),
      ],
    );
  }

  Widget _buildDebtList(BuildContext context, DebtViewModel viewModel) {
    final activeDebts = viewModel.activeDebts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppHeaderText(text: 'Active Debts', fontSize: 20),
        const Gap(16),
        if (activeDebts.isEmpty)
          const Center(
            child: Text('No active debts'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeDebts.length,
            itemBuilder: (context, index) {
              return _buildDebtCard(
                context,
                activeDebts[index],
                viewModel,
              );
            },
          ),
      ],
    );
  }

  Widget _buildDebtCard(
    BuildContext context,
    DebtModel debt,
    DebtViewModel viewModel,
  ) {
    return Card(
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
                        debt.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        debt.type.toString().split('.').last,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'payment':
                        _showAddPaymentDialog(context, debt, viewModel);
                        break;
                      case 'edit':
                        _showEditDebtDialog(context, debt, viewModel);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(context, debt, viewModel);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'payment',
                      child: Text('Add Payment'),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(16),
            LinearProgressIndicator(
              value: debt.progressPercentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${debt.progressPercentage.toStringAsFixed(1)}% paid',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${Helpers.storeCurrency(context)}${debt.remainingAmount} remaining',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Payment',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${Helpers.storeCurrency(context)}${debt.minimumPayment}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Interest Rate',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${debt.interestRate}%',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtAnalysis(BuildContext context, DebtViewModel viewModel) {
    final sortedByInterest = viewModel.getSortedByInterestRate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppHeaderText(text: 'Debt Analysis', fontSize: 20),
        const Gap(16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Payoff Strategy',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Debt Avalanche Method: Pay off debts in order of highest to lowest interest rate while maintaining minimum payments on all debts.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (sortedByInterest.isNotEmpty) ...[
                  Text(
                    'Priority Order:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedByInterest.length,
                    itemBuilder: (context, index) {
                      final debt = sortedByInterest[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(debt.name),
                        subtitle: Text(
                          '${debt.interestRate}% APR - ${Helpers.storeCurrency(context)}${debt.remainingAmount} remaining',
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddDebtDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    DebtType type = DebtType.other;
    double totalAmount = 0;
    double interestRate = 0;
    double minimumPayment = 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Debt'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  labelText: 'Debt Name',
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a name' : null,
                  onSaved: (value) => name = value ?? '',
                ),
                DropdownButtonFormField<DebtType>(
                  decoration: const InputDecoration(labelText: 'Debt Type'),
                  value: type,
                  items: DebtType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) => type = value ?? DebtType.other,
                ),
                CustomTextField(
                  labelText: 'Total Amount',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter an amount';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) => totalAmount = double.parse(value!),
                ),
                CustomTextField(
                  labelText: 'Interest Rate (%)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter a rate';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid rate';
                    }
                    return null;
                  },
                  onSaved: (value) => interestRate = double.parse(value!),
                ),
                CustomTextField(
                  labelText: 'Minimum Monthly Payment',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter an amount';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) => minimumPayment = double.parse(value!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final viewModel = context.read<DebtViewModel>();
                final debt = DebtModel(
                  id: '',
                  userId: viewModel.authViewModel.currentUser!.id,
                  name: name,
                  type: type,
                  totalAmount: totalAmount,
                  remainingAmount: totalAmount,
                  interestRate: interestRate,
                  startDate: DateTime.now(),
                  paymentFrequency: 'monthly',
                  minimumPayment: minimumPayment,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                viewModel.addDebt(debt);
                Navigator.pop(context);
              }
            },
            child: const Text('Add Debt'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDebtDialog(
    BuildContext context,
    DebtModel debt,
    DebtViewModel viewModel,
  ) async {
    final formKey = GlobalKey<FormState>();
    String name = debt.name;
    DebtType type = debt.type;
    double interestRate = debt.interestRate;
    double minimumPayment = debt.minimumPayment;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Debt'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  initialValue: name,
                  labelText: 'Debt Name',
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a name' : null,
                  onSaved: (value) => name = value ?? '',
                ),
                DropdownButtonFormField<DebtType>(
                  decoration: const InputDecoration(labelText: 'Debt Type'),
                  value: type,
                  items: DebtType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) => type = value ?? DebtType.other,
                ),
                CustomTextField(
                  initialValue: interestRate.toString(),
                  labelText: 'Interest Rate (%)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter a rate';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid rate';
                    }
                    return null;
                  },
                  onSaved: (value) => interestRate = double.parse(value!),
                ),
                CustomTextField(
                  initialValue: minimumPayment.toString(),
                  labelText: 'Minimum Monthly Payment',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter an amount';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) => minimumPayment = double.parse(value!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final updatedDebt = debt.copyWith(
                  name: name,
                  type: type,
                  interestRate: interestRate,
                  minimumPayment: minimumPayment,
                  updatedAt: DateTime.now(),
                );
                viewModel.updateDebt(updatedDebt);
                Navigator.pop(context);
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPaymentDialog(
    BuildContext context,
    DebtModel debt,
    DebtViewModel viewModel,
  ) async {
    final formKey = GlobalKey<FormState>();
    double paymentAmount = 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Balance: ${Helpers.storeCurrency(context)}${debt.remainingAmount}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Payment Amount',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter an amount';
                  final amount = double.tryParse(value!);
                  if (amount == null) return 'Please enter a valid amount';
                  if (amount <= 0) return 'Amount must be greater than zero';
                  if (amount > debt.remainingAmount) {
                    return 'Amount cannot exceed remaining balance';
                  }
                  return null;
                },
                onSaved: (value) => paymentAmount = double.parse(value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                viewModel.addPayment(debt.id, paymentAmount);
                Navigator.pop(context);
              }
            },
            child: const Text('Add Payment'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    DebtModel debt,
    DebtViewModel viewModel,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Debt'),
        content: Text(
          'Are you sure you want to delete "${debt.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteDebt(debt.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
