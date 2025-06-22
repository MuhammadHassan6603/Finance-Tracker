import 'package:finance_tracker/data/models/retirement_model.dart';
import 'package:finance_tracker/viewmodels/retirement_viewmodel.dart';
import 'package:finance_tracker/widgets/app_header_text.dart';
import 'package:finance_tracker/widgets/custom_text_field.dart';
import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';

import '../../../../core/utils/helpers.dart';

class RetirementPlanningScreen extends StatelessWidget {
  const RetirementPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppbar(title: 'Retirement Planning'),
      body: Consumer<RetirementViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final plan = viewModel.retirementPlan;
          if (plan == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () => _showEditPlanDialog(context, null),
                child: const Text('Create Retirement Plan'),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(context, plan),
                const Gap(24),
                _buildProjectionsCard(context, plan),
                const Gap(24),
                _buildRecommendationsCard(context, plan),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditPlanDialog(
          context,
          context.read<RetirementViewModel>().retirementPlan,
        ),
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, RetirementModel plan) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeaderText(text: 'Retirement Summary', fontSize: 20),
            const Gap(16),
            _buildSummaryRow(
              context,
              'Current Age',
              plan.currentAge.toString(),
              Icons.person,
            ),
            _buildSummaryRow(
              context,
              'Retirement Age',
              plan.retirementAge.toString(),
              Icons.elderly,
            ),
            _buildSummaryRow(
              context,
              'Years Until Retirement',
              plan.yearsUntilRetirement.toStringAsFixed(0),
              Icons.timer,
            ),
            _buildSummaryRow(
              context,
              'Current Savings',
              '${Helpers.storeCurrency(context)}${plan.currentSavings}',
              Icons.savings,
            ),
            _buildSummaryRow(
              context,
              'Monthly Contribution',
              '${Helpers.storeCurrency(context)}${plan.monthlyContribution}',
              Icons.trending_up,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const Gap(12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionsCard(BuildContext context, RetirementModel plan) {
    final isOnTrack = plan.isOnTrack;
    final fundingRatio = plan.fundingRatio;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeaderText(text: 'Retirement Projections', fontSize: 20),
            const Gap(16),
            ListTile(
              title: const Text('Projected Retirement Savings'),
              subtitle: Text(
                '${Helpers.storeCurrency(context)}${plan.projectedRetirementSavings.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              title: const Text('Monthly Retirement Income'),
              subtitle: Text(
                '${Helpers.storeCurrency(context)}${plan.monthlyRetirementIncome.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              title: const Text('Desired Monthly Income'),
              subtitle: Text(
                '${Helpers.storeCurrency(context)}${plan.desiredRetirementIncome.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Gap(16),
            LinearProgressIndicator(
              value: fundingRatio / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOnTrack ? Colors.green : Colors.orange,
              ),
            ),
            const Gap(8),
            Text(
              'Funding Progress: ${fundingRatio.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(BuildContext context, RetirementModel plan) {
    final recommendations = _getRecommendations(plan);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeaderText(text: 'Recommendations', fontSize: 20),
            const Gap(16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(recommendations[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getRecommendations(RetirementModel plan) {
    final recommendations = <String>[];

    if (!plan.isOnTrack) {
      recommendations.add(
        'Consider increasing your monthly contribution to reach your retirement goal.',
      );
    }

    if (plan.expectedAnnualReturn < 7) {
      recommendations.add(
        'Your expected return seems conservative. Consider diversifying your investments.',
      );
    }

    if (plan.monthlyContribution < plan.desiredRetirementIncome * 0.1) {
      recommendations.add(
        'Your current savings rate might be too low. Aim to save at least 10-15% of your income.',
      );
    }

    if (plan.retirementAge < 65) {
      recommendations.add(
        'Early retirement requires more savings. Make sure your plan accounts for a longer retirement period.',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add('You\'re on track with your retirement goals!');
    }

    return recommendations;
  }

  Future<void> _showEditPlanDialog(
    BuildContext context,
    RetirementModel? existingPlan,
  ) async {
    final formKey = GlobalKey<FormState>();
    int currentAge = existingPlan?.currentAge ?? 30;
    int retirementAge = existingPlan?.retirementAge ?? 65;
    double currentSavings = existingPlan?.currentSavings ?? 0;
    double monthlyContribution = existingPlan?.monthlyContribution ?? 0;
    double expectedAnnualReturn = existingPlan?.expectedAnnualReturn ?? 7;
    double inflationRate = existingPlan?.inflationRate ?? 2;
    double desiredRetirementIncome = existingPlan?.desiredRetirementIncome ?? 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingPlan == null
            ? 'Create Retirement Plan'
            : 'Edit Retirement Plan'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  initialValue: currentAge.toString(),
                  labelText: 'Current Age',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter your age';
                    final age = int.tryParse(value!);
                    if (age == null || age < 18 || age > 100) {
                      return 'Please enter a valid age between 18 and 100';
                    }
                    return null;
                  },
                  onSaved: (value) => currentAge = int.parse(value!),
                ),
                CustomTextField(
                  initialValue: retirementAge.toString(),
                  labelText: 'Retirement Age',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter retirement age';
                    }
                    final age = int.tryParse(value!);
                    if (age == null || age <= currentAge || age > 100) {
                      return 'Must be greater than current age and less than 100';
                    }
                    return null;
                  },
                  onSaved: (value) => retirementAge = int.parse(value!),
                ),
                CustomTextField(
                  initialValue: currentSavings.toString(),
                  labelText: 'Current Retirement Savings',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter amount';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) => currentSavings = double.parse(value!),
                ),
                CustomTextField(
                  initialValue: monthlyContribution.toString(),
                  labelText: 'Monthly Contribution',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter amount';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) =>
                      monthlyContribution = double.parse(value!),
                ),
                CustomTextField(
                  initialValue: expectedAnnualReturn.toString(),
                  labelText: 'Expected Annual Return (%)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter rate';
                    final rate = double.tryParse(value!);
                    if (rate == null || rate < 0 || rate > 20) {
                      return 'Please enter a valid rate between 0 and 20';
                    }
                    return null;
                  },
                  onSaved: (value) =>
                      expectedAnnualReturn = double.parse(value!),
                ),
                CustomTextField(
                  initialValue: inflationRate.toString(),
                  labelText: 'Expected Inflation Rate (%)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter rate';
                    final rate = double.tryParse(value!);
                    if (rate == null || rate < 0 || rate > 10) {
                      return 'Please enter a valid rate between 0 and 10';
                    }
                    return null;
                  },
                  onSaved: (value) => inflationRate = double.parse(value!),
                ),
                CustomTextField(
                  initialValue: desiredRetirementIncome.toString(),
                  labelText: 'Desired Monthly Retirement Income',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter amount';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) =>
                      desiredRetirementIncome = double.parse(value!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (existingPlan != null)
            TextButton(
              onPressed: () {
                context.read<RetirementViewModel>().deleteRetirementPlan();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete Plan'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final viewModel = context.read<RetirementViewModel>();
                final plan = RetirementModel(
                  id: existingPlan?.id ?? '',
                  userId: viewModel.authViewModel.currentUser!.id,
                  currentAge: currentAge,
                  retirementAge: retirementAge,
                  currentSavings: currentSavings,
                  monthlyContribution: monthlyContribution,
                  expectedAnnualReturn: expectedAnnualReturn,
                  inflationRate: inflationRate,
                  desiredRetirementIncome: desiredRetirementIncome,
                  createdAt: existingPlan?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                viewModel.saveRetirementPlan(plan);
                Navigator.pop(context);
              }
            },
            child: Text(existingPlan == null ? 'Create Plan' : 'Save Changes'),
          ),
        ],
      ),
    );
  }
}
