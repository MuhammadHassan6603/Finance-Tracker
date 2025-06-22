import 'package:finance_tracker/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../data/models/account_card_model.dart';
import '../../../../viewmodels/account_card_viewmodel.dart';
import '../../../../widgets/app_header_text.dart';
import '../../../../widgets/custom_loader.dart';
import '../../cards/add_card_sheet.dart';
import '../../cards/card_details_screen.dart';

class AccountCardsWidget extends StatelessWidget {
  const AccountCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Consumer<AccountCardViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CustomLoadingOverlay());
        }

        if (viewModel.error != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeaderText(
                text: localization.yourCardsAndAccounts,
                fontSize: 18,
              ),
              const Gap(16),
              Center(
                child: Column(
                  children: [
                    Text(
                      viewModel.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const Gap(8),
                    ElevatedButton(
                      onPressed: () => viewModel.reloadAccountCards(),
                      child: Text(localization.retryButton),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeaderText(
              text: localization.yourCardsAndAccounts,
              fontSize: 18,
            ),
            const Gap(16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: viewModel.accountCards.length + 1,
                itemBuilder: (context, index) {
                  if (index == viewModel.accountCards.length) {
                    return _buildAddCardButton(context);
                  }
                  return _buildCardItem(viewModel.accountCards[index], context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardItem(AccountCardModel card, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currencyCode = context.watch<SessionManager>().selectedCurrency;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardDetailsScreen(card: card),
          ),
        );
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: card.color.withOpacity(isDarkMode ? 0.8 : 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(card.icon, color: card.color),
                Text(
                  card.type,
                  style: TextStyle(
                    color: isDarkMode
                        ? ThemeConstants.textSecondaryDark
                        : ThemeConstants.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              card.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? ThemeConstants.textPrimaryDark
                        : ThemeConstants.textPrimaryLight,
                  ),
            ),
            const Gap(4),
            Text(
              card.number,
              style: TextStyle(
                color: isDarkMode
                    ? ThemeConstants.textSecondaryDark
                    : ThemeConstants.textSecondaryLight,
              ),
            ),
            const Gap(8),
            Text(
              '$currencyCode${card.balance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? ThemeConstants.textPrimaryDark
                        : ThemeConstants.textPrimaryLight,
                  ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                card.accountName,
                style: TextStyle(
                  color: isDarkMode
                      ? ThemeConstants.textSecondaryDark
                      : ThemeConstants.textSecondaryLight,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddCardButton(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localization = AppLocalizations.of(context);
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? ThemeConstants.cardDark : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddCardSheet(),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: isDarkMode
                  ? ThemeConstants.textSecondaryDark
                  : ThemeConstants.textSecondaryLight,
            ),
            const SizedBox(height: 8),
            Text(
              localization.addNewCard,
              style: TextStyle(
                color: isDarkMode
                    ? ThemeConstants.textSecondaryDark
                    : ThemeConstants.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
