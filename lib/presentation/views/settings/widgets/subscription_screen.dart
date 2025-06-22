import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/data/models/subscription_model.dart';
import 'package:finance_tracker/viewmodels/subscription_viewmodel.dart';
import 'package:finance_tracker/widgets/app_header_text.dart';
import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppbar(title: 'Subscription Plan'),
      body: Consumer<SubscriptionViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentPlan(context, viewModel),
                const Gap(24),
                _buildAvailablePlans(context, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentPlan(BuildContext context, SubscriptionViewModel viewModel) {
    final subscription = viewModel.currentSubscription;
    final isExpired = subscription?.isExpired ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeaderText(text: 'Current Plan', fontSize: 20),
            const Gap(16),
            Row(
              children: [
                Icon(
                  Icons.card_membership,
                  color: isExpired ? Colors.red : Theme.of(context).primaryColor,
                  size: 32,
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription?.type.toString().split('.').last
                                .toUpperCase() ??
                            'FREE',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (subscription != null && !isExpired) ...[
                        const Gap(4),
                        Text(
                          '${subscription.daysRemaining} days remaining',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (isExpired)
                        Text(
                          'Expired',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailablePlans(
      BuildContext context, SubscriptionViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppHeaderText(text: 'Available Plans', fontSize: 20),
        const Gap(16),
        _buildPlanCard(
          context,
          'Basic Plan',
          'Perfect for personal finance tracking',
          [
            'Unlimited transactions',
            'Basic reports',
            'Email support',
          ],
          9.99,
          () => _showSubscriptionDialog(context, SubscriptionType.basic, 9.99),
        ),
        const Gap(16),
        _buildPlanCard(
          context,
          'Premium Plan',
          'Advanced features for power users',
          [
            'Everything in Basic',
            'Advanced analytics',
            'Priority support',
            'Custom categories',
            'Data export',
          ],
          19.99,
          () => _showSubscriptionDialog(context, SubscriptionType.premium, 19.99),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    String title,
    String subtitle,
    List<String> features,
    double price,
    VoidCallback onSubscribe,
  ) {
    final currency = Helpers.storeCurrency(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Gap(16),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check, size: 16),
                      const Gap(8),
                      Text(feature),
                    ],
                  ),
                )),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currency$price/month',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton(
                  onPressed: onSubscribe,
                  child: const Text('Subscribe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSubscriptionDialog(
    BuildContext context,
    SubscriptionType type,
    double amount,
  ) async {
    final viewModel = context.read<SubscriptionViewModel>();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to subscribe to the ${type.toString().split('.').last} plan.'),
            const Gap(16),
            Text(
              'Amount: ${Helpers.formatCurrency( amount)}/month',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // In a real app, you would integrate with a payment provider here
              await viewModel.updateSubscription(
                type,
                amount,
                DateTime.now().add(const Duration(days: 30)),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subscription updated successfully'),
                  ),
                );
              }
            },
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }
}