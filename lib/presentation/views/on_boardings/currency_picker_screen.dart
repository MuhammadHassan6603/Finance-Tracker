import 'package:currency_picker/currency_picker.dart';
import 'package:finance_tracker/core/services/session_manager.dart';
import 'package:finance_tracker/widgets/custom_button.dart';
import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/routes.dart';

class CurrencyPickerScreen extends StatefulWidget {
  final bool isFromSettings;

  const CurrencyPickerScreen({
    super.key,
    this.isFromSettings = false,
  });

  @override
  State<CurrencyPickerScreen> createState() => _CurrencyPickerScreenState();
}

class _CurrencyPickerScreenState extends State<CurrencyPickerScreen> {
  Currency? selectedCurrency;

  @override
  void initState() {
    super.initState();
    // Load current currency if exists
    final currentCurrencyCode = context.read<SessionManager>().selectedCurrency;
    if (currentCurrencyCode != null) {
      final currencies = CurrencyService().findByCode(currentCurrencyCode);
      if (currencies != null) {
        setState(() {
          selectedCurrency = currencies;
        });
      }
    }
  }

  void _selectCurrency(BuildContext context, Currency currency) async {
    final sessionManager = context.read<SessionManager>();
    await sessionManager.setSelectedCurrency(currency.symbol);

    if (mounted) {
      setState(() {
        selectedCurrency = currency;
      });

      if (widget.isFromSettings) {
        // If coming from settings, just go back
        Navigator.pop(context);
      } else {
        // If from onboarding, go to login instead of dashboard
        Navigator.pushReplacementNamed(context, Routes.signIn);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isFromSettings
          ? const SharedAppbar(
              title: 'Change Currency',
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!widget.isFromSettings) ...[
                const Gap(40),
                Text(
                  'Select Your Currency',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const Gap(16),
                Text(
                  'Choose your preferred currency to get started. '
                  'This will be used for all your financial transactions and reports.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
              ],
              const Gap(24),
              if (selectedCurrency != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedCurrency?.flag ?? '',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${selectedCurrency!.code} (${selectedCurrency!.symbol})',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            selectedCurrency!.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    CustomButton(
                      onPressed: () {
                        showCurrencyPicker(
                          context: context,
                          showFlag: true,
                          showCurrencyName: true,
                          showCurrencyCode: true,
                          theme: CurrencyPickerThemeData(
                            flagSize: 25,
                            titleTextStyle:
                                Theme.of(context).textTheme.titleLarge,
                            subtitleTextStyle:
                                Theme.of(context).textTheme.bodyMedium,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                          ),
                          onSelect: (Currency currency) {
                            _selectCurrency(context, currency);
                          },
                        );
                      },
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        selectedCurrency == null
                            ? 'Select Currency'
                            : 'Change Currency',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!widget.isFromSettings && selectedCurrency != null) ...[
                      const Gap(16),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, Routes.signIn);
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }
}
