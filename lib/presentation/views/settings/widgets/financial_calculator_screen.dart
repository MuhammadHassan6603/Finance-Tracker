import 'dart:math';

import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/widgets/custom_text_field.dart';
import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FinancialCalculatorScreen extends StatelessWidget {
  const FinancialCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppbar(title: 'Financial Calculator'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCalculatorCard(
              context,
              'Loan Calculator',
              'Calculate loan payments and total interest',
              Icons.account_balance,
              () => _showLoanCalculator(context),
            ),
            const Gap(16),
            _buildCalculatorCard(
              context,
              'Investment Calculator',
              'Calculate investment growth and returns',
              Icons.trending_up,
              () => _showInvestmentCalculator(context),
            ),
            const Gap(16),
            _buildCalculatorCard(
              context,
              'Savings Goal Calculator',
              'Calculate monthly savings needed',
              Icons.savings,
              () => _showSavingsGoalCalculator(context),
            ),
            const Gap(16),
            _buildCalculatorCard(
              context,
              'Mortgage Calculator',
              'Calculate mortgage payments and amortization',
              Icons.home,
              () => _showMortgageCalculator(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showLoanCalculator(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    double loanAmount = 0;
    double interestRate = 0;
    int loanTerm = 0;

    final currency = Helpers.storeCurrency(context);

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Loan Calculator'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  labelText: 'Loan Amount',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter amount';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) => loanAmount = double.parse(value!),
                ),
                CustomTextField(
                  labelText: 'Annual Interest Rate (%)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter rate';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid rate';
                    }
                    return null;
                  },
                  onSaved: (value) => interestRate = double.parse(value!),
                ),
                CustomTextField(
                  labelText: 'Loan Term (months)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter term';
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid term';
                    }
                    return null;
                  },
                  onSaved: (value) => loanTerm = int.parse(value!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final monthlyPayment = _calculateLoanPayment(
                  loanAmount,
                  interestRate,
                  loanTerm,
                );
                final totalInterest = (monthlyPayment * loanTerm) - loanAmount;
                
                _showResults(
                  dialogContext,
                  'Loan Calculation Results',
                  [
                    'Monthly Payment: ${Helpers.formatAmount(monthlyPayment, currency)}',
                    'Total Interest: ${Helpers.formatAmount(totalInterest, currency)}',
                    'Total Payment: ${Helpers.formatAmount(monthlyPayment * loanTerm, currency)}',
                  ],
                );
              }
            },
            child: const Text('Calculate'),
          ),
        ],
      ),
    );
  }

  Future<void> _showInvestmentCalculator(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    double initialInvestment = 0;
    double monthlyContribution = 0;
    double annualReturn = 0;
    int investmentPeriod = 0;

    final currency = Helpers.storeCurrency(context);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Investment Calculator'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  labelText: 'Initial Investment',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter amount';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) => initialInvestment = double.parse(value!),
                ),
                CustomTextField(
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
                  labelText: 'Annual Return Rate (%)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter rate';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid rate';
                    }
                    return null;
                  },
                  onSaved: (value) => annualReturn = double.parse(value!),
                ),
                CustomTextField(
                  labelText: 'Investment Period (years)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter period';
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid period';
                    }
                    return null;
                  },
                  onSaved: (value) => investmentPeriod = int.parse(value!),
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
                final futureValue = _calculateInvestmentGrowth(
                  initialInvestment,
                  monthlyContribution,
                  annualReturn,
                  investmentPeriod,
                );
                final totalContributions = initialInvestment +
                    (monthlyContribution * 12 * investmentPeriod);
                final totalEarnings = futureValue - totalContributions;
                
                _showResults(
                  context,
                  'Investment Calculation Results',
                  [
                    'Future Value: ${Helpers.formatAmount(futureValue, currency)}',
                    'Total Contributions: ${Helpers.formatAmount(totalContributions, currency)}',
                    'Total Earnings: ${Helpers.formatAmount(totalEarnings, currency)}',
                  ],
                );
              }
            },
            child: const Text('Calculate'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSavingsGoalCalculator(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    double goalAmount = 0;
    int months = 0;
    double annualReturn = 0;
    double initialSavings = 0;

    final currency = Helpers.storeCurrency(context);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Savings Goal Calculator'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  labelText: 'Goal Amount',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter amount';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) => goalAmount = double.parse(value!),
                ),
                CustomTextField(
                  labelText: 'Time to Goal (months)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter months';
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid number of months';
                    }
                    return null;
                  },
                  onSaved: (value) => months = int.parse(value!),
                ),
                CustomTextField(
                  labelText: 'Annual Return Rate (%)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter rate';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid rate';
                    }
                    return null;
                  },
                  onSaved: (value) => annualReturn = double.parse(value!),
                ),
                CustomTextField(
                  labelText: 'Initial Savings',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter amount';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) => initialSavings = double.parse(value!),
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
                final monthlyAmount = _calculateRequiredSavings(
                  goalAmount,
                  months,
                  annualReturn,
                  initialSavings,
                );
                
                _showResults(
                  context,
                  'Savings Goal Calculation Results',
                  [
                    'Required Monthly Savings: ${Helpers.formatAmount(monthlyAmount, currency)}',
                    'Total Savings Needed: ${Helpers.formatAmount(goalAmount - initialSavings, currency)}',
                    'Time to Goal: $months months',
                  ],
                );
              }
            },
            child: const Text('Calculate'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMortgageCalculator(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    double homePrice = 0;
    double downPayment = 0;
    double interestRate = 0;
    int loanTerm = 30;

    final currency = Helpers.storeCurrency(context);

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mortgage Calculator'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  labelText: 'Home Price',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter price';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                  onSaved: (value) => homePrice = double.parse(value!),
                ),
                CustomTextField(
                  labelText: 'Down Payment',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter amount';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                  onSaved: (value) => downPayment = double.parse(value!),
                ),
                CustomTextField(
                  labelText: 'Annual Interest Rate (%)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter rate';
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid rate';
                    }
                    return null;
                  },
                  onSaved: (value) => interestRate = double.parse(value!),
                ),
                CustomTextField(
                  initialValue: '30',
                  labelText: 'Loan Term (years)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Please enter term';
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid term';
                    }
                    return null;
                  },
                  onSaved: (value) => loanTerm = int.parse(value!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final loanAmount = homePrice - downPayment;
                final monthlyPayment = _calculateLoanPayment(
                  loanAmount,
                  interestRate,
                  loanTerm * 12,
                );
                final totalInterest =
                    (monthlyPayment * loanTerm * 12) - loanAmount;
                
                _showResults(
                  dialogContext,
                  'Mortgage Calculation Results',
                  [
                    'Monthly Payment: ${Helpers.formatAmount(monthlyPayment, currency)}',
                    'Total Interest: ${Helpers.formatAmount(totalInterest, currency)}',
                    'Total Cost: ${Helpers.formatAmount(homePrice + totalInterest, currency)}',
                    'Down Payment: ${(downPayment / homePrice * 100).toStringAsFixed(1)}%',
                  ],
                );
              }
            },
            child: const Text('Calculate'),
          ),
        ],
      ),
    );
  }

  Future<void> _showResults(
    BuildContext context,
    String title,
    List<String> results,
  ) {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: results.map((result) => Text(result)).toList(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  double _calculateLoanPayment(
    double principal,
    double annualRate,
    int months,
  ) {
    final monthlyRate = annualRate / 1200; // Convert annual rate to monthly
    final payment = principal *
        (monthlyRate * pow(1 + monthlyRate, months)) /
        (pow(1 + monthlyRate, months) - 1);
    return payment;
  }

  double _calculateInvestmentGrowth(
    double initial,
    double monthlyContribution,
    double annualReturn,
    int years,
  ) {
    final monthlyRate = annualReturn / 1200;
    final months = years * 12;
    final futureValueInitial = initial * pow(1 + monthlyRate, months);
    final futureValueContributions = monthlyContribution *
        ((pow(1 + monthlyRate, months) - 1) / monthlyRate);
    return futureValueInitial + futureValueContributions;
  }

  double _calculateRequiredSavings(
    double goalAmount,
    int months,
    double annualReturn,
    double initialAmount,
  ) {
    final monthlyRate = annualReturn / 1200;
    final remainingAmount = goalAmount - initialAmount;
    final monthlyPayment =
        remainingAmount * (monthlyRate / (pow(1 + monthlyRate, months) - 1));
    return monthlyPayment;
  }
}
