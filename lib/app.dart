import 'package:finance_tracker/data/providers/budget_provider.dart';
import 'package:finance_tracker/viewmodels/account_card_viewmodel.dart';
import 'package:finance_tracker/viewmodels/ad_service_viewmodel.dart';
import 'package:finance_tracker/viewmodels/asset_liability_viewmodel.dart';
import 'package:finance_tracker/viewmodels/auth_viewmodel.dart';
import 'package:finance_tracker/viewmodels/budget_viewmodel.dart';
import 'package:finance_tracker/viewmodels/debt_viewmodel.dart';
import 'package:finance_tracker/viewmodels/locale_view_model.dart';
import 'package:finance_tracker/viewmodels/profile_viewmodel.dart';
import 'package:finance_tracker/viewmodels/projection_viewmodel.dart';
import 'package:finance_tracker/viewmodels/retirement_viewmodel.dart';
import 'package:finance_tracker/viewmodels/savings_goal_viewmodel.dart';
import 'package:finance_tracker/viewmodels/settlement_viewmodel.dart';
import 'package:finance_tracker/viewmodels/split_view_model.dart';
import 'package:finance_tracker/viewmodels/subscription_viewmodel.dart';
import 'package:finance_tracker/viewmodels/theme_provider.dart';
import 'package:finance_tracker/viewmodels/transaction_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/theme_constants.dart';
import 'core/routes/routes.dart';
import 'core/services/localization_service.dart';
import 'core/services/notification_settings_service.dart';
import 'core/services/session_manager.dart';
import 'presentation/views/session_wrapper.dart';

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final NotificationSettingsService notificationSettingsService;

  const MyApp({
    super.key,
    required this.prefs,
    required this.notificationSettingsService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NotificationSettingsService>(
          create: (_) => notificationSettingsService,
        ),
        Provider<SessionManager>(
          create: (_) => SessionManager(prefs: prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => AdViewModel()
            ..loadBannerAd()
            ..loadInterstitialAd(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => LocaleViewModel()),
        ChangeNotifierProvider(
            create: (_) =>
                SplitTransactionViewModel(authViewModel: AuthViewModel())),
        ChangeNotifierProvider(
            create: (_) => NotificationSettingsService(prefs)),
        ChangeNotifierProvider(create: (_) => SessionManager(prefs: prefs)),
        ChangeNotifierProxyProvider<AuthViewModel, TransactionViewModel>(
          create: (context) => TransactionViewModel(
            authViewModel: context.read<AuthViewModel>(),
            settingsService: notificationSettingsService,
          ),
          update: (context, authVM, transactionVM) =>
              transactionVM ??
              TransactionViewModel(
                authViewModel: authVM,
                settingsService: notificationSettingsService,
              ),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, AssetLiabilityViewModel>(
          create: (context) => AssetLiabilityViewModel(
            authViewModel: context.read<AuthViewModel>(),
          ),
          update: (context, auth, previous) => AssetLiabilityViewModel(
            authViewModel: auth,
            repository: previous?.repository,
          ),
        ),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProxyProvider2<AuthViewModel, TransactionViewModel,
            BudgetViewModel>(
          create: (context) => BudgetViewModel(
            authViewModel: context.read<AuthViewModel>(),
            transactionViewModel: context.read<TransactionViewModel>(),
            settingsService: notificationSettingsService,
          ),
          update: (context, authVM, transactionVM, budgetVM) =>
              budgetVM ??
              BudgetViewModel(
                authViewModel: authVM,
                transactionViewModel: transactionVM,
                settingsService: notificationSettingsService,
              ),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, SettlementViewModel>(
          create: (context) => SettlementViewModel(
            authViewModel: Provider.of<AuthViewModel>(context, listen: false),
          ),
          update: (context, authViewModel, settlementViewModel) =>
              SettlementViewModel(
            authViewModel: authViewModel,
          ),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, AccountCardViewModel>(
          create: (context) => AccountCardViewModel(
            authViewModel: context.read<AuthViewModel>(),
          ),
          update: (context, auth, previous) => AccountCardViewModel(
            authViewModel: auth,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProjectionViewModel(
            transactionVM: context.read<TransactionViewModel>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SavingsGoalViewModel(
            authViewModel: context.read<AuthViewModel>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DebtViewModel(
            authViewModel: context.read<AuthViewModel>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => RetirementViewModel(
            authViewModel: context.read<AuthViewModel>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileViewModel(
            authViewModel: context.read<AuthViewModel>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SubscriptionViewModel(
            authViewModel: context.read<AuthViewModel>(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final localeViewModel = Provider.of<LocaleViewModel>(context);
          // If still loading, show loading indicator
          if (localeViewModel.isLoading) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          Locale appLocale;
          if (localeViewModel.isSystemDefault) {
            // Use the system locale, but ensure it's a supported one
            appLocale = LocalizationService.supportedLocales.firstWhere(
              (locale) =>
                  locale.languageCode ==
                  WidgetsBinding.instance.window.locale.languageCode,
              orElse: () => const Locale('en', ''),
            );
          } else {
            // Use the selected locale
            appLocale = localeViewModel.locale!;
          }
          return MaterialApp(
            title: 'NetWorth+',
            theme: ThemeConstants.lightTheme,
            darkTheme: ThemeConstants.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: appLocale,
            supportedLocales: LocalizationService.supportedLocales,
            localizationsDelegates: LocalizationService.localizationDelegates,
            debugShowCheckedModeBanner: false,
            home: const SessionWrapper(),
            onGenerateRoute: RouteGenerator.getRoute,
          );
        },
      ),
    );
  }
}
