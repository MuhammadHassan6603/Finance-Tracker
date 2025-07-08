import 'package:finance_tracker/core/constants/theme_constants.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/presentation/views/dashboard/widgets/activity_search_screen.dart';
import 'package:finance_tracker/presentation/views/portfolio_screen/portfolio_screen.dart';
import 'package:finance_tracker/presentation/views/settings/settings_view.dart';
import 'package:finance_tracker/widgets/app_header_text.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/dashboard_viewmodel.dart';
import '../budget/add_budget_sheet.dart';
import '../budget/budget_screen.dart';
import 'add_transaction_sheet_new.dart';
import '../home/home_screen.dart';
import '../notifications/notifications_screen.dart';
import '../portfolio_screen/widgets/add_asset_liability_sheet.dart';
import '../transaction/transaction_screen.dart';
import '../../../../viewmodels/asset_liability_viewmodel.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: const DashboardViewContent(),
    );
  }
}

class DashboardViewContent extends StatefulWidget {
  const DashboardViewContent({super.key});

  @override
  State<DashboardViewContent> createState() => _DashboardViewContentState();
}

class _DashboardViewContentState extends State<DashboardViewContent> {
  int _selectedIndex = 0;
  String searchText = "";
  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionScreen(),
    const BudgetScreen(),
    const PortfolioScreen(),
  ];

  final List<String> _screenTitles = [
    'NetWorth+',
    'Transaction',
    'Budget',
    'Portfolio',
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localisation = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _screenTitles[_selectedIndex],
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal_outline, size: 20),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ActivitySearchScreen()),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'notifications',
                child: Row(
                  children: [
                    Icon(
                      Iconsax.notification_outline,
                      size: 20,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    const SizedBox(width: 12),
                    Text(localisation.notificationsTitle),
                    // const SizedBox(width: 8),
                    // Container(
                    //   padding: const EdgeInsets.all(6),
                    //   decoration: BoxDecoration(
                    //     color: Theme.of(context).colorScheme.primary,
                    //     shape: BoxShape.circle,
                    //   ),
                    //   child: Text(
                    //     '3',
                    //     style: TextStyle(
                    //       color: isDarkMode ? Colors.black : Colors.white,
                    //       fontSize: 12,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(
                      Iconsax.setting_2_outline,
                      size: 20,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    const SizedBox(width: 12),
                    Text(localisation.settingsTitle),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'notifications':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                  break;
                case 'settings':
                  // Navigate to settings screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsView(),
                    ),
                  );
                  break;
              }
            },
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0,
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0 || _selectedIndex == 1) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (context) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: const AddTransactionSheet(),
              ),
            );
          } else if (_selectedIndex == 2) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (context) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: const AddBudgetSheet(
                  categoryName: 'Category',
                  categoryIcon: Iconsax.category_outline,
                ),
              ),
            );
          } else if (_selectedIndex == 3) {
            // Show a dialog to choose between Asset and Liability
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: AppHeaderText(
                    text: localisation.whatWouldYouLikeToAdd, fontSize: 18),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading:
                          const Icon(Icons.arrow_upward, color: Colors.green),
                      title: Text(localisation.addAsset),
                      onTap: () {
                        Navigator.pop(dialogContext); // Close dialog
                        // Store the ViewModel reference before showing bottom sheet
                        final viewModel = Provider.of<AssetLiabilityViewModel>(
                            context,
                            listen: false);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              const AddAssetLiabilitySheet(isAsset: true),
                        ).then((_) {
                          // Check if the widget is still mounted before calling reloadItems
                          if (mounted) {
                            viewModel.reloadItems();
                          }
                        });
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.arrow_downward, color: Colors.red),
                      title: Text(localisation.addLiability),
                      onTap: () {
                        Navigator.pop(dialogContext); // Close dialog
                        // Store the ViewModel reference before showing bottom sheet
                        final viewModel = Provider.of<AssetLiabilityViewModel>(
                            context,
                            listen: false);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              const AddAssetLiabilitySheet(isAsset: false),
                        ).then((_) {
                          // Check if the widget is still mounted before calling reloadItems
                          if (mounted) {
                            viewModel.reloadItems();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 28,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        height: 65,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.dashboard, localisation.homeTitle),
            _buildNavItem(
                1, Icons.sync_alt_outlined, localisation.transactionsTitle),
            const SizedBox(width: 30), // Space for FAB
            _buildNavItem(2, Icons.account_balance_wallet_outlined,
                localisation.budgetTitle),
            _buildNavItem(
                3, Icons.work_outline_rounded, localisation.portfolio),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : isDarkMode
                      ? ThemeConstants.textSecondaryDark
                      : ThemeConstants.textSecondaryLight,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : isDarkMode
                          ? ThemeConstants.textPrimaryDark
                          : ThemeConstants.textPrimaryLight,
                  fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
