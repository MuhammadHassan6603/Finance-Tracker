import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/core/utils/motion_toast.dart';
import 'package:finance_tracker/data/models/savings_goal_model.dart';
import 'package:finance_tracker/viewmodels/savings_goal_viewmodel.dart';
import 'package:finance_tracker/widgets/app_header_text.dart';
import 'package:finance_tracker/widgets/custom_button.dart';
import 'package:finance_tracker/widgets/custom_loader.dart';
import 'package:finance_tracker/widgets/custom_text_field.dart';
import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class SavingsGoalsScreen extends StatelessWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppbar(title: 'Savings Goals'),
      body: Consumer<SavingsGoalViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CustomLoadingOverlay());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverallProgress(context, viewModel),
                const SizedBox(height: 24),
                _buildActiveGoals(context, viewModel),
                const SizedBox(height: 24),
                _buildCompletedGoals(context, viewModel),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOverallProgress(
      BuildContext context, SavingsGoalViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeaderText(text: 'Overall Progress', fontSize: 20),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Saved',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${Helpers.storeCurrency(context)}${viewModel.totalSaved}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Target',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${Helpers.storeCurrency(context)}${viewModel.totalTarget}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: viewModel.overallProgress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${viewModel.overallProgress.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveGoals(
      BuildContext context, SavingsGoalViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppHeaderText(text: 'Active Goals', fontSize: 20),
        const SizedBox(height: 16),
        if (viewModel.activeGoals.isEmpty)
          const Center(
            child: Text('No active savings goals'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.activeGoals.length,
            itemBuilder: (context, index) {
              return _buildGoalCard(
                context,
                viewModel.activeGoals[index],
                viewModel,
              );
            },
          ),
      ],
    );
  }

  Widget _buildCompletedGoals(
      BuildContext context, SavingsGoalViewModel viewModel) {
    if (viewModel.completedGoals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completed Goals',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: viewModel.completedGoals.length,
          itemBuilder: (context, index) {
            return _buildGoalCard(
              context,
              viewModel.completedGoals[index],
              viewModel,
              isCompleted: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    SavingsGoalModel goal,
    SavingsGoalViewModel viewModel, {
    bool isCompleted = false,
  }) {
    final progress = goal.progressPercentage;
    final remainingAmount = goal.targetAmount - goal.currentAmount;
    final daysRemaining = goal.targetDate.difference(DateTime.now()).inDays;

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
                  child: Text(
                    goal.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Row(
                  children: [
                    if (!isCompleted)
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _showAddContributionDialog(
                          context,
                          goal,
                          viewModel,
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      onPressed: () => _showDeleteConfirmation(
                        context,
                        goal,
                        viewModel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${Helpers.storeCurrency(context)}${goal.currentAmount} / ${Helpers.storeCurrency(context)}${goal.targetAmount}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remaining: ${Helpers.storeCurrency(context)}$remainingAmount',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '$daysRemaining days left',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: daysRemaining < 30 ? Colors.red : null,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showAddGoalDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String title = '';
    double targetAmount = 0;
    DateTime targetDate = DateTime.now().add(const Duration(days: 30));

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Savings Goal'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  labelText: 'Goal Title',
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a title' : null,
                  onSaved: (value) => title = value ?? '',
                ),
                const Gap(8),
                CustomTextField(
                  labelText: 'Target Amount',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter an amount';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) => targetAmount = double.parse(value!),
                ),
                const Gap(16),
                CustomButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: targetDate,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (date != null) {
                        targetDate = date;
                      }
                    },
                    child: const Text('Select Target Date')),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  formKey.currentState?.save();
                  final viewModel = context.read<SavingsGoalViewModel>();
                  final goal = SavingsGoalModel(
                    id: '',
                    userId: viewModel.authViewModel.currentUser!.id,
                    title: title,
                    targetAmount: targetAmount,
                    startDate: DateTime.now(),
                    targetDate: targetDate,
                    category: 'Savings',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  viewModel.createSavingsGoal(goal);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Goal')),
        ],
      ),
    );
  }

  Future<void> _showAddContributionDialog(
    BuildContext context,
    SavingsGoalModel goal,
    SavingsGoalViewModel viewModel,
  ) async {
    final formKey = GlobalKey<FormState>();
    double amount = 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Contribution'),
        content: Form(
          key: formKey,
          child: CustomTextField(
            labelText: 'Amount',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Please enter an amount';
              if (double.tryParse(value!) == null) {
                return 'Please enter a valid amount';
              }
              return null;
            },
            onSaved: (value) => amount = double.parse(value!),
          ),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                viewModel.addContribution(goal.id, amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    SavingsGoalModel goal,
    SavingsGoalViewModel viewModel,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text(
          'Are you sure you want to delete "${goal.title}"? This action cannot be undone.',
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            onPressed: () async {
              final success = await viewModel.deleteSavingsGoal(goal.id);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ToastUtils.showSuccessToast(context,
                      title: 'Deleted',
                      description: 'Goal deleted successfully');
                } else {
                  ToastUtils.showErrorToast(context,
                      title: 'Failed',
                      description: viewModel.error ?? 'Failed to delete goal');
                }
              }
            },
            backgroundColor: Colors.red,
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
