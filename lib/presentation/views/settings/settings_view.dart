import 'package:finance_tracker/core/routes/routes.dart';
import 'package:finance_tracker/core/services/session_manager.dart';
import 'package:finance_tracker/core/utils/motion_toast.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/presentation/views/on_boardings/currency_picker_screen.dart';
import 'package:finance_tracker/presentation/views/settings/widgets/budget_vs_actual_screen.dart';
import 'package:finance_tracker/presentation/views/settings/widgets/debt_repayment_screen.dart';
import 'package:finance_tracker/presentation/views/settings/widgets/download_report_screen.dart';
import 'package:finance_tracker/presentation/views/settings/widgets/financial_calculator_screen.dart';
import 'package:finance_tracker/presentation/views/settings/widgets/future_projections_screen.dart';
import 'package:finance_tracker/presentation/views/settings/widgets/income_expense_analysis_screen.dart';
import 'package:finance_tracker/presentation/views/settings/widgets/language_selector_screen.dart';
import 'package:finance_tracker/presentation/views/settings/widgets/notification_toggle.dart';
import 'package:finance_tracker/presentation/views/settings/widgets/past_performance_screen.dart';
import 'package:finance_tracker/presentation/views/settings/widgets/privacy_policy_screen.dart';
import 'package:finance_tracker/presentation/views/settings/widgets/profile_screen.dart';
import 'package:finance_tracker/presentation/views/settings/widgets/retirement_planning_screen.dart';
import 'package:finance_tracker/presentation/views/settings/widgets/savings_goal_screen.dart';
import 'package:finance_tracker/presentation/views/settings/widgets/subscription_screen.dart';
import 'package:finance_tracker/presentation/views/settings/widgets/terms_of_service_screen.dart';
import 'package:finance_tracker/viewmodels/auth_viewmodel.dart';
import 'package:finance_tracker/viewmodels/theme_provider.dart';
import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:finance_tracker/widgets/shared_dynamic_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/ad_service_viewmodel.dart';
import 'widgets/settings_tile.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
    Provider.of<AdViewModel>(context, listen: false).loadInterstitialAd();
  }

  void _showAdIfLoaded() {
    final adViewModel = Provider.of<AdViewModel>(context, listen: false);

    if (adViewModel.isInterstitialAdLoaded) {
      adViewModel.interstitialAd!.show();
      adViewModel.loadInterstitialAd();
    } else {
      ToastUtils.showWarningToast(context,
          title: 'Wait', description: 'Ad not ready yet');
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: SharedAppbar(title: local.settings),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Column(
            children: [
              _buildProfileSection(context),
              const SizedBox(height: 24),
              _buildSupportSection(context),
              const SizedBox(height: 16),
              _SettingsSection(
                title: local.reportsAndAnalytics,
                children: [
                  SettingsTile(
                    title: local.futureProjections,
                    subtitle: local.viewFinancialForecastsAndTrends,
                    leading: _buildIconContainer(context, Icons.trending_up),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FutureProjectionsScreen(),
                        ),
                      );
                    },
                  ),
                  SettingsTile(
                    title: local.pastPerformance,
                    subtitle: local.historicalFinancialAnalysis,
                    leading: _buildIconContainer(context, Icons.history),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PastPerformanceScreen(),
                        ),
                      );
                    },
                  ),
                  SettingsTile(
                    title: local.incomeAndExpenseAnalysis,
                    subtitle: local.compareIncomeExpensesAndSavings,
                    leading: _buildIconContainer(context, Icons.analytics),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const IncomeExpenseAnalysisScreen(),
                        ),
                      );
                    },
                  ),
                  SettingsTile(
                    title: local.budgetVsActual,
                    subtitle: local.trackBudgetPerformance,
                    leading: _buildIconContainer(context, Icons.compare_arrows),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BudgetVsActualScreen(),
                        ),
                      );
                    },
                  ),
                  SettingsTile(
                    title: local.downloadReports,
                    subtitle: local.exportFinancialReports,
                    leading: _buildIconContainer(context, Icons.download),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DownloadReportsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              _SettingsSection(
                title: local.appPreferences,
                children: [
                  SettingsTile(
                    title: local.currency,
                    subtitle:
                        Provider.of<SessionManager>(context).selectedCurrency ??
                            local.setYourPreferredCurrency,
                    leading:
                        _buildIconContainer(context, Icons.currency_exchange),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CurrencyPickerScreen(
                                isFromSettings: true)),
                      );
                    },
                  ),
                  SettingsTile(
                    title: local.appTheme,
                    subtitle: isDarkMode ? local.darkMode : local.lightMode,
                    leading: _buildIconContainer(
                        context,
                        isDarkMode
                            ? Icons.nights_stay_outlined
                            : Icons.wb_sunny_outlined),
                    trailing: Switch(
                      value: isDarkMode,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
                  ),
                  SettingsTile(
                    title: local.language,
                    subtitle: local.chooseYourPreferredLanguage,
                    leading: _buildIconContainer(context, Icons.language),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LanguageSelectorScreen()));
                    },
                  ),
                  // SettingsTile(
                  //   title: 'Theme Customization',
                  //   subtitle: 'Customize app appearance',
                  //   leading:
                  //       _buildIconContainer(context, Icons.palette_outlined),
                  //   onTap: () {},
                  // ),
                ],
              ),
              _SettingsSection(
                title: local.notifications,
                children: [
                  SettingsTile(
                    title: local.budgetLimits,
                    subtitle: local.getAlertsWhenNearingBudgetLimits,
                    leading: _buildIconContainer(context, Icons.warning_amber),
                    trailing: const NotificationToggle(type: 'budget_limits'),
                  ),
                  SettingsTile(
                    title: local.billPaymentReminders,
                    subtitle: local.neverMissAPaymentDeadline,
                    leading: _buildIconContainer(context, Icons.calendar_today),
                    trailing: const NotificationToggle(type: 'bill_payment'),
                  ),
                ],
              ),
              _SettingsSection(
                title: local.planningAndFinancialGoals,
                children: [
                  SettingsTile(
                    title: local.savingsGoals,
                    subtitle: local.setAndTrackSavingsTargets,
                    leading: _buildIconContainer(context, Icons.savings),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavingsGoalsScreen(),
                        ),
                      );
                    },
                  ),
                  SettingsTile(
                    title: local.debtRepaymentPlan,
                    subtitle: local.manageAndTrackDebtPayments,
                    leading:
                        _buildIconContainer(context, Icons.account_balance),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DebtRepaymentScreen(),
                        ),
                      );
                    },
                  ),
                  SettingsTile(
                    title: local.retirementPlanning,
                    subtitle: local.planForYourRetirement,
                    leading: _buildIconContainer(context, Icons.beach_access),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RetirementPlanningScreen(),
                        ),
                      );
                    },
                  ),
                  SettingsTile(
                    title: local.financialCalculator,
                    subtitle: local.calculateLoansInvestmentsAndMore,
                    leading: _buildIconContainer(context, Icons.calculate),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FinancialCalculatorScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              _SettingsSection(
                title: local.accountSettings,
                children: [
                  SettingsTile(
                    title: local.profile,
                    subtitle: local.managePersonalInformation,
                    leading: _buildIconContainer(context, Icons.person_outline),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    ),
                  ),
                  // SettingsTile(
                  //   title: local.subscriptionPlan,
                  //   subtitle: local.manageYourSubscription,
                  //   leading:
                  //       _buildIconContainer(context, Icons.card_membership),
                  //   onTap: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => const SubscriptionScreen(),
                  //     ),
                  //   ),
                  // ),
                  // SettingsTile(
                  //   title: local.security,
                  //   subtitle: local.appLockBiometricsAndBackup,
                  //   leading: _buildIconContainer(context, Icons.security),
                  //   onTap: () {},
                  // ),
                  // SettingsTile(
                  //   title: local.dataBackupAndSync,
                  //   subtitle: local.manageYourDataAcrossDevices,
                  //   leading: _buildIconContainer(context, Icons.sync),
                  //   onTap: () {},
                  // ),
                ],
              ),
              _SettingsSection(
                title: local.more,
                children: [
                  // SettingsTile(
                  //   title: local.helpAndSupport,
                  //   subtitle: local.faqContactAndSupport,
                  //   leading: _buildIconContainer(context, Icons.help_outline),
                  //   onTap: () => _showHelpSupportDialog(context),
                  // ),
                  SettingsTile(
                    title: local.termsAndPrivacy,
                    subtitle: local.termsOfService,
                    leading: _buildIconContainer(
                        context, Icons.privacy_tip_outlined),
                    onTap: () => _showTermsPrivacyDialog(context),
                  ),
                  SettingsTile(
                    title: local.aboutApp,
                    subtitle: 'Version 1.0.0+1',
                    leading: _buildIconContainer(context, Icons.info_outline),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'NetWorth+',
                        applicationVersion: '1.0.0+1',
                        applicationIcon: Image.asset(
                            'assets/icons/app_logo.jpg',
                            width: 32,
                            height: 32),
                        children: const [
                          Text(
                            'A comprehensive finance tracking application to manage your expenses, budgets, and financial portfolio.',
                          ),
                        ],
                      );
                    },
                  ),
                  SettingsTile(
                    title: local.signOut,
                    textColor: Colors.red,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.logout_outlined,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () => _handleSignOut(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      local.supportTheApp,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDonationDialog(context),
                        icon: const Icon(Icons.favorite_outline),
                        label: Text(local.donate),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAdIfLoaded(),
                        icon: const Icon(Icons.play_circle_outline),
                        label: Text(local.watchAd),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconContainer(BuildContext context, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final local = AppLocalizations.of(context);
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(local.signOut),
        content: Text(local.areYouSureYouWantToSignOut),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(local.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              local.signOut,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get providers
      final sessionManager = context.read<SessionManager>();
      final authViewModel = context.read<AuthViewModel>();

      // Sign out from both
      await Future.wait([
        sessionManager.signOut(),
        authViewModel.signOut(),
      ]);

      if (context.mounted) {
        // Close loading dialog
        Navigator.pop(context);

        // Navigate to login and clear stack
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.signIn,
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Close loading dialog if it's showing
        Navigator.maybeOf(context)?.pop();

        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildProfileSection(BuildContext context) {
    return Consumer<AuthViewModel>(builder: (context, userProvider, _) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              userProvider.currentUser?.name ?? 'User',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              userProvider.currentUser?.email ?? 'user@gmail.com',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    });
  }

  void _showHelpSupportDialog(BuildContext context) {
    final local = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(local.helpAndSupport),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpSection(
                local.frequentlyAskedQuestions,
                Icons.question_answer_outlined,
                () {
                  Navigator.pop(context);
                  // Navigate to FAQ page
                },
              ),
              const Divider(),
              _buildHelpSection(
                local.contactSupport,
                Icons.email_outlined,
                () {
                  // Launch email client
                  // You can use url_launcher package to implement this
                  // launchUrl(Uri.parse('mailto:support@yourapp.com'));
                },
              ),
              const Divider(),
              _buildHelpSection(
                local.liveChatSupport,
                Icons.chat_outlined,
                () {
                  Navigator.pop(context);
                  // Navigate to chat support
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(local.close),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showTermsPrivacyDialog(BuildContext context) {
    final local = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(local.termsAndPrivacy),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpSection(
                local.termsOfService,
                Icons.description_outlined,
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TermsOfServiceScreen()));
                  // Navigate to Terms of Service page or open URL
                },
              ),
              const Divider(),
              _buildHelpSection(
                local.privacyPolicy,
                Icons.privacy_tip_outlined,
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen()));
                  // Navigate to Privacy Policy page or open URL
                },
              ),
              // const Divider(),
              // _buildHelpSection(
              //   local.dataUsage,
              //   Icons.data_usage_outlined,
              //   () {
              //     Navigator.pop(context);
              //     // Navigate to Data Usage page
              //   },
              // ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(local.close),
          ),
        ],
      ),
    );
  }

  void _showDonationDialog(BuildContext context) {
    final local = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(local.scanToDonate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/test_qrcode.png',
              width: 250,
              height: 250,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(local.close),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
        ),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }
}
