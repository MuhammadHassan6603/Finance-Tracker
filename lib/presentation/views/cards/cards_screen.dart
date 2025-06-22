import 'package:finance_tracker/data/models/account_card_model.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/console.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../viewmodels/account_card_viewmodel.dart';
import 'add_card_sheet.dart';
import 'card_details_screen.dart';
import 'transfer_sheet.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<AccountCardViewModel>(context, listen: false);
    if (viewModel.currentUserId != null) {
      viewModel.reloadAccountCards();
    }
    // The AccountCardViewModel now handles user ID automatically
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final viewModel = Provider.of<AccountCardViewModel>(context, listen: false);
  //   if (viewModel.currentUserId != null) {
  //     viewModel.reloadAccountCards();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<AccountCardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${viewModel.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.reloadAccountCards();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).yourCardsAndAccounts,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? ThemeConstants.textPrimaryDark
                            : ThemeConstants.textPrimaryLight,
                      ),
                ),
                const SizedBox(height: 16),
                _buildCardsList(viewModel),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildRecentTransactions(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddCardSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCardsList(AccountCardViewModel viewModel) {
    final cards = viewModel.accountCards;
    console('${cards.length} cards loaded', type: DebugType.info);
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length + 1,
        itemBuilder: (context, index) {
          if (index == cards.length) {
            return _buildAddCardButton();
          }
          return _buildCardItem(cards[index]);
        },
      ),
    );
  }

  Widget _buildCardItem(AccountCardModel card) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: card.color.withOpacity(isDarkMode ? 0.8 : 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 4),
            Text(
              card.number,
              style: TextStyle(
                color: isDarkMode
                    ? ThemeConstants.textSecondaryDark
                    : ThemeConstants.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${card.balance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? ThemeConstants.textPrimaryDark
                        : ThemeConstants.textPrimaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCardButton() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              'Add New Card',
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

  Widget _buildQuickActions() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? ThemeConstants.textPrimaryDark
                    : ThemeConstants.textPrimaryLight,
              ),
        ),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              icon: Icons.swap_horiz,
              label: 'Transfer',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const TransferSheet(),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.receipt_long,
              label: 'Statements',
              onTap: () {},
            ),
            _buildActionButton(
              icon: Icons.qr_code_scanner,
              label: 'Scan & Pay',
              onTap: () {},
            ),
            _buildActionButton(
              icon: Icons.more_horiz,
              label: 'More',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? ThemeConstants.cardDark : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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

  Widget _buildRecentTransactions() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? ThemeConstants.textPrimaryDark
                    : ThemeConstants.textPrimaryLight,
              ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return _buildTransactionItem();
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.swap_horiz,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transfer to Savings',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? ThemeConstants.textPrimaryDark
                        : ThemeConstants.textPrimaryLight,
                  ),
                ),
                Text(
                  'May 15, 2024',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? ThemeConstants.textSecondaryDark
                        : ThemeConstants.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '- ₹5,000.00',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
