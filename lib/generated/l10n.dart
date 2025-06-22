// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalizations {
  AppLocalizations();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(
      _current != null,
      'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalizations();
      AppLocalizations._current = instance;

      return instance;
    });
  }

  static AppLocalizations of(BuildContext context) {
    final instance = AppLocalizations.maybeOf(context);
    assert(
      instance != null,
      'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `Finance Manager`
  String get appTitle {
    return Intl.message(
      'Finance Manager',
      name: 'appTitle',
      desc: 'The title of the application',
      args: [],
    );
  }

  /// `Dashboard`
  String get homeTitle {
    return Intl.message(
      'Dashboard',
      name: 'homeTitle',
      desc: 'Title for the home screen',
      args: [],
    );
  }

  /// `Transactions`
  String get transactionsTitle {
    return Intl.message(
      'Transactions',
      name: 'transactionsTitle',
      desc: 'Title for the transactions screen',
      args: [],
    );
  }

  /// `Budget`
  String get budgetTitle {
    return Intl.message(
      'Budget',
      name: 'budgetTitle',
      desc: 'Title for the budget screen',
      args: [],
    );
  }

  /// `Portfolio`
  String get portfolio {
    return Intl.message(
      'Portfolio',
      name: 'portfolio',
      desc: 'Label for portfolio section',
      args: [],
    );
  }

  /// `Settings`
  String get settingsTitle {
    return Intl.message(
      'Settings',
      name: 'settingsTitle',
      desc: 'Title for the settings screen',
      args: [],
    );
  }

  /// `Notifications`
  String get notificationsTitle {
    return Intl.message(
      'Notifications',
      name: 'notificationsTitle',
      desc: 'Title for the notifications screen',
      args: [],
    );
  }

  /// `Language`
  String get languageTitle {
    return Intl.message(
      'Language',
      name: 'languageTitle',
      desc: 'Title for the language selection option',
      args: [],
    );
  }

  /// `Income`
  String get incomeLabel {
    return Intl.message(
      'Income',
      name: 'incomeLabel',
      desc: 'Label for income',
      args: [],
    );
  }

  /// `Expenses`
  String get expenseLabel {
    return Intl.message(
      'Expenses',
      name: 'expenseLabel',
      desc: 'Label for expenses',
      args: [],
    );
  }

  /// `Balance`
  String get balanceLabel {
    return Intl.message(
      'Balance',
      name: 'balanceLabel',
      desc: 'Label for the balance field',
      args: [],
    );
  }

  /// `Savings`
  String get savingsLabel {
    return Intl.message(
      'Savings',
      name: 'savingsLabel',
      desc: 'Label for savings',
      args: [],
    );
  }

  /// `Investments`
  String get investmentsLabel {
    return Intl.message(
      'Investments',
      name: 'investmentsLabel',
      desc: 'Label for investments',
      args: [],
    );
  }

  /// `Add Transaction`
  String get addTransaction {
    return Intl.message(
      'Add Transaction',
      name: 'addTransaction',
      desc: 'Button to add a new transaction',
      args: [],
    );
  }

  /// `Category`
  String get categoryLabel {
    return Intl.message(
      'Category',
      name: 'categoryLabel',
      desc: 'Label for category',
      args: [],
    );
  }

  /// `Amount`
  String get amountLabel {
    return Intl.message(
      'Amount',
      name: 'amountLabel',
      desc: 'Label for amount',
      args: [],
    );
  }

  /// `Date`
  String get dateLabel {
    return Intl.message(
      'Date',
      name: 'dateLabel',
      desc: 'Label for date',
      args: [],
    );
  }

  /// `Notes`
  String get notesLabel {
    return Intl.message(
      'Notes',
      name: 'notesLabel',
      desc: 'Label for notes',
      args: [],
    );
  }

  /// `Save`
  String get saveButton {
    return Intl.message(
      'Save',
      name: 'saveButton',
      desc: 'Save button text',
      args: [],
    );
  }

  /// `Cancel`
  String get cancelButton {
    return Intl.message(
      'Cancel',
      name: 'cancelButton',
      desc: 'Cancel button text',
      args: [],
    );
  }

  /// `System Default`
  String get systemDefault {
    return Intl.message(
      'System Default',
      name: 'systemDefault',
      desc: 'System default language option',
      args: [],
    );
  }

  /// `Net Worth`
  String get netWorth {
    return Intl.message(
      'Net Worth',
      name: 'netWorth',
      desc: 'Net Worth label',
      args: [],
    );
  }

  /// `Yearly Growth`
  String get yearlyGrowth {
    return Intl.message(
      'Yearly Growth',
      name: 'yearlyGrowth',
      desc: 'Label for yearly growth',
      args: [],
    );
  }

  /// `vs Last Year`
  String get vsLastYear {
    return Intl.message(
      'vs Last Year',
      name: 'vsLastYear',
      desc: 'Label for comparison with the previous year',
      args: [],
    );
  }

  /// `Growth Trend`
  String get growthTrend {
    return Intl.message(
      'Growth Trend',
      name: 'growthTrend',
      desc: 'Label for growth trend',
      args: [],
    );
  }

  /// `Your Cards & Accounts`
  String get yourCardsAndAccounts {
    return Intl.message(
      'Your Cards & Accounts',
      name: 'yourCardsAndAccounts',
      desc: 'Label for the section displaying cards and accounts',
      args: [],
    );
  }

  /// `Retry`
  String get retryButton {
    return Intl.message(
      'Retry',
      name: 'retryButton',
      desc: 'Button text for retrying an action',
      args: [],
    );
  }

  /// `Add New Card`
  String get addNewCard {
    return Intl.message(
      'Add New Card',
      name: 'addNewCard',
      desc: 'Button text for adding a new card',
      args: [],
    );
  }

  /// `Available balance`
  String get availableBalance {
    return Intl.message(
      'Available balance',
      name: 'availableBalance',
      desc: 'Label for available balance',
      args: [],
    );
  }

  /// `Cash`
  String get cashLabel {
    return Intl.message(
      'Cash',
      name: 'cashLabel',
      desc: 'Label for cash balance',
      args: [],
    );
  }

  /// `Bank`
  String get bankLabel {
    return Intl.message(
      'Bank',
      name: 'bankLabel',
      desc: 'Label for bank balance',
      args: [],
    );
  }

  /// `Upcoming payments`
  String get upcomingPayments {
    return Intl.message(
      'Upcoming payments',
      name: 'upcomingPayments',
      desc: 'Label for upcoming payments section',
      args: [],
    );
  }

  /// `No upcoming payments`
  String get noUpcomingPayments {
    return Intl.message(
      'No upcoming payments',
      name: 'noUpcomingPayments',
      desc: 'Message displayed when there are no upcoming payments',
      args: [],
    );
  }

  /// `Last 30 days`
  String get last30Days {
    return Intl.message(
      'Last 30 days',
      name: 'last30Days',
      desc: 'Label for the last 30 days section',
      args: [],
    );
  }

  /// `Income`
  String get income {
    return Intl.message(
      'Income',
      name: 'income',
      desc: 'Label for income section',
      args: [],
    );
  }

  /// `Expense`
  String get expense {
    return Intl.message(
      'Expense',
      name: 'expense',
      desc: 'Label for expense section',
      args: [],
    );
  }

  /// `Savings`
  String get savings {
    return Intl.message(
      'Savings',
      name: 'savings',
      desc: 'Label for savings section',
      args: [],
    );
  }

  /// `What would you like to add?`
  String get whatWouldYouLikeToAdd {
    return Intl.message(
      'What would you like to add?',
      name: 'whatWouldYouLikeToAdd',
      desc: 'Prompt asking the user what they would like to add',
      args: [],
    );
  }

  /// `Add Asset`
  String get addAsset {
    return Intl.message(
      'Add Asset',
      name: 'addAsset',
      desc: 'Button or label for adding an asset',
      args: [],
    );
  }

  /// `Add Liability`
  String get addLiability {
    return Intl.message(
      'Add Liability',
      name: 'addLiability',
      desc: 'Button or label for adding a liability',
      args: [],
    );
  }

  /// `Report`
  String get report {
    return Intl.message(
      'Report',
      name: 'report',
      desc: 'Label for the report section',
      args: [],
    );
  }

  /// `Settle Up`
  String get settleUp {
    return Intl.message(
      'Settle Up',
      name: 'settleUp',
      desc: 'Button or label for settling up transactions',
      args: [],
    );
  }

  /// `By Category`
  String get byCategory {
    return Intl.message(
      'By Category',
      name: 'byCategory',
      desc: 'Filter option for categorizing items',
      args: [],
    );
  }

  /// `By Date Range`
  String get byDateRange {
    return Intl.message(
      'By Date Range',
      name: 'byDateRange',
      desc: 'Filter option for selecting a date range',
      args: [],
    );
  }

  /// `By Amount`
  String get byAmount {
    return Intl.message(
      'By Amount',
      name: 'byAmount',
      desc: 'Filter option for selecting by amount',
      args: [],
    );
  }

  /// `Available`
  String get available {
    return Intl.message(
      'Available',
      name: 'available',
      desc: 'Label for available items or balance',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: 'Label for error messages or titles',
      args: [],
    );
  }

  /// `No transactions found`
  String get noTransactionsFound {
    return Intl.message(
      'No transactions found',
      name: 'noTransactionsFound',
      desc: 'Message displayed when no transactions are available',
      args: [],
    );
  }

  /// `Payment Method`
  String get paymentMethod {
    return Intl.message(
      'Payment Method',
      name: 'paymentMethod',
      desc: 'Label for selecting a payment method',
      args: [],
    );
  }

  /// `Settlement`
  String get settlement {
    return Intl.message(
      'Settlement',
      name: 'settlement',
      desc: 'Label for settlement details or description',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: 'Label for edit action or button',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: 'Label for the delete action',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message(
      'Success',
      name: 'success',
      desc: 'Label for success messages or titles',
      args: [],
    );
  }

  /// `Transaction updated successfully`
  String get transactionUpdatedSuccessfully {
    return Intl.message(
      'Transaction updated successfully',
      name: 'transactionUpdatedSuccessfully',
      desc: 'Message displayed when a transaction is successfully updated',
      args: [],
    );
  }

  /// `Delete Transaction`
  String get deleteTransaction {
    return Intl.message(
      'Delete Transaction',
      name: 'deleteTransaction',
      desc: 'Label for delete transaction action or button',
      args: [],
    );
  }

  /// `Are you sure you want to delete this transaction?`
  String get confirmDeleteTransaction {
    return Intl.message(
      'Are you sure you want to delete this transaction?',
      name: 'confirmDeleteTransaction',
      desc: 'Confirmation message for deleting a transaction',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: 'Label for cancel action or button',
      args: [],
    );
  }

  /// `Transaction deleted successfully`
  String get transactionDeletedSuccessfully {
    return Intl.message(
      'Transaction deleted successfully',
      name: 'transactionDeletedSuccessfully',
      desc: 'Message displayed when a transaction is successfully deleted',
      args: [],
    );
  }

  /// `Spending by Category`
  String get spendingByCategory {
    return Intl.message(
      'Spending by Category',
      name: 'spendingByCategory',
      desc: 'Title for the spending by category chart',
      args: [],
    );
  }

  /// `No expense data available for selected period`
  String get noExpenseDataAvailable {
    return Intl.message(
      'No expense data available for selected period',
      name: 'noExpenseDataAvailable',
      desc:
          'Message displayed when there is no expense data for the selected period',
      args: [],
    );
  }

  /// `Financial Summary`
  String get financialSummary {
    return Intl.message(
      'Financial Summary',
      name: 'financialSummary',
      desc: 'Title for the financial summary section',
      args: [],
    );
  }

  /// `Total Income`
  String get totalIncome {
    return Intl.message(
      'Total Income',
      name: 'totalIncome',
      desc: 'Label for total income',
      args: [],
    );
  }

  /// `Total Expenses`
  String get totalExpenses {
    return Intl.message(
      'Total Expenses',
      name: 'totalExpenses',
      desc: 'Label for total expenses',
      args: [],
    );
  }

  /// `Net Savings`
  String get netSavings {
    return Intl.message(
      'Net Savings',
      name: 'netSavings',
      desc: 'Label for net savings',
      args: [],
    );
  }

  /// `Operation Failed`
  String get operationFailed {
    return Intl.message(
      'Operation Failed',
      name: 'operationFailed',
      desc: 'Message displayed when an operation fails',
      args: [],
    );
  }

  /// `Add New Settlement`
  String get addNewSettlement {
    return Intl.message(
      'Add New Settlement',
      name: 'addNewSettlement',
      desc: 'Button or label for adding a new settlement',
      args: [],
    );
  }

  /// `No settlements found`
  String get noSettlementsFound {
    return Intl.message(
      'No settlements found',
      name: 'noSettlementsFound',
      desc: 'Message displayed when no settlements are available',
      args: [],
    );
  }

  /// `You owe`
  String get youOwe {
    return Intl.message(
      'You owe',
      name: 'youOwe',
      desc: 'Label indicating that the user owes someone',
      args: [],
    );
  }

  /// `Owes you`
  String get owesYou {
    return Intl.message(
      'Owes you',
      name: 'owesYou',
      desc: 'Label indicating that someone owes the user',
      args: [],
    );
  }

  /// `Person Name`
  String get personName {
    return Intl.message(
      'Person Name',
      name: 'personName',
      desc: 'Label for entering or displaying a person\'s name',
      args: [],
    );
  }

  /// `Amount:`
  String get amount {
    return Intl.message(
      'Amount:',
      name: 'amount',
      desc: 'Label for subscription amount',
      args: [],
    );
  }

  /// `They Owe Me`
  String get theyOweMe {
    return Intl.message(
      'They Owe Me',
      name: 'theyOweMe',
      desc: 'Label indicating that someone owes the user',
      args: [],
    );
  }

  /// `I Owe Them`
  String get iOweThem {
    return Intl.message(
      'I Owe Them',
      name: 'iOweThem',
      desc: 'Label indicating that the user owes someone',
      args: [],
    );
  }

  /// `Invalid Input`
  String get invalidInput {
    return Intl.message(
      'Invalid Input',
      name: 'invalidInput',
      desc: 'Message displayed when the user provides invalid input',
      args: [],
    );
  }

  /// `Please enter a name`
  String get pleaseEnterAName {
    return Intl.message(
      'Please enter a name',
      name: 'pleaseEnterAName',
      desc: 'Message prompting the user to enter a name',
      args: [],
    );
  }

  /// `Invalid Amount`
  String get invalidAmount {
    return Intl.message(
      'Invalid Amount',
      name: 'invalidAmount',
      desc: 'Message indicating that the entered amount is invalid',
      args: [],
    );
  }

  /// `Please enter a valid number`
  String get pleaseEnterAValidNumber {
    return Intl.message(
      'Please enter a valid number',
      name: 'pleaseEnterAValidNumber',
      desc: 'Message prompting the user to enter a valid number',
      args: [],
    );
  }

  /// `Settlement added successfully`
  String get settlementAddedSuccessfully {
    return Intl.message(
      'Settlement added successfully',
      name: 'settlementAddedSuccessfully',
      desc: 'Message displayed when a settlement is successfully added',
      args: [],
    );
  }

  /// `Add Settlement`
  String get addSettlement {
    return Intl.message(
      'Add Settlement',
      name: 'addSettlement',
      desc: 'Button or label for adding a settlement',
      args: [],
    );
  }

  /// `Related Transactions`
  String get relatedTransactions {
    return Intl.message(
      'Related Transactions',
      name: 'relatedTransactions',
      desc: 'Label for the section displaying related transactions',
      args: [],
    );
  }

  /// `Payment marked as completed`
  String get paymentMarkedAsCompleted {
    return Intl.message(
      'Payment marked as completed',
      name: 'paymentMarkedAsCompleted',
      desc:
          'Message displayed when a payment is successfully marked as completed',
      args: [],
    );
  }

  /// `Reminder sent successfully`
  String get reminderSentSuccessfully {
    return Intl.message(
      'Reminder sent successfully',
      name: 'reminderSentSuccessfully',
      desc: 'Message displayed when a reminder is successfully sent',
      args: [],
    );
  }

  /// `Pay Now`
  String get payNow {
    return Intl.message(
      'Pay Now',
      name: 'payNow',
      desc: 'Button or label for initiating a payment',
      args: [],
    );
  }

  /// `Remind`
  String get remind {
    return Intl.message(
      'Remind',
      name: 'remind',
      desc: 'Button or label for sending a reminder',
      args: [],
    );
  }

  /// `Budgeted Categories`
  String get budgetedCategories {
    return Intl.message(
      'Budgeted Categories',
      name: 'budgetedCategories',
      desc: 'Label for the section displaying budgeted categories',
      args: [],
    );
  }

  /// `No budgets available for this month.`
  String get noBudgetsAvailable {
    return Intl.message(
      'No budgets available for this month.',
      name: 'noBudgetsAvailable',
      desc:
          'Message displayed when there are no budgets available for the selected month',
      args: [],
    );
  }

  /// `Delete Budget`
  String get deleteBudget {
    return Intl.message(
      'Delete Budget',
      name: 'deleteBudget',
      desc: 'Label for the delete budget action or button',
      args: [],
    );
  }

  /// `Are you sure you want to delete this budget?`
  String get confirmDeleteBudget {
    return Intl.message(
      'Are you sure you want to delete this budget?',
      name: 'confirmDeleteBudget',
      desc: 'Confirmation message for deleting a budget',
      args: [],
    );
  }

  /// `Overview`
  String get overview {
    return Intl.message(
      'Overview',
      name: 'overview',
      desc: 'Label for the overview section',
      args: [],
    );
  }

  /// `Financial health:`
  String get financialHealth {
    return Intl.message(
      'Financial health:',
      name: 'financialHealth',
      desc: 'Label for financial health section or metric',
      args: [],
    );
  }

  /// `Portfolio Analysis`
  String get portfolioAnalysis {
    return Intl.message(
      'Portfolio Analysis',
      name: 'portfolioAnalysis',
      desc: 'Label for the portfolio analysis section',
      args: [],
    );
  }

  /// `Net Worth Trend`
  String get netWorthTrend {
    return Intl.message(
      'Net Worth Trend',
      name: 'netWorthTrend',
      desc: 'Label for the net worth trend section',
      args: [],
    );
  }

  /// `Track your net worth changes over time`
  String get trackNetWorthChanges {
    return Intl.message(
      'Track your net worth changes over time',
      name: 'trackNetWorthChanges',
      desc: 'Label for tracking net worth changes over time',
      args: [],
    );
  }

  /// `Asset Performance`
  String get assetPerformance {
    return Intl.message(
      'Asset Performance',
      name: 'assetPerformance',
      desc: 'Label for the asset performance section',
      args: [],
    );
  }

  /// `Analyze your assets growth and distribution`
  String get analyzeAssetsGrowth {
    return Intl.message(
      'Analyze your assets growth and distribution',
      name: 'analyzeAssetsGrowth',
      desc: 'Label for analyzing assets growth and distribution',
      args: [],
    );
  }

  /// `Liability Analysis`
  String get liabilityAnalysis {
    return Intl.message(
      'Liability Analysis',
      name: 'liabilityAnalysis',
      desc: 'Label for the liability analysis section',
      args: [],
    );
  }

  /// `Monitor your debt and repayment progress`
  String get monitorDebtProgress {
    return Intl.message(
      'Monitor your debt and repayment progress',
      name: 'monitorDebtProgress',
      desc: 'Label for monitoring debt and repayment progress',
      args: [],
    );
  }

  /// `Financial Insights`
  String get financialInsights {
    return Intl.message(
      'Financial Insights',
      name: 'financialInsights',
      desc: 'Label for the financial insights section',
      args: [],
    );
  }

  /// `Get personalized recommendations`
  String get personalizedRecommendations {
    return Intl.message(
      'Get personalized recommendations',
      name: 'personalizedRecommendations',
      desc: 'Label for personalized recommendations section',
      args: [],
    );
  }

  /// `Net Worth Trends`
  String get netWorthTrends {
    return Intl.message(
      'Net Worth Trends',
      name: 'netWorthTrends',
      desc: 'Label for the net worth trends section',
      args: [],
    );
  }

  /// `Current Net Worth`
  String get currentNetWorth {
    return Intl.message(
      'Current Net Worth',
      name: 'currentNetWorth',
      desc: 'Label for the current net worth section',
      args: [],
    );
  }

  /// `1M Growth`
  String get oneMonthGrowth {
    return Intl.message(
      '1M Growth',
      name: 'oneMonthGrowth',
      desc: 'Label for one-month growth metric',
      args: [],
    );
  }

  /// `6M Growth`
  String get sixMonthGrowth {
    return Intl.message(
      '6M Growth',
      name: 'sixMonthGrowth',
      desc: 'Label for six-month growth metric',
      args: [],
    );
  }

  /// `1Y Growth`
  String get oneYearGrowth {
    return Intl.message(
      '1Y Growth',
      name: 'oneYearGrowth',
      desc: 'Label for one-year growth metric',
      args: [],
    );
  }

  /// `Net Worth History`
  String get netWorthHistory {
    return Intl.message(
      'Net Worth History',
      name: 'netWorthHistory',
      desc: 'Label for the net worth history section',
      args: [],
    );
  }

  /// `Monthly Breakdown`
  String get monthlyBreakdown {
    return Intl.message(
      'Monthly Breakdown',
      name: 'monthlyBreakdown',
      desc: 'Label for the monthly breakdown section',
      args: [],
    );
  }

  /// `Asset Distribution`
  String get assetDistribution {
    return Intl.message(
      'Asset Distribution',
      name: 'assetDistribution',
      desc: 'Label for the asset distribution section',
      args: [],
    );
  }

  /// `Total Liabilities`
  String get totalLiabilities {
    return Intl.message(
      'Total Liabilities',
      name: 'totalLiabilities',
      desc: 'Label for the total liabilities section',
      args: [],
    );
  }

  /// `Monthly EMIs`
  String get monthlyEmis {
    return Intl.message(
      'Monthly EMIs',
      name: 'monthlyEmis',
      desc: 'Label for the monthly EMIs section',
      args: [],
    );
  }

  /// `Debt Ratio`
  String get debtRatio {
    return Intl.message(
      'Debt Ratio',
      name: 'debtRatio',
      desc: 'Label for the debt ratio section',
      args: [],
    );
  }

  /// `Debt Distribution`
  String get debtDistribution {
    return Intl.message(
      'Debt Distribution',
      name: 'debtDistribution',
      desc: 'Label for the debt distribution section',
      args: [],
    );
  }

  /// `Loan Details`
  String get loanDetails {
    return Intl.message(
      'Loan Details',
      name: 'loanDetails',
      desc: 'Label for the loan details section',
      args: [],
    );
  }

  /// `Financial Health Score`
  String get financialHealthScore {
    return Intl.message(
      'Financial Health Score',
      name: 'financialHealthScore',
      desc: 'Label for the financial health score section',
      args: [],
    );
  }

  /// `Key Metrics`
  String get keyMetrics {
    return Intl.message(
      'Key Metrics',
      name: 'keyMetrics',
      desc: 'Label for the key metrics section',
      args: [],
    );
  }

  /// `Recommendations`
  String get recommendations {
    return Intl.message(
      'Recommendations',
      name: 'recommendations',
      desc: 'Label for the recommendations section',
      args: [],
    );
  }

  /// `EMI`
  String get emiLabel {
    return Intl.message(
      'EMI',
      name: 'emiLabel',
      desc: 'Label for EMI (Equated Monthly Installment)',
      args: [],
    );
  }

  /// `Interest`
  String get interestLabel {
    return Intl.message(
      'Interest',
      name: 'interestLabel',
      desc: 'Label for interest rate',
      args: [],
    );
  }

  /// `Remaining`
  String get remainingLabel {
    return Intl.message(
      'Remaining',
      name: 'remainingLabel',
      desc: 'Label for remaining loan term in months',
      args: [],
    );
  }

  /// `Build Emergency Fund`
  String get buildEmergencyFund {
    return Intl.message(
      'Build Emergency Fund',
      name: 'buildEmergencyFund',
      desc: 'Label for building an emergency fund recommendation',
      args: [],
    );
  }

  /// `Increase emergency fund to cover 6 months of expenses`
  String get increaseEmergencyFund {
    return Intl.message(
      'Increase emergency fund to cover 6 months of expenses',
      name: 'increaseEmergencyFund',
      desc: 'Label for increasing emergency fund recommendation',
      args: [],
    );
  }

  /// `Reduce Debt`
  String get reduceDebt {
    return Intl.message(
      'Reduce Debt',
      name: 'reduceDebt',
      desc: 'Label for reducing debt recommendation',
      args: [],
    );
  }

  /// `Focus on paying down high-interest debt to improve financial health`
  String get focusOnHighInterestDebt {
    return Intl.message(
      'Focus on paying down high-interest debt to improve financial health',
      name: 'focusOnHighInterestDebt',
      desc: 'Recommendation to focus on paying down high-interest debt',
      args: [],
    );
  }

  /// `High`
  String get high {
    return Intl.message(
      'High',
      name: 'high',
      desc: 'Label for high priority',
      args: [],
    );
  }

  /// `Increase Savings`
  String get increaseSavings {
    return Intl.message(
      'Increase Savings',
      name: 'increaseSavings',
      desc: 'Label for increasing savings recommendation',
      args: [],
    );
  }

  /// `Optimize Investments`
  String get optimizeInvestments {
    return Intl.message(
      'Optimize Investments',
      name: 'optimizeInvestments',
      desc: 'Label for optimizing investments recommendation',
      args: [],
    );
  }

  /// `Consider diversifying your investment portfolio`
  String get considerDiversifyingInvestments {
    return Intl.message(
      'Consider diversifying your investment portfolio',
      name: 'considerDiversifyingInvestments',
      desc: 'Recommendation to consider diversifying the investment portfolio',
      args: [],
    );
  }

  /// `Maintain Financial Health`
  String get maintainFinancialHealth {
    return Intl.message(
      'Maintain Financial Health',
      name: 'maintainFinancialHealth',
      desc: 'Recommendation to maintain good financial habits',
      args: [],
    );
  }

  /// `Continue good financial habits to stay on track`
  String get continueGoodHabits {
    return Intl.message(
      'Continue good financial habits to stay on track',
      name: 'continueGoodHabits',
      desc: 'Recommendation to continue good financial habits',
      args: [],
    );
  }

  /// `Low`
  String get low {
    return Intl.message(
      'Low',
      name: 'low',
      desc: 'Label for low priority',
      args: [],
    );
  }

  /// `Medium`
  String get medium {
    return Intl.message(
      'Medium',
      name: 'medium',
      desc: 'Label for medium priority',
      args: [],
    );
  }

  /// `Top Assets`
  String get topAssets {
    return Intl.message(
      'Top Assets',
      name: 'topAssets',
      desc: 'Label for the top assets section',
      args: [],
    );
  }

  /// `Top Liabilities`
  String get topLiabilities {
    return Intl.message(
      'Top Liabilities',
      name: 'topLiabilities',
      desc: 'Label for the top liabilities section',
      args: [],
    );
  }

  /// `Undo`
  String get undo {
    return Intl.message(
      'Undo',
      name: 'undo',
      desc: 'Label for undo action or button',
      args: [],
    );
  }

  /// `Total Budget`
  String get totalBudget {
    return Intl.message(
      'Total Budget',
      name: 'totalBudget',
      desc: 'Label for total budget',
      args: [],
    );
  }

  /// `Spent`
  String get spent {
    return Intl.message(
      'Spent',
      name: 'spent',
      desc: 'Label for spent amount',
      args: [],
    );
  }

  /// `remaining`
  String get remaining {
    return Intl.message(
      'remaining',
      name: 'remaining',
      desc: 'Label for remaining amount',
      args: [],
    );
  }

  /// `Edit Card/Account`
  String get editCardAccount {
    return Intl.message(
      'Edit Card/Account',
      name: 'editCardAccount',
      desc: 'Label for editing a card or account',
      args: [],
    );
  }

  /// `Add New Card/Account`
  String get addNewCardAccount {
    return Intl.message(
      'Add New Card/Account',
      name: 'addNewCardAccount',
      desc: 'Button text for adding a new card or account',
      args: [],
    );
  }

  /// `Type`
  String get type {
    return Intl.message(
      'Type',
      name: 'type',
      desc: 'Label for selecting the type of card or account',
      args: [],
    );
  }

  /// `Card/Account Number`
  String get cardAccountNumber {
    return Intl.message(
      'Card/Account Number',
      name: 'cardAccountNumber',
      desc: 'Label for the card or account number field',
      args: [],
    );
  }

  /// `Please enter balance`
  String get pleaseEnterBalance {
    return Intl.message(
      'Please enter balance',
      name: 'pleaseEnterBalance',
      desc: 'Message prompting the user to enter a balance',
      args: [],
    );
  }

  /// `Update Card`
  String get updateCard {
    return Intl.message(
      'Update Card',
      name: 'updateCard',
      desc: 'Button text for updating an existing card',
      args: [],
    );
  }

  /// `Add Card`
  String get addCard {
    return Intl.message(
      'Add Card',
      name: 'addCard',
      desc: 'Button text for adding a new card',
      args: [],
    );
  }

  /// `Card Icon`
  String get cardIcon {
    return Intl.message(
      'Card Icon',
      name: 'cardIcon',
      desc: 'Label for selecting a card icon',
      args: [],
    );
  }

  /// `Card updated successfully`
  String get cardUpdatedSuccessfully {
    return Intl.message(
      'Card updated successfully',
      name: 'cardUpdatedSuccessfully',
      desc: 'Message displayed when a card is successfully updated',
      args: [],
    );
  }

  /// `Card added successfully`
  String get cardAddedSuccessfully {
    return Intl.message(
      'Card added successfully',
      name: 'cardAddedSuccessfully',
      desc: 'Message displayed when a card is successfully added',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: 'Label for update action or button',
      args: [],
    );
  }

  /// `Card Color`
  String get cardColor {
    return Intl.message(
      'Card Color',
      name: 'cardColor',
      desc: 'Label for Card Color',
      args: [],
    );
  }

  /// `Save more to build a stronger financial foundation`
  String get saveMoreToBuildFoundation {
    return Intl.message(
      'Save more to build a stronger financial foundation',
      name: 'saveMoreToBuildFoundation',
      desc: 'Recommendation to save more for a stronger financial foundation',
      args: [],
    );
  }

  /// `Unauthorized`
  String get unauthorized {
    return Intl.message(
      'Unauthorized',
      name: 'unauthorized',
      desc: 'Message displayed when the user is unauthorized',
      args: [],
    );
  }

  /// `Transfer Money`
  String get transferMoney {
    return Intl.message(
      'Transfer Money',
      name: 'transferMoney',
      desc: 'Label for transferring money',
      args: [],
    );
  }

  /// `Transfer`
  String get transfer {
    return Intl.message(
      'Transfer',
      name: 'transfer',
      desc: 'Label for the transfer action',
      args: [],
    );
  }

  /// `From Account`
  String get fromAccount {
    return Intl.message(
      'From Account',
      name: 'fromAccount',
      desc: 'Label for selecting the source account',
      args: [],
    );
  }

  /// `To Account`
  String get toAccount {
    return Intl.message(
      'To Account',
      name: 'toAccount',
      desc: 'Label for selecting the destination account',
      args: [],
    );
  }

  /// `Transfer Amount`
  String get transferAmount {
    return Intl.message(
      'Transfer Amount',
      name: 'transferAmount',
      desc: 'Label for the amount to be transferred',
      args: [],
    );
  }

  /// `Enter amount to transfer`
  String get enterAmountToTransfer {
    return Intl.message(
      'Enter amount to transfer',
      name: 'enterAmountToTransfer',
      desc:
          'Placeholder or message prompting the user to enter the transfer amount',
      args: [],
    );
  }

  /// `Available Budget`
  String get availableBudget {
    return Intl.message(
      'Available Budget',
      name: 'availableBudget',
      desc: 'Label for available budget',
      args: [],
    );
  }

  /// `Enter amount`
  String get enterAmount {
    return Intl.message(
      'Enter amount',
      name: 'enterAmount',
      desc: 'Placeholder or message prompting the user to enter an amount',
      args: [],
    );
  }

  /// `Please enter an amount`
  String get pleaseEnterAnAmount {
    return Intl.message(
      'Please enter an amount',
      name: 'pleaseEnterAnAmount',
      desc: 'Message prompting the user to enter an amount',
      args: [],
    );
  }

  /// `Please enter a valid amount greater than 0`
  String get pleaseEnterAValidAmount {
    return Intl.message(
      'Please enter a valid amount greater than 0',
      name: 'pleaseEnterAValidAmount',
      desc: 'Message prompting the user to enter a valid amount greater than 0',
      args: [],
    );
  }

  /// `Please add income first!`
  String get pleaseAddIncomeFirst {
    return Intl.message(
      'Please add income first!',
      name: 'pleaseAddIncomeFirst',
      desc: 'Message prompting the user to add income before proceeding',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: 'Label for description field',
      args: [],
    );
  }

  /// `Enter description`
  String get enterDescription {
    return Intl.message(
      'Enter description',
      name: 'enterDescription',
      desc: 'Placeholder or message prompting the user to enter a description',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: 'Label for selecting a date',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message(
      'Time',
      name: 'time',
      desc: 'Label for selecting a time',
      args: [],
    );
  }

  /// `Cash Wallet`
  String get cashWallet {
    return Intl.message(
      'Cash Wallet',
      name: 'cashWallet',
      desc: 'Label for the cash wallet payment method',
      args: [],
    );
  }

  /// `Add New Account`
  String get addNewAccount {
    return Intl.message(
      'Add New Account',
      name: 'addNewAccount',
      desc: 'Button text for adding a new account',
      args: [],
    );
  }

  /// `Please select a payment method`
  String get pleaseSelectAPaymentMethod {
    return Intl.message(
      'Please select a payment method',
      name: 'pleaseSelectAPaymentMethod',
      desc: 'Message prompting the user to select a payment method',
      args: [],
    );
  }

  /// `Recurring Transaction`
  String get recurringTransaction {
    return Intl.message(
      'Recurring Transaction',
      name: 'recurringTransaction',
      desc: 'Label for enabling or disabling recurring transactions',
      args: [],
    );
  }

  /// `Frequency`
  String get frequency {
    return Intl.message(
      'Frequency',
      name: 'frequency',
      desc: 'Label for selecting the frequency of a transaction',
      args: [],
    );
  }

  /// `Split Transaction`
  String get splitTransaction {
    return Intl.message(
      'Split Transaction',
      name: 'splitTransaction',
      desc: 'Label for splitting a transaction',
      args: [],
    );
  }

  /// `Update Transaction`
  String get updateTransaction {
    return Intl.message(
      'Update Transaction',
      name: 'updateTransaction',
      desc: 'Label for updating a transaction',
      args: [],
    );
  }

  /// `Save Transaction`
  String get saveTransaction {
    return Intl.message(
      'Save Transaction',
      name: 'saveTransaction',
      desc: 'Label for saving a transaction',
      args: [],
    );
  }

  /// `Transaction added successfully`
  String get transactionAddedSuccessfully {
    return Intl.message(
      'Transaction added successfully',
      name: 'transactionAddedSuccessfully',
      desc: 'Message displayed when a transaction is successfully added',
      args: [],
    );
  }

  /// `Select Category`
  String get selectCategory {
    return Intl.message(
      'Select Category',
      name: 'selectCategory',
      desc: 'Label for selecting a category',
      args: [],
    );
  }

  /// `New Category`
  String get newCategory {
    return Intl.message(
      'New Category',
      name: 'newCategory',
      desc: 'Label for creating a new category',
      args: [],
    );
  }

  /// `Add New Category`
  String get addNewCategory {
    return Intl.message(
      'Add New Category',
      name: 'addNewCategory',
      desc: 'Button text for adding a new category',
      args: [],
    );
  }

  /// `Category Name`
  String get categoryName {
    return Intl.message(
      'Category Name',
      name: 'categoryName',
      desc: 'Label for entering the name of a category',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: 'Button text for adding an item',
      args: [],
    );
  }

  /// `Account Name`
  String get accountName {
    return Intl.message(
      'Account Name',
      name: 'accountName',
      desc: 'Label for entering the name of an account',
      args: [],
    );
  }

  /// `Account Type`
  String get accountType {
    return Intl.message(
      'Account Type',
      name: 'accountType',
      desc: 'Label for selecting the type of account',
      args: [],
    );
  }

  /// `Bank Account`
  String get bankAccount {
    return Intl.message(
      'Bank Account',
      name: 'bankAccount',
      desc: 'Label for bank account type',
      args: [],
    );
  }

  /// `Credit Card`
  String get creditCard {
    return Intl.message(
      'Credit Card',
      name: 'creditCard',
      desc: 'Label for credit card type',
      args: [],
    );
  }

  /// `Cash`
  String get cash {
    return Intl.message(
      'Cash',
      name: 'cash',
      desc: 'Label for cash type',
      args: [],
    );
  }

  /// `Add Person to Split`
  String get addPersonToSplit {
    return Intl.message(
      'Add Person to Split',
      name: 'addPersonToSplit',
      desc: 'Button text for adding a person to split',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: 'Label for name field',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: 'Label for entering a person\'s email',
      args: [],
    );
  }

  /// `Please enter the email`
  String get pleaseEnterTheEmail {
    return Intl.message(
      'Please enter the email',
      name: 'pleaseEnterTheEmail',
      desc: 'Message prompting the user to enter an email',
      args: [],
    );
  }

  /// `Split Equally`
  String get splitEqually {
    return Intl.message(
      'Split Equally',
      name: 'splitEqually',
      desc: 'Label for the split equally option',
      args: [],
    );
  }

  /// `Custom Split`
  String get customSplit {
    return Intl.message(
      'Custom Split',
      name: 'customSplit',
      desc: 'Label for the custom split option',
      args: [],
    );
  }

  /// `Budget Period`
  String get budgetPeriod {
    return Intl.message(
      'Budget Period',
      name: 'budgetPeriod',
      desc: 'Label for selecting the budget period',
      args: [],
    );
  }

  /// `Monthly`
  String get monthly {
    return Intl.message(
      'Monthly',
      name: 'monthly',
      desc: 'Label for the monthly budget period',
      args: [],
    );
  }

  /// `Quarterly`
  String get quarterly {
    return Intl.message(
      'Quarterly',
      name: 'quarterly',
      desc: 'Label for the quarterly budget period',
      args: [],
    );
  }

  /// `Yearly`
  String get yearly {
    return Intl.message(
      'Yearly',
      name: 'yearly',
      desc: 'Label for the yearly budget period',
      args: [],
    );
  }

  /// `Custom`
  String get custom {
    return Intl.message(
      'Custom',
      name: 'custom',
      desc: 'Label for the custom budget period',
      args: [],
    );
  }

  /// `Alerts & Notifications`
  String get alertsAndNotifications {
    return Intl.message(
      'Alerts & Notifications',
      name: 'alertsAndNotifications',
      desc: 'Label for the alerts and notifications section',
      args: [],
    );
  }

  /// `80% of budget used`
  String get eightyPercentBudgetUsed {
    return Intl.message(
      '80% of budget used',
      name: 'eightyPercentBudgetUsed',
      desc: 'Notification message for 80% of the budget being used',
      args: [],
    );
  }

  /// `90% of budget used`
  String get ninetyPercentBudgetUsed {
    return Intl.message(
      '90% of budget used',
      name: 'ninetyPercentBudgetUsed',
      desc: 'Notification message for 90% of the budget being used',
      args: [],
    );
  }

  /// `Budget exceeded`
  String get budgetExceeded {
    return Intl.message(
      'Budget exceeded',
      name: 'budgetExceeded',
      desc: 'Notification message for when the budget is exceeded',
      args: [],
    );
  }

  /// `Budget Amount`
  String get budgetAmount {
    return Intl.message(
      'Budget Amount',
      name: 'budgetAmount',
      desc: 'Label for entering the budget amount',
      args: [],
    );
  }

  /// `Enter Budget Amount`
  String get enterBudgetAmount {
    return Intl.message(
      'Enter Budget Amount',
      name: 'enterBudgetAmount',
      desc:
          'Placeholder or message prompting the user to enter a budget amount',
      args: [],
    );
  }

  /// `Set your budget limit for this category`
  String get setYourBudgetLimit {
    return Intl.message(
      'Set your budget limit for this category',
      name: 'setYourBudgetLimit',
      desc: 'Message prompting the user to set a budget limit for a category',
      args: [],
    );
  }

  /// `Please enter a budget amount`
  String get pleaseEnterABudgetAmount {
    return Intl.message(
      'Please enter a budget amount',
      name: 'pleaseEnterABudgetAmount',
      desc: 'Message prompting the user to enter a budget amount',
      args: [],
    );
  }

  /// `Amount must be greater than 0`
  String get amountMustBeGreaterThanZero {
    return Intl.message(
      'Amount must be greater than 0',
      name: 'amountMustBeGreaterThanZero',
      desc: 'Message indicating that the amount must be greater than 0',
      args: [],
    );
  }

  /// `Amount is too large`
  String get amountIsTooLarge {
    return Intl.message(
      'Amount is too large',
      name: 'amountIsTooLarge',
      desc: 'Message indicating that the entered amount is too large',
      args: [],
    );
  }

  /// `Recurring Options`
  String get recurringOptions {
    return Intl.message(
      'Recurring Options',
      name: 'recurringOptions',
      desc: 'Label for recurring budget options',
      args: [],
    );
  }

  /// `Make this budget recurring?`
  String get makeThisBudgetRecurring {
    return Intl.message(
      'Make this budget recurring?',
      name: 'makeThisBudgetRecurring',
      desc: 'Prompt asking if the budget should be made recurring',
      args: [],
    );
  }

  /// `Budget will automatically reset each period`
  String get budgetWillResetEachPeriod {
    return Intl.message(
      'Budget will automatically reset each period',
      name: 'budgetWillResetEachPeriod',
      desc: 'Message indicating that the budget will reset each period',
      args: [],
    );
  }

  /// `Budget will automatically reset at the beginning of each period`
  String get budgetWillResetAtBeginning {
    return Intl.message(
      'Budget will automatically reset at the beginning of each period',
      name: 'budgetWillResetAtBeginning',
      desc:
          'Message indicating that the budget will reset at the start of each period',
      args: [],
    );
  }

  /// `Carry over remaining balance`
  String get carryOverRemainingBalance {
    return Intl.message(
      'Carry over remaining balance',
      name: 'carryOverRemainingBalance',
      desc: 'Option to carry over the remaining balance to the next period',
      args: [],
    );
  }

  /// `Collaborators`
  String get collaborators {
    return Intl.message(
      'Collaborators',
      name: 'collaborators',
      desc: 'Label for the collaborators section',
      args: [],
    );
  }

  /// `Add Collaborators`
  String get addCollaborators {
    return Intl.message(
      'Add Collaborators',
      name: 'addCollaborators',
      desc: 'Button text for adding collaborators',
      args: [],
    );
  }

  /// `Share this budget with others`
  String get shareThisBudget {
    return Intl.message(
      'Share this budget with others',
      name: 'shareThisBudget',
      desc: 'Message prompting the user to share the budget with others',
      args: [],
    );
  }

  /// `Add Collaborator`
  String get addCollaborator {
    return Intl.message(
      'Add Collaborator',
      name: 'addCollaborator',
      desc: 'Button text for adding a single collaborator',
      args: [],
    );
  }

  /// `Enter email or name`
  String get enterEmailOrName {
    return Intl.message(
      'Enter email or name',
      name: 'enterEmailOrName',
      desc:
          'Placeholder or message prompting the user to enter an email or name',
      args: [],
    );
  }

  /// `Validation Error`
  String get validationError {
    return Intl.message(
      'Validation Error',
      name: 'validationError',
      desc: 'Label for validation error messages',
      args: [],
    );
  }

  /// `Please fill in all required fields`
  String get pleaseFillRequiredFields {
    return Intl.message(
      'Please fill in all required fields',
      name: 'pleaseFillRequiredFields',
      desc: 'Message prompting the user to fill in all required fields',
      args: [],
    );
  }

  /// `Invalid Date Range`
  String get invalidDateRange {
    return Intl.message(
      'Invalid Date Range',
      name: 'invalidDateRange',
      desc: 'Message indicating that the selected date range is invalid',
      args: [],
    );
  }

  /// `Start date must be before end date`
  String get startDateBeforeEndDate {
    return Intl.message(
      'Start date must be before end date',
      name: 'startDateBeforeEndDate',
      desc:
          'Message indicating that the start date must be earlier than the end date',
      args: [],
    );
  }

  /// `Duplicate Budget`
  String get duplicateBudget {
    return Intl.message(
      'Duplicate Budget',
      name: 'duplicateBudget',
      desc:
          'Message indicating that a budget for the category already exists in the selected month',
      args: [],
    );
  }

  /// `Failed to save budget. Please try again.`
  String get failedToSaveBudget {
    return Intl.message(
      'Failed to save budget. Please try again.',
      name: 'failedToSaveBudget',
      desc: 'Message displayed when saving the budget fails',
      args: [],
    );
  }

  /// `Budget updated successfully`
  String get budgetUpdatedSuccessfully {
    return Intl.message(
      'Budget updated successfully',
      name: 'budgetUpdatedSuccessfully',
      desc: 'Message displayed when a budget is successfully updated',
      args: [],
    );
  }

  /// `Budget created successfully`
  String get budgetCreatedSuccessfully {
    return Intl.message(
      'Budget created successfully',
      name: 'budgetCreatedSuccessfully',
      desc: 'Message displayed when a budget is successfully created',
      args: [],
    );
  }

  /// `Set Budget`
  String get setBudget {
    return Intl.message(
      'Set Budget',
      name: 'setBudget',
      desc: 'Button text for setting a budget',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: 'Button text for saving',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: 'Button text for going back',
      args: [],
    );
  }

  /// `Continue`
  String get continueButton {
    return Intl.message(
      'Continue',
      name: 'continueButton',
      desc: 'Button text for continuing to the next step',
      args: [],
    );
  }

  /// `Enter Custom Category`
  String get enterCustomCategory {
    return Intl.message(
      'Enter Custom Category',
      name: 'enterCustomCategory',
      desc: 'Label for entering a custom category',
      args: [],
    );
  }

  /// `Start Date`
  String get startDate {
    return Intl.message(
      'Start Date',
      name: 'startDate',
      desc: 'Label for selecting the start date',
      args: [],
    );
  }

  /// `End Date`
  String get endDate {
    return Intl.message(
      'End Date',
      name: 'endDate',
      desc: 'Label for selecting the end date',
      args: [],
    );
  }

  /// `Custom Alert Threshold (%)`
  String get customAlertThreshold {
    return Intl.message(
      'Custom Alert Threshold (%)',
      name: 'customAlertThreshold',
      desc: 'Label for entering a custom alert threshold percentage',
      args: [],
    );
  }

  /// `Enter a custom percentage for alerts`
  String get enterCustomPercentage {
    return Intl.message(
      'Enter a custom percentage for alerts',
      name: 'enterCustomPercentage',
      desc: 'Helper text for entering a custom alert percentage',
      args: [],
    );
  }

  /// `Required Field`
  String get requiredField {
    return Intl.message(
      'Required Field',
      name: 'requiredField',
      desc: 'Message indicating that a required field is missing',
      args: [],
    );
  }

  /// `Please select a category`
  String get pleaseSelectACategory {
    return Intl.message(
      'Please select a category',
      name: 'pleaseSelectACategory',
      desc: 'Message prompting the user to select a category',
      args: [],
    );
  }

  /// `Budget amount must be greater than 0`
  String get budgetAmountMustBeGreaterThanZero {
    return Intl.message(
      'Budget amount must be greater than 0',
      name: 'budgetAmountMustBeGreaterThanZero',
      desc:
          'Message indicating that the budget amount must be greater than zero',
      args: [],
    );
  }

  /// `Start date must be before end date`
  String get startDateMustBeBeforeEndDate {
    return Intl.message(
      'Start date must be before end date',
      name: 'startDateMustBeBeforeEndDate',
      desc:
          'Message indicating that the start date must be earlier than the end date',
      args: [],
    );
  }

  /// `Budget period must be at least 1 day`
  String get budgetPeriodMustBeAtLeastOneDay {
    return Intl.message(
      'Budget period must be at least 1 day',
      name: 'budgetPeriodMustBeAtLeastOneDay',
      desc:
          'Message indicating that the budget period must be at least one day',
      args: [],
    );
  }

  /// `Asset`
  String get asset {
    return Intl.message(
      'Asset',
      name: 'asset',
      desc: 'Label for asset type',
      args: [],
    );
  }

  /// `Liability`
  String get liability {
    return Intl.message(
      'Liability',
      name: 'liability',
      desc: 'Label for liability type',
      args: [],
    );
  }

  /// `Enter Custom Type`
  String get enterCustomType {
    return Intl.message(
      'Enter Custom Type',
      name: 'enterCustomType',
      desc: 'Label for entering a custom type',
      args: [],
    );
  }

  /// `Please enter a custom type`
  String get pleaseEnterACustomType {
    return Intl.message(
      'Please enter a custom type',
      name: 'pleaseEnterACustomType',
      desc: 'Message prompting the user to enter a custom type',
      args: [],
    );
  }

  /// `Value/Amount`
  String get valueOrAmount {
    return Intl.message(
      'Value/Amount',
      name: 'valueOrAmount',
      desc: 'Label for entering a value or amount',
      args: [],
    );
  }

  /// `Asset Value`
  String get assetValue {
    return Intl.message(
      'Asset Value',
      name: 'assetValue',
      desc: 'Label for entering the value of an asset',
      args: [],
    );
  }

  /// `Liability Amount`
  String get liabilityAmount {
    return Intl.message(
      'Liability Amount',
      name: 'liabilityAmount',
      desc: 'Label for entering the amount of a liability',
      args: [],
    );
  }

  /// `Current market value`
  String get currentMarketValue {
    return Intl.message(
      'Current market value',
      name: 'currentMarketValue',
      desc: 'Helper text for entering the current market value',
      args: [],
    );
  }

  /// `Outstanding amount`
  String get outstandingAmount {
    return Intl.message(
      'Outstanding amount',
      name: 'outstandingAmount',
      desc: 'Helper text for entering the outstanding amount',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message(
      'Details',
      name: 'details',
      desc: 'Label for the details section',
      args: [],
    );
  }

  /// `Name/Description`
  String get nameOrDescription {
    return Intl.message(
      'Name/Description',
      name: 'nameOrDescription',
      desc: 'Label for entering a name or description',
      args: [],
    );
  }

  /// `Please enter a name/description`
  String get pleaseEnterANameOrDescription {
    return Intl.message(
      'Please enter a name/description',
      name: 'pleaseEnterANameOrDescription',
      desc: 'Message prompting the user to enter a name or description',
      args: [],
    );
  }

  /// `Purchase/Start Date`
  String get purchaseOrStartDate {
    return Intl.message(
      'Purchase/Start Date',
      name: 'purchaseOrStartDate',
      desc: 'Label for selecting the purchase or start date',
      args: [],
    );
  }

  /// `Please select a date`
  String get pleaseSelectADate {
    return Intl.message(
      'Please select a date',
      name: 'pleaseSelectADate',
      desc: 'Message prompting the user to select a date',
      args: [],
    );
  }

  /// `Interest Rate`
  String get interestRate {
    return Intl.message(
      'Interest Rate',
      name: 'interestRate',
      desc: 'Label for interest rate',
      args: [],
    );
  }

  /// `Please enter an interest rate`
  String get pleaseEnterAnInterestRate {
    return Intl.message(
      'Please enter an interest rate',
      name: 'pleaseEnterAnInterestRate',
      desc: 'Message prompting the user to enter an interest rate',
      args: [],
    );
  }

  /// `Interest rate cannot be negative`
  String get interestRateCannotBeNegative {
    return Intl.message(
      'Interest rate cannot be negative',
      name: 'interestRateCannotBeNegative',
      desc: 'Message indicating that the interest rate cannot be negative',
      args: [],
    );
  }

  /// `Payment Schedule`
  String get paymentSchedule {
    return Intl.message(
      'Payment Schedule',
      name: 'paymentSchedule',
      desc: 'Label for selecting a payment schedule',
      args: [],
    );
  }

  /// `Select payment frequency`
  String get selectPaymentFrequency {
    return Intl.message(
      'Select payment frequency',
      name: 'selectPaymentFrequency',
      desc: 'Placeholder for selecting a payment frequency',
      args: [],
    );
  }

  /// `Please select a payment schedule`
  String get pleaseSelectAPaymentSchedule {
    return Intl.message(
      'Please select a payment schedule',
      name: 'pleaseSelectAPaymentSchedule',
      desc: 'Message prompting the user to select a payment schedule',
      args: [],
    );
  }

  /// `Documents/Attachments`
  String get documentsOrAttachments {
    return Intl.message(
      'Documents/Attachments',
      name: 'documentsOrAttachments',
      desc: 'Label for the documents or attachments section',
      args: [],
    );
  }

  /// `Add Document`
  String get addDocument {
    return Intl.message(
      'Add Document',
      name: 'addDocument',
      desc: 'Button text for adding a document',
      args: [],
    );
  }

  /// `Value Updates`
  String get valueUpdates {
    return Intl.message(
      'Value Updates',
      name: 'valueUpdates',
      desc: 'Label for value updates tracking option',
      args: [],
    );
  }

  /// `Payment Reminders`
  String get paymentReminders {
    return Intl.message(
      'Payment Reminders',
      name: 'paymentReminders',
      desc: 'Label for payment reminders tracking option',
      args: [],
    );
  }

  /// `Document Expiry`
  String get documentExpiry {
    return Intl.message(
      'Document Expiry',
      name: 'documentExpiry',
      desc: 'Label for document expiry tracking option',
      args: [],
    );
  }

  /// `Interest Rate Changes`
  String get interestRateChanges {
    return Intl.message(
      'Interest Rate Changes',
      name: 'interestRateChanges',
      desc: 'Label for interest rate changes tracking option',
      args: [],
    );
  }

  /// `Tracking Preferences`
  String get trackingPreferences {
    return Intl.message(
      'Tracking Preferences',
      name: 'trackingPreferences',
      desc: 'Label for tracking preferences section',
      args: [],
    );
  }

  /// `Custom Tracking Note`
  String get customTrackingNote {
    return Intl.message(
      'Custom Tracking Note',
      name: 'customTrackingNote',
      desc: 'Label for custom tracking note field',
      args: [],
    );
  }

  /// `Add any specific tracking requirements`
  String get addSpecificTrackingRequirements {
    return Intl.message(
      'Add any specific tracking requirements',
      name: 'addSpecificTrackingRequirements',
      desc: 'Helper text for adding specific tracking requirements',
      args: [],
    );
  }

  /// `Please select a type`
  String get pleaseSelectAType {
    return Intl.message(
      'Please select a type',
      name: 'pleaseSelectAType',
      desc: 'Message prompting the user to select a type',
      args: [],
    );
  }

  /// `Please fill in all required liability fields`
  String get pleaseFillRequiredLiabilityFields {
    return Intl.message(
      'Please fill in all required liability fields',
      name: 'pleaseFillRequiredLiabilityFields',
      desc:
          'Message prompting the user to fill in all required liability fields',
      args: [],
    );
  }

  /// `Change Currency`
  String get changeCurrency {
    return Intl.message(
      'Change Currency',
      name: 'changeCurrency',
      desc: 'Label for changing the currency',
      args: [],
    );
  }

  /// `Select Your Currency`
  String get selectYourCurrency {
    return Intl.message(
      'Select Your Currency',
      name: 'selectYourCurrency',
      desc: 'Title for selecting the user\'s currency',
      args: [],
    );
  }

  /// `Choose your preferred currency to get started.`
  String get choosePreferredCurrency {
    return Intl.message(
      'Choose your preferred currency to get started.',
      name: 'choosePreferredCurrency',
      desc: 'Message prompting the user to choose their preferred currency',
      args: [],
    );
  }

  /// `This will be used for all your financial transactions and reports.`
  String get currencyUsageInfo {
    return Intl.message(
      'This will be used for all your financial transactions and reports.',
      name: 'currencyUsageInfo',
      desc: 'Message explaining the purpose of selecting a currency',
      args: [],
    );
  }

  /// `Select Currency`
  String get selectCurrency {
    return Intl.message(
      'Select Currency',
      name: 'selectCurrency',
      desc: 'Button text for selecting a currency',
      args: [],
    );
  }

  /// `Change Currency`
  String get changeCurrencyButton {
    return Intl.message(
      'Change Currency',
      name: 'changeCurrencyButton',
      desc: 'Button text for changing the currency',
      args: [],
    );
  }

  /// `Next`
  String get nextButton {
    return Intl.message(
      'Next',
      name: 'nextButton',
      desc: 'Button text for proceeding to the next step',
      args: [],
    );
  }

  /// `Wait`
  String get wait {
    return Intl.message(
      'Wait',
      name: 'wait',
      desc: 'Message displayed when the user needs to wait',
      args: [],
    );
  }

  /// `Ad not ready yet`
  String get adNotReadyYet {
    return Intl.message(
      'Ad not ready yet',
      name: 'adNotReadyYet',
      desc: 'Message displayed when an ad is not ready to be shown',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: 'Label for the settings section',
      args: [],
    );
  }

  /// `Reports & Analytics`
  String get reportsAndAnalytics {
    return Intl.message(
      'Reports & Analytics',
      name: 'reportsAndAnalytics',
      desc: 'Label for the reports and analytics section',
      args: [],
    );
  }

  /// `Future Projections`
  String get futureProjections {
    return Intl.message(
      'Future Projections',
      name: 'futureProjections',
      desc: 'Label for the future projections section',
      args: [],
    );
  }

  /// `View financial forecasts and trends`
  String get viewFinancialForecastsAndTrends {
    return Intl.message(
      'View financial forecasts and trends',
      name: 'viewFinancialForecastsAndTrends',
      desc: 'Message prompting the user to view financial forecasts and trends',
      args: [],
    );
  }

  /// `Past Performance`
  String get pastPerformance {
    return Intl.message(
      'Past Performance',
      name: 'pastPerformance',
      desc: 'Label for the past performance section',
      args: [],
    );
  }

  /// `Historical financial analysis`
  String get historicalFinancialAnalysis {
    return Intl.message(
      'Historical financial analysis',
      name: 'historicalFinancialAnalysis',
      desc: 'Label for analyzing historical financial data',
      args: [],
    );
  }

  /// `Income & Expense Analysis`
  String get incomeAndExpenseAnalysis {
    return Intl.message(
      'Income & Expense Analysis',
      name: 'incomeAndExpenseAnalysis',
      desc: 'Title for the income and expense analysis screen',
      args: [],
    );
  }

  /// `Compare income, expenses and savings`
  String get compareIncomeExpensesAndSavings {
    return Intl.message(
      'Compare income, expenses and savings',
      name: 'compareIncomeExpensesAndSavings',
      desc:
          'Message prompting the user to compare income, expenses, and savings',
      args: [],
    );
  }

  /// `Budget vs Actual`
  String get budgetVsActual {
    return Intl.message(
      'Budget vs Actual',
      name: 'budgetVsActual',
      desc: 'Title for the budget vs actual screen',
      args: [],
    );
  }

  /// `Track budget performance`
  String get trackBudgetPerformance {
    return Intl.message(
      'Track budget performance',
      name: 'trackBudgetPerformance',
      desc: 'Message prompting the user to track budget performance',
      args: [],
    );
  }

  /// `Download Reports`
  String get downloadReports {
    return Intl.message(
      'Download Reports',
      name: 'downloadReports',
      desc: 'Title for the download reports section',
      args: [],
    );
  }

  /// `Export financial reports`
  String get exportFinancialReports {
    return Intl.message(
      'Export financial reports',
      name: 'exportFinancialReports',
      desc: 'Button text for exporting financial reports',
      args: [],
    );
  }

  /// `App Preferences`
  String get appPreferences {
    return Intl.message(
      'App Preferences',
      name: 'appPreferences',
      desc: 'Label for the app preferences section',
      args: [],
    );
  }

  /// `Currency`
  String get currency {
    return Intl.message(
      'Currency',
      name: 'currency',
      desc: 'Label for the currency settings section',
      args: [],
    );
  }

  /// `Set your preferred currency`
  String get setYourPreferredCurrency {
    return Intl.message(
      'Set your preferred currency',
      name: 'setYourPreferredCurrency',
      desc: 'Message prompting the user to set their preferred currency',
      args: [],
    );
  }

  /// `App Theme`
  String get appTheme {
    return Intl.message(
      'App Theme',
      name: 'appTheme',
      desc: 'Label for the app theme settings section',
      args: [],
    );
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message(
      'Dark Mode',
      name: 'darkMode',
      desc: 'Label for the dark mode theme option',
      args: [],
    );
  }

  /// `Light Mode`
  String get lightMode {
    return Intl.message(
      'Light Mode',
      name: 'lightMode',
      desc: 'Label for the light mode theme option',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: 'Label for the language settings section',
      args: [],
    );
  }

  /// `Choose your preferred language`
  String get chooseYourPreferredLanguage {
    return Intl.message(
      'Choose your preferred language',
      name: 'chooseYourPreferredLanguage',
      desc: 'Message prompting the user to choose their preferred language',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: 'Label for the notifications section',
      args: [],
    );
  }

  /// `Budget Limits`
  String get budgetLimits {
    return Intl.message(
      'Budget Limits',
      name: 'budgetLimits',
      desc: 'Label for the budget limits section',
      args: [],
    );
  }

  /// `Get alerts when nearing budget limits`
  String get getAlertsWhenNearingBudgetLimits {
    return Intl.message(
      'Get alerts when nearing budget limits',
      name: 'getAlertsWhenNearingBudgetLimits',
      desc:
          'Message prompting the user to enable alerts for nearing budget limits',
      args: [],
    );
  }

  /// `Bill Payment Reminders`
  String get billPaymentReminders {
    return Intl.message(
      'Bill Payment Reminders',
      name: 'billPaymentReminders',
      desc: 'Label for the bill payment reminders section',
      args: [],
    );
  }

  /// `Never miss a payment deadline`
  String get neverMissAPaymentDeadline {
    return Intl.message(
      'Never miss a payment deadline',
      name: 'neverMissAPaymentDeadline',
      desc: 'Message encouraging the user to set up bill payment reminders',
      args: [],
    );
  }

  /// `Planning & Financial Goals`
  String get planningAndFinancialGoals {
    return Intl.message(
      'Planning & Financial Goals',
      name: 'planningAndFinancialGoals',
      desc: 'Label for the planning and financial goals section',
      args: [],
    );
  }

  /// `Savings Goals`
  String get savingsGoals {
    return Intl.message(
      'Savings Goals',
      name: 'savingsGoals',
      desc: 'Title for the savings goals screen',
      args: [],
    );
  }

  /// `Set and track savings targets`
  String get setAndTrackSavingsTargets {
    return Intl.message(
      'Set and track savings targets',
      name: 'setAndTrackSavingsTargets',
      desc: 'Message prompting the user to set and track savings targets',
      args: [],
    );
  }

  /// `Debt Repayment Plan`
  String get debtRepaymentPlan {
    return Intl.message(
      'Debt Repayment Plan',
      name: 'debtRepaymentPlan',
      desc: 'Title for the debt repayment plan screen',
      args: [],
    );
  }

  /// `Debt Summary`
  String get debtSummary {
    return Intl.message(
      'Debt Summary',
      name: 'debtSummary',
      desc: 'Title for debt summary section',
      args: [],
    );
  }

  /// `Total Debt`
  String get totalDebt {
    return Intl.message(
      'Total Debt',
      name: 'totalDebt',
      desc: 'Label for total debt amount',
      args: [],
    );
  }

  /// `Monthly Payment:`
  String get monthlyPayment {
    return Intl.message(
      'Monthly Payment:',
      name: 'monthlyPayment',
      desc: 'Label for monthly payment result',
      args: [],
    );
  }

  /// `Avg Interest`
  String get avgInterest {
    return Intl.message(
      'Avg Interest',
      name: 'avgInterest',
      desc: 'Label for average interest rate',
      args: [],
    );
  }

  /// `Active Debts`
  String get activeDebts {
    return Intl.message(
      'Active Debts',
      name: 'activeDebts',
      desc: 'Title for active debts section',
      args: [],
    );
  }

  /// `No active debts`
  String get noActiveDebts {
    return Intl.message(
      'No active debts',
      name: 'noActiveDebts',
      desc: 'Message shown when there are no active debts',
      args: [],
    );
  }

  /// ` paid`
  String get paid {
    return Intl.message(
      ' paid',
      name: 'paid',
      desc: 'Label for paid percentage',
      args: [],
    );
  }

  /// `Debt Analysis`
  String get debtAnalysis {
    return Intl.message(
      'Debt Analysis',
      name: 'debtAnalysis',
      desc: 'Title for debt analysis section',
      args: [],
    );
  }

  /// `Recommended Payoff Strategy`
  String get recommendedPayoffStrategy {
    return Intl.message(
      'Recommended Payoff Strategy',
      name: 'recommendedPayoffStrategy',
      desc: 'Title for recommended payoff strategy',
      args: [],
    );
  }

  /// `Debt Avalanche Method: Pay off debts in order of highest to lowest interest rate while maintaining minimum payments on all debts.`
  String get debtAvalancheMethod {
    return Intl.message(
      'Debt Avalanche Method: Pay off debts in order of highest to lowest interest rate while maintaining minimum payments on all debts.',
      name: 'debtAvalancheMethod',
      desc: 'Description of the debt avalanche method',
      args: [],
    );
  }

  /// `Priority Order:`
  String get priorityOrder {
    return Intl.message(
      'Priority Order:',
      name: 'priorityOrder',
      desc: 'Label for priority order list',
      args: [],
    );
  }

  /// `Add New Debt`
  String get addNewDebt {
    return Intl.message(
      'Add New Debt',
      name: 'addNewDebt',
      desc: 'Title for add new debt dialog',
      args: [],
    );
  }

  /// `Debt Name`
  String get debtName {
    return Intl.message(
      'Debt Name',
      name: 'debtName',
      desc: 'Label for debt name field',
      args: [],
    );
  }

  /// `Debt Type`
  String get debtType {
    return Intl.message(
      'Debt Type',
      name: 'debtType',
      desc: 'Label for debt type field',
      args: [],
    );
  }

  /// `Total Amount`
  String get totalAmount {
    return Intl.message(
      'Total Amount',
      name: 'totalAmount',
      desc: 'Label for total amount field',
      args: [],
    );
  }

  /// `Interest Rate`
  String get interestRatePercent {
    return Intl.message(
      'Interest Rate',
      name: 'interestRatePercent',
      desc: 'Label for interest rate field',
      args: [],
    );
  }

  /// `Minimum Monthly Payment`
  String get minimumMonthlyPayment {
    return Intl.message(
      'Minimum Monthly Payment',
      name: 'minimumMonthlyPayment',
      desc: 'Label for minimum monthly payment field',
      args: [],
    );
  }

  /// `Add Debt`
  String get addDebt {
    return Intl.message(
      'Add Debt',
      name: 'addDebt',
      desc: 'Label for add debt button',
      args: [],
    );
  }

  /// `Edit Debt`
  String get editDebt {
    return Intl.message(
      'Edit Debt',
      name: 'editDebt',
      desc: 'Title for edit debt dialog',
      args: [],
    );
  }

  /// `Save Changes`
  String get saveChanges {
    return Intl.message(
      'Save Changes',
      name: 'saveChanges',
      desc: 'Label for save changes button',
      args: [],
    );
  }

  /// `Add Payment`
  String get addPayment {
    return Intl.message(
      'Add Payment',
      name: 'addPayment',
      desc: 'Title for add payment dialog',
      args: [],
    );
  }

  /// `Current Balance: {amount}`
  String currentBalance(String amount) {
    return Intl.message(
      'Current Balance: $amount',
      name: 'currentBalance',
      desc: 'Label for current balance',
      args: [amount],
    );
  }

  /// `Payment Amount`
  String get paymentAmount {
    return Intl.message(
      'Payment Amount',
      name: 'paymentAmount',
      desc: 'Label for payment amount field',
      args: [],
    );
  }

  /// `Delete Debt`
  String get deleteDebt {
    return Intl.message(
      'Delete Debt',
      name: 'deleteDebt',
      desc: 'Title for delete debt confirmation dialog',
      args: [],
    );
  }

  /// `Are you sure you want to delete? This action cannot be undone.`
  String get deleteDebtConfirmation {
    return Intl.message(
      'Are you sure you want to delete? This action cannot be undone.',
      name: 'deleteDebtConfirmation',
      desc: 'Confirmation message for deleting a debt',
      args: [],
    );
  }

  /// `Retirement Planning`
  String get retirementPlanning {
    return Intl.message(
      'Retirement Planning',
      name: 'retirementPlanning',
      desc: 'Title for the retirement planning screen',
      args: [],
    );
  }

  /// `Create Retirement Plan`
  String get createRetirementPlan {
    return Intl.message(
      'Create Retirement Plan',
      name: 'createRetirementPlan',
      desc: 'Button text for creating a new retirement plan',
      args: [],
    );
  }

  /// `Retirement Summary`
  String get retirementSummary {
    return Intl.message(
      'Retirement Summary',
      name: 'retirementSummary',
      desc: 'Title for retirement summary section',
      args: [],
    );
  }

  /// `Current Age`
  String get currentAge {
    return Intl.message(
      'Current Age',
      name: 'currentAge',
      desc: 'Label for current age',
      args: [],
    );
  }

  /// `Retirement Age`
  String get retirementAge {
    return Intl.message(
      'Retirement Age',
      name: 'retirementAge',
      desc: 'Label for retirement age',
      args: [],
    );
  }

  /// `Years Until Retirement`
  String get yearsUntilRetirement {
    return Intl.message(
      'Years Until Retirement',
      name: 'yearsUntilRetirement',
      desc: 'Label for years until retirement',
      args: [],
    );
  }

  /// `Current Savings`
  String get currentSavings {
    return Intl.message(
      'Current Savings',
      name: 'currentSavings',
      desc: 'Label for current savings amount',
      args: [],
    );
  }

  /// `Monthly Contribution`
  String get monthlyContribution {
    return Intl.message(
      'Monthly Contribution',
      name: 'monthlyContribution',
      desc: 'Label for monthly contribution amount',
      args: [],
    );
  }

  /// `Retirement Projections`
  String get retirementProjections {
    return Intl.message(
      'Retirement Projections',
      name: 'retirementProjections',
      desc: 'Title for retirement projections section',
      args: [],
    );
  }

  /// `Projected Retirement Savings`
  String get projectedRetirementSavings {
    return Intl.message(
      'Projected Retirement Savings',
      name: 'projectedRetirementSavings',
      desc: 'Label for projected retirement savings',
      args: [],
    );
  }

  /// `Monthly Retirement Income`
  String get monthlyRetirementIncome {
    return Intl.message(
      'Monthly Retirement Income',
      name: 'monthlyRetirementIncome',
      desc: 'Label for monthly retirement income',
      args: [],
    );
  }

  /// `Desired Monthly Income`
  String get desiredMonthlyIncome {
    return Intl.message(
      'Desired Monthly Income',
      name: 'desiredMonthlyIncome',
      desc: 'Label for desired monthly income',
      args: [],
    );
  }

  /// `Funding Progress: {percentage}%`
  String fundingProgress(int percentage) {
    return Intl.message(
      'Funding Progress: $percentage%',
      name: 'fundingProgress',
      desc: 'Label for funding progress percentage',
      args: [percentage],
    );
  }

  /// `Consider increasing your monthly contribution to reach your retirement goal.`
  String get recommendationIncreaseContribution {
    return Intl.message(
      'Consider increasing your monthly contribution to reach your retirement goal.',
      name: 'recommendationIncreaseContribution',
      desc: 'Recommendation to increase monthly contribution',
      args: [],
    );
  }

  /// `Your expected return seems conservative. Consider diversifying your investments.`
  String get recommendationDiversifyInvestments {
    return Intl.message(
      'Your expected return seems conservative. Consider diversifying your investments.',
      name: 'recommendationDiversifyInvestments',
      desc: 'Recommendation to diversify investments',
      args: [],
    );
  }

  /// `Your current savings rate might be too low. Aim to save at least 10-15% of your income.`
  String get recommendationIncreaseSavingsRate {
    return Intl.message(
      'Your current savings rate might be too low. Aim to save at least 10-15% of your income.',
      name: 'recommendationIncreaseSavingsRate',
      desc: 'Recommendation to increase savings rate',
      args: [],
    );
  }

  /// `Early retirement requires more savings. Make sure your plan accounts for a longer retirement period.`
  String get recommendationEarlyRetirement {
    return Intl.message(
      'Early retirement requires more savings. Make sure your plan accounts for a longer retirement period.',
      name: 'recommendationEarlyRetirement',
      desc: 'Recommendation for early retirement planning',
      args: [],
    );
  }

  /// `You're on track with your retirement goals!`
  String get recommendationOnTrack {
    return Intl.message(
      'You\'re on track with your retirement goals!',
      name: 'recommendationOnTrack',
      desc:
          'Message indicating the user is on track with their retirement goals',
      args: [],
    );
  }

  /// `Financial Calculator`
  String get financialCalculator {
    return Intl.message(
      'Financial Calculator',
      name: 'financialCalculator',
      desc: 'Title for the financial calculator screen',
      args: [],
    );
  }

  /// `Loan Calculator`
  String get loanCalculator {
    return Intl.message(
      'Loan Calculator',
      name: 'loanCalculator',
      desc: 'Title for loan calculator',
      args: [],
    );
  }

  /// `Calculate loan payments and total interest`
  String get loanCalculatorDescription {
    return Intl.message(
      'Calculate loan payments and total interest',
      name: 'loanCalculatorDescription',
      desc: 'Description for loan calculator',
      args: [],
    );
  }

  /// `Investment Calculator`
  String get investmentCalculator {
    return Intl.message(
      'Investment Calculator',
      name: 'investmentCalculator',
      desc: 'Title for investment calculator',
      args: [],
    );
  }

  /// `Calculate investment growth and returns`
  String get investmentCalculatorDescription {
    return Intl.message(
      'Calculate investment growth and returns',
      name: 'investmentCalculatorDescription',
      desc: 'Description for investment calculator',
      args: [],
    );
  }

  /// `Savings Goal Calculator`
  String get savingsGoalCalculator {
    return Intl.message(
      'Savings Goal Calculator',
      name: 'savingsGoalCalculator',
      desc: 'Title for savings goal calculator',
      args: [],
    );
  }

  /// `Calculate monthly savings needed`
  String get savingsGoalCalculatorDescription {
    return Intl.message(
      'Calculate monthly savings needed',
      name: 'savingsGoalCalculatorDescription',
      desc: 'Description for savings goal calculator',
      args: [],
    );
  }

  /// `Mortgage Calculator`
  String get mortgageCalculator {
    return Intl.message(
      'Mortgage Calculator',
      name: 'mortgageCalculator',
      desc: 'Title for mortgage calculator',
      args: [],
    );
  }

  /// `Calculate mortgage payments and amortization`
  String get mortgageCalculatorDescription {
    return Intl.message(
      'Calculate mortgage payments and amortization',
      name: 'mortgageCalculatorDescription',
      desc: 'Description for mortgage calculator',
      args: [],
    );
  }

  /// `Loan Amount`
  String get loanAmount {
    return Intl.message(
      'Loan Amount',
      name: 'loanAmount',
      desc: 'Label for loan amount field',
      args: [],
    );
  }

  /// `Annual Interest Rate (%)`
  String get annualInterestRate {
    return Intl.message(
      'Annual Interest Rate (%)',
      name: 'annualInterestRate',
      desc: 'Label for annual interest rate field',
      args: [],
    );
  }

  /// `Loan Term (months)`
  String get loanTerm {
    return Intl.message(
      'Loan Term (months)',
      name: 'loanTerm',
      desc: 'Label for loan term field',
      args: [],
    );
  }

  /// `Calculate`
  String get calculate {
    return Intl.message(
      'Calculate',
      name: 'calculate',
      desc: 'Label for calculate button',
      args: [],
    );
  }

  /// `Loan Calculation Results`
  String get loanCalculationResults {
    return Intl.message(
      'Loan Calculation Results',
      name: 'loanCalculationResults',
      desc: 'Title for loan calculation results',
      args: [],
    );
  }

  /// `Total Interest:`
  String get totalInterest {
    return Intl.message(
      'Total Interest:',
      name: 'totalInterest',
      desc: 'Label for total interest result',
      args: [],
    );
  }

  /// `Total Payment:`
  String get totalPayment {
    return Intl.message(
      'Total Payment:',
      name: 'totalPayment',
      desc: 'Label for total payment result',
      args: [],
    );
  }

  /// `Initial Investment`
  String get initialInvestment {
    return Intl.message(
      'Initial Investment',
      name: 'initialInvestment',
      desc: 'Label for initial investment field',
      args: [],
    );
  }

  /// `Annual Return Rate`
  String get annualReturnRate {
    return Intl.message(
      'Annual Return Rate',
      name: 'annualReturnRate',
      desc: 'Label for annual return rate field',
      args: [],
    );
  }

  /// `Investment Period (years)`
  String get investmentPeriod {
    return Intl.message(
      'Investment Period (years)',
      name: 'investmentPeriod',
      desc: 'Label for investment period field',
      args: [],
    );
  }

  /// `Investment Calculation Results`
  String get investmentCalculationResults {
    return Intl.message(
      'Investment Calculation Results',
      name: 'investmentCalculationResults',
      desc: 'Title for investment calculation results',
      args: [],
    );
  }

  /// `Future Value:`
  String get futureValue {
    return Intl.message(
      'Future Value:',
      name: 'futureValue',
      desc: 'Label for future value result',
      args: [],
    );
  }

  /// `Total Contributions:`
  String get totalContributions {
    return Intl.message(
      'Total Contributions:',
      name: 'totalContributions',
      desc: 'Label for total contributions result',
      args: [],
    );
  }

  /// `Total Earnings:`
  String get totalEarnings {
    return Intl.message(
      'Total Earnings:',
      name: 'totalEarnings',
      desc: 'Label for total earnings result',
      args: [],
    );
  }

  /// `Goal Amount`
  String get goalAmount {
    return Intl.message(
      'Goal Amount',
      name: 'goalAmount',
      desc: 'Label for goal amount field',
      args: [],
    );
  }

  /// `Time to Goal (months)`
  String get timeToGoal {
    return Intl.message(
      'Time to Goal (months)',
      name: 'timeToGoal',
      desc: 'Label for time to goal field',
      args: [],
    );
  }

  /// `Initial Savings`
  String get initialSavings {
    return Intl.message(
      'Initial Savings',
      name: 'initialSavings',
      desc: 'Label for initial savings field',
      args: [],
    );
  }

  /// `Savings Goal Calculation Results`
  String get savingsGoalCalculationResults {
    return Intl.message(
      'Savings Goal Calculation Results',
      name: 'savingsGoalCalculationResults',
      desc: 'Title for savings goal calculation results',
      args: [],
    );
  }

  /// `Required Monthly Savings:`
  String get requiredMonthlySavings {
    return Intl.message(
      'Required Monthly Savings:',
      name: 'requiredMonthlySavings',
      desc: 'Label for required monthly savings result',
      args: [],
    );
  }

  /// `Total Savings Needed:`
  String get totalSavingsNeeded {
    return Intl.message(
      'Total Savings Needed:',
      name: 'totalSavingsNeeded',
      desc: 'Label for total savings needed result',
      args: [],
    );
  }

  /// `Time to Goal:`
  String get timeToGoalResult {
    return Intl.message(
      'Time to Goal:',
      name: 'timeToGoalResult',
      desc: 'Label for time to goal result',
      args: [],
    );
  }

  /// `Home Price`
  String get homePrice {
    return Intl.message(
      'Home Price',
      name: 'homePrice',
      desc: 'Label for home price field',
      args: [],
    );
  }

  /// `Down Payment`
  String get downPayment {
    return Intl.message(
      'Down Payment',
      name: 'downPayment',
      desc: 'Label for down payment field',
      args: [],
    );
  }

  /// `Loan Term (years)`
  String get loanTermYears {
    return Intl.message(
      'Loan Term (years)',
      name: 'loanTermYears',
      desc: 'Label for loan term in years field',
      args: [],
    );
  }

  /// `Mortgage Calculation Results`
  String get mortgageCalculationResults {
    return Intl.message(
      'Mortgage Calculation Results',
      name: 'mortgageCalculationResults',
      desc: 'Title for mortgage calculation results',
      args: [],
    );
  }

  /// `Total Cost:`
  String get totalCost {
    return Intl.message(
      'Total Cost:',
      name: 'totalCost',
      desc: 'Label for total cost result',
      args: [],
    );
  }

  /// `Down Payment:`
  String get downPaymentPercentage {
    return Intl.message(
      'Down Payment:',
      name: 'downPaymentPercentage',
      desc: 'Label for down payment percentage result',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: 'Label for OK button',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: 'Title for the profile screen',
      args: [],
    );
  }

  /// `Profile not available`
  String get profileNotAvailable {
    return Intl.message(
      'Profile not available',
      name: 'profileNotAvailable',
      desc: 'Message shown when profile is not available',
      args: [],
    );
  }

  /// `No Name`
  String get noName {
    return Intl.message(
      'No Name',
      name: 'noName',
      desc: 'Default text when user name is not set',
      args: [],
    );
  }

  /// `Personal Information`
  String get personalInformation {
    return Intl.message(
      'Personal Information',
      name: 'personalInformation',
      desc: 'Title for personal information section',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: 'Label for phone number',
      args: [],
    );
  }

  /// `Not set`
  String get notSet {
    return Intl.message(
      'Not set',
      name: 'notSet',
      desc: 'Text shown when a field is not set',
      args: [],
    );
  }

  /// `Date of Birth`
  String get dateOfBirth {
    return Intl.message(
      'Date of Birth',
      name: 'dateOfBirth',
      desc: 'Label for date of birth',
      args: [],
    );
  }

  /// `Financial Information`
  String get financialInformation {
    return Intl.message(
      'Financial Information',
      name: 'financialInformation',
      desc: 'Title for financial information section',
      args: [],
    );
  }

  /// `Monthly Income`
  String get monthlyIncome {
    return Intl.message(
      'Monthly Income',
      name: 'monthlyIncome',
      desc: 'Label for monthly income',
      args: [],
    );
  }

  /// `Preferred Currency`
  String get preferredCurrency {
    return Intl.message(
      'Preferred Currency',
      name: 'preferredCurrency',
      desc: 'Label for preferred currency',
      args: [],
    );
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: 'Title for edit profile dialog',
      args: [],
    );
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: 'Label for phone number field',
      args: [],
    );
  }

  /// `Occupation`
  String get occupation {
    return Intl.message(
      'Occupation',
      name: 'occupation',
      desc: 'Label for occupation field',
      args: [],
    );
  }

  /// `Please enter your name`
  String get pleaseEnterName {
    return Intl.message(
      'Please enter your name',
      name: 'pleaseEnterName',
      desc: 'Validation message for name field',
      args: [],
    );
  }

  /// `Subscription Plan`
  String get subscriptionPlan {
    return Intl.message(
      'Subscription Plan',
      name: 'subscriptionPlan',
      desc: 'Title for the subscription plan screen',
      args: [],
    );
  }

  /// `Current Plan`
  String get currentPlan {
    return Intl.message(
      'Current Plan',
      name: 'currentPlan',
      desc: 'Title for current plan section',
      args: [],
    );
  }

  /// `{days} days remaining`
  String daysRemaining(int days) {
    return Intl.message(
      '$days days remaining',
      name: 'daysRemaining',
      desc: 'Label for days remaining in subscription',
      args: [days],
    );
  }

  /// `Expired`
  String get expired {
    return Intl.message(
      'Expired',
      name: 'expired',
      desc: 'Label for expired subscription',
      args: [],
    );
  }

  /// `Available Plans`
  String get availablePlans {
    return Intl.message(
      'Available Plans',
      name: 'availablePlans',
      desc: 'Title for available plans section',
      args: [],
    );
  }

  /// `Basic Plan`
  String get basicPlan {
    return Intl.message(
      'Basic Plan',
      name: 'basicPlan',
      desc: 'Title for basic subscription plan',
      args: [],
    );
  }

  /// `Perfect for personal finance tracking`
  String get basicPlanDescription {
    return Intl.message(
      'Perfect for personal finance tracking',
      name: 'basicPlanDescription',
      desc: 'Description for basic subscription plan',
      args: [],
    );
  }

  /// `Premium Plan`
  String get premiumPlan {
    return Intl.message(
      'Premium Plan',
      name: 'premiumPlan',
      desc: 'Title for premium subscription plan',
      args: [],
    );
  }

  /// `Advanced features for power users`
  String get premiumPlanDescription {
    return Intl.message(
      'Advanced features for power users',
      name: 'premiumPlanDescription',
      desc: 'Description for premium subscription plan',
      args: [],
    );
  }

  /// `Unlimited transactions`
  String get unlimitedTransactions {
    return Intl.message(
      'Unlimited transactions',
      name: 'unlimitedTransactions',
      desc: 'Feature in subscription plan',
      args: [],
    );
  }

  /// `Basic reports`
  String get basicReports {
    return Intl.message(
      'Basic reports',
      name: 'basicReports',
      desc: 'Feature in subscription plan',
      args: [],
    );
  }

  /// `Email support`
  String get emailSupport {
    return Intl.message(
      'Email support',
      name: 'emailSupport',
      desc: 'Feature in subscription plan',
      args: [],
    );
  }

  /// `Advanced analytics`
  String get advancedAnalytics {
    return Intl.message(
      'Advanced analytics',
      name: 'advancedAnalytics',
      desc: 'Feature in subscription plan',
      args: [],
    );
  }

  /// `Priority support`
  String get prioritySupport {
    return Intl.message(
      'Priority support',
      name: 'prioritySupport',
      desc: 'Feature in subscription plan',
      args: [],
    );
  }

  /// `Custom categories`
  String get customCategories {
    return Intl.message(
      'Custom categories',
      name: 'customCategories',
      desc: 'Feature in subscription plan',
      args: [],
    );
  }

  /// `Data export`
  String get dataExport {
    return Intl.message(
      'Data export',
      name: 'dataExport',
      desc: 'Feature in subscription plan',
      args: [],
    );
  }

  /// `/month`
  String get perMonth {
    return Intl.message(
      '/month',
      name: 'perMonth',
      desc: 'Label for monthly subscription price',
      args: [],
    );
  }

  /// `Subscribe`
  String get subscribe {
    return Intl.message(
      'Subscribe',
      name: 'subscribe',
      desc: 'Label for subscribe button',
      args: [],
    );
  }

  /// `Confirm Subscription`
  String get confirmSubscription {
    return Intl.message(
      'Confirm Subscription',
      name: 'confirmSubscription',
      desc: 'Title for subscription confirmation dialog',
      args: [],
    );
  }

  /// `You are about to subscribe to the plan.`
  String get subscriptionConfirmation {
    return Intl.message(
      'You are about to subscribe to the plan.',
      name: 'subscriptionConfirmation',
      desc: 'Confirmation message for subscription',
      args: [],
    );
  }

  /// `Subscription updated successfully`
  String get subscriptionUpdated {
    return Intl.message(
      'Subscription updated successfully',
      name: 'subscriptionUpdated',
      desc: 'Success message when subscription is updated',
      args: [],
    );
  }

  /// `Insufficient Balance`
  String get insufficientBalance {
    return Intl.message(
      'Insufficient Balance',
      name: 'insufficientBalance',
      desc: 'Insufficient Balance description',
      args: [],
    );
  }

  /// `Transfer completed successfully`
  String get transferCompletedSuccessfully {
    return Intl.message(
      'Transfer completed successfully',
      name: 'transferCompletedSuccessfully',
      desc: 'Message displayed when a transfer is successfully completed',
      args: [],
    );
  }

  /// `Or sign up with`
  String get orSignUpWith {
    return Intl.message(
      'Or sign up with',
      name: 'orSignUpWith',
      desc: 'Text displayed between dividers for alternative sign-up methods',
      args: [],
    );
  }

  /// `Validation Failed`
  String get validationFailed {
    return Intl.message(
      'Validation Failed',
      name: 'validationFailed',
      desc: 'Title for validation error',
      args: [],
    );
  }

  /// `Please agree to Terms & Conditions`
  String get pleaseAgreeToTerms {
    return Intl.message(
      'Please agree to Terms & Conditions',
      name: 'pleaseAgreeToTerms',
      desc: 'Message asking user to agree to terms',
      args: [],
    );
  }

  /// `Sent`
  String get sent {
    return Intl.message(
      'Sent',
      name: 'sent',
      desc: 'Title for success message',
      args: [],
    );
  }

  /// `Password reset email sent. Please check your inbox.`
  String get passwordResetEmailSent {
    return Intl.message(
      'Password reset email sent. Please check your inbox.',
      name: 'passwordResetEmailSent',
      desc: 'Message shown when password reset email is sent',
      args: [],
    );
  }

  /// `Reset link has been sent to your email`
  String get resetLinkSent {
    return Intl.message(
      'Reset link has been sent to your email',
      name: 'resetLinkSent',
      desc: 'Message shown when reset link is sent',
      args: [],
    );
  }

  /// `Send Reset Link`
  String get sendResetLink {
    return Intl.message(
      'Send Reset Link',
      name: 'sendResetLink',
      desc: 'Button text for sending reset link',
      args: [],
    );
  }

  /// `Back to Login`
  String get backToLogin {
    return Intl.message(
      'Back to Login',
      name: 'backToLogin',
      desc: 'Button text to go back to login screen',
      args: [],
    );
  }

  /// `Google`
  String get google {
    return Intl.message(
      'Google',
      name: 'google',
      desc: 'Label for Google sign in button',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: 'Button text for login',
      args: [],
    );
  }

  /// `Forgot Password`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password',
      name: 'forgotPassword',
      desc: 'Title for forgot password screen',
      args: [],
    );
  }

  /// `Please enter your email address`
  String get pleaseEnterYourEmail {
    return Intl.message(
      'Please enter your email address',
      name: 'pleaseEnterYourEmail',
      desc: 'Message prompting user to enter their email',
      args: [],
    );
  }

  /// `Email Address`
  String get emailAddress {
    return Intl.message(
      'Email Address',
      name: 'emailAddress',
      desc: 'Label for email address field',
      args: [],
    );
  }

  /// `Please enter a valid email address`
  String get pleaseEnterAValidEmail {
    return Intl.message(
      'Please enter a valid email address',
      name: 'pleaseEnterAValidEmail',
      desc: 'Validation message for invalid email',
      args: [],
    );
  }

  /// `Welcome Back`
  String get welcomeBack {
    return Intl.message(
      'Welcome Back',
      name: 'welcomeBack',
      desc: 'Welcome message on login screen',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: 'Label for password field',
      args: [],
    );
  }

  /// `Please enter your password`
  String get pleaseEnterYourPassword {
    return Intl.message(
      'Please enter your password',
      name: 'pleaseEnterYourPassword',
      desc: 'Message prompting user to enter their password',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get passwordMustBeAtLeast6Characters {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'passwordMustBeAtLeast6Characters',
      desc: 'Validation message for password length',
      args: [],
    );
  }

  /// `Don't have an account? `
  String get dontHaveAccount {
    return Intl.message(
      'Don\'t have an account? ',
      name: 'dontHaveAccount',
      desc: 'Text prompting user to sign up',
      args: [],
    );
  }

  /// `Sign Up`
  String get signUp {
    return Intl.message(
      'Sign Up',
      name: 'signUp',
      desc: 'Button text for sign up',
      args: [],
    );
  }

  /// `Create Your Account`
  String get createYourAccount {
    return Intl.message(
      'Create Your Account',
      name: 'createYourAccount',
      desc: 'Title for sign up screen',
      args: [],
    );
  }

  /// `Card Details`
  String get cardDetails {
    return Intl.message(
      'Card Details',
      name: 'cardDetails',
      desc: 'Title for card details screen',
      args: [],
    );
  }

  /// `Type`
  String get typeLabel {
    return Intl.message(
      'Type',
      name: 'typeLabel',
      desc: 'Label for card type',
      args: [],
    );
  }

  /// `Number`
  String get number {
    return Intl.message(
      'Number',
      name: 'number',
      desc: 'Label for card number',
      args: [],
    );
  }

  /// `Delete Card`
  String get deleteCard {
    return Intl.message(
      'Delete Card',
      name: 'deleteCard',
      desc: 'Button text for deleting a card',
      args: [],
    );
  }

  /// `Are you sure you want to delete this card?`
  String get areYouSureYouWantToDeleteThisCard {
    return Intl.message(
      'Are you sure you want to delete this card?',
      name: 'areYouSureYouWantToDeleteThisCard',
      desc: 'Confirmation message for deleting a card',
      args: [],
    );
  }

  /// `Deleted`
  String get deleted {
    return Intl.message(
      'Deleted',
      name: 'deleted',
      desc: 'Title for deletion success message',
      args: [],
    );
  }

  /// `Card deleted successfully`
  String get cardDeletedSuccessfully {
    return Intl.message(
      'Card deleted successfully',
      name: 'cardDeletedSuccessfully',
      desc: 'Success message when card is deleted',
      args: [],
    );
  }

  /// `Manage and track debt payments`
  String get manageAndTrackDebtPayments {
    return Intl.message(
      'Manage and track debt payments',
      name: 'manageAndTrackDebtPayments',
      desc: 'Description for debt repayment plan feature',
      args: [],
    );
  }

  /// `Plan for your retirement`
  String get planForYourRetirement {
    return Intl.message(
      'Plan for your retirement',
      name: 'planForYourRetirement',
      desc: 'Description for retirement planning feature',
      args: [],
    );
  }

  /// `I agree to the Terms & Conditions`
  String get agreeToTerms {
    return Intl.message(
      'I agree to the Terms & Conditions',
      name: 'agreeToTerms',
      desc: 'Text for terms and conditions checkbox',
      args: [],
    );
  }

  /// `Already have an account? `
  String get alreadyHaveAnAccount {
    return Intl.message(
      'Already have an account? ',
      name: 'alreadyHaveAnAccount',
      desc: 'Text prompting user to login',
      args: [],
    );
  }

  /// `Calculate loans, investments and more`
  String get calculateLoansInvestmentsAndMore {
    return Intl.message(
      'Calculate loans, investments and more',
      name: 'calculateLoansInvestmentsAndMore',
      desc: 'Description for financial calculator feature',
      args: [],
    );
  }

  /// `Account Settings`
  String get accountSettings {
    return Intl.message(
      'Account Settings',
      name: 'accountSettings',
      desc: 'Title for account settings section',
      args: [],
    );
  }

  /// `Manage personal information`
  String get managePersonalInformation {
    return Intl.message(
      'Manage personal information',
      name: 'managePersonalInformation',
      desc: 'Description for profile management',
      args: [],
    );
  }

  /// `Manage your subscription`
  String get manageYourSubscription {
    return Intl.message(
      'Manage your subscription',
      name: 'manageYourSubscription',
      desc: 'Description for subscription management',
      args: [],
    );
  }

  /// `Security`
  String get security {
    return Intl.message(
      'Security',
      name: 'security',
      desc: 'Title for security settings section',
      args: [],
    );
  }

  /// `App lock, biometrics and backup`
  String get appLockBiometricsAndBackup {
    return Intl.message(
      'App lock, biometrics and backup',
      name: 'appLockBiometricsAndBackup',
      desc: 'Description for security features',
      args: [],
    );
  }

  /// `Data Backup & Sync`
  String get dataBackupAndSync {
    return Intl.message(
      'Data Backup & Sync',
      name: 'dataBackupAndSync',
      desc: 'Title for data backup and sync section',
      args: [],
    );
  }

  /// `Manage your data across devices`
  String get manageYourDataAcrossDevices {
    return Intl.message(
      'Manage your data across devices',
      name: 'manageYourDataAcrossDevices',
      desc: 'Description for data management across devices',
      args: [],
    );
  }

  /// `More`
  String get more {
    return Intl.message(
      'More',
      name: 'more',
      desc: 'Title for additional settings section',
      args: [],
    );
  }

  /// `Help & Support`
  String get helpAndSupport {
    return Intl.message(
      'Help & Support',
      name: 'helpAndSupport',
      desc: 'Title for help and support section',
      args: [],
    );
  }

  /// `FAQ, Contact and Support`
  String get faqContactAndSupport {
    return Intl.message(
      'FAQ, Contact and Support',
      name: 'faqContactAndSupport',
      desc: 'Description for help and support features',
      args: [],
    );
  }

  /// `Terms & Privacy`
  String get termsAndPrivacy {
    return Intl.message(
      'Terms & Privacy',
      name: 'termsAndPrivacy',
      desc: 'Title for terms and privacy section',
      args: [],
    );
  }

  /// `Terms of Service`
  String get termsOfService {
    return Intl.message(
      'Terms of Service',
      name: 'termsOfService',
      desc: 'Title for terms of service',
      args: [],
    );
  }

  /// `About App`
  String get aboutApp {
    return Intl.message(
      'About App',
      name: 'aboutApp',
      desc: 'Title for about app section',
      args: [],
    );
  }

  /// `Sign Out`
  String get signOut {
    return Intl.message(
      'Sign Out',
      name: 'signOut',
      desc: 'Button text for signing out',
      args: [],
    );
  }

  /// `Support the App`
  String get supportTheApp {
    return Intl.message(
      'Support the App',
      name: 'supportTheApp',
      desc: 'Title for app support section',
      args: [],
    );
  }

  /// `Donate`
  String get donate {
    return Intl.message(
      'Donate',
      name: 'donate',
      desc: 'Button text for donating',
      args: [],
    );
  }

  /// `Watch Ad`
  String get watchAd {
    return Intl.message(
      'Watch Ad',
      name: 'watchAd',
      desc: 'Button text for watching an ad',
      args: [],
    );
  }

  /// `Are you sure you want to sign out?`
  String get areYouSureYouWantToSignOut {
    return Intl.message(
      'Are you sure you want to sign out?',
      name: 'areYouSureYouWantToSignOut',
      desc: 'Confirmation message for signing out',
      args: [],
    );
  }

  /// `Frequently Asked Questions`
  String get frequentlyAskedQuestions {
    return Intl.message(
      'Frequently Asked Questions',
      name: 'frequentlyAskedQuestions',
      desc: 'Title for FAQ section',
      args: [],
    );
  }

  /// `Contact Support`
  String get contactSupport {
    return Intl.message(
      'Contact Support',
      name: 'contactSupport',
      desc: 'Title for contact support section',
      args: [],
    );
  }

  /// `Live Chat Support`
  String get liveChatSupport {
    return Intl.message(
      'Live Chat Support',
      name: 'liveChatSupport',
      desc: 'Title for live chat support',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: 'Button text for closing',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: 'Title for privacy policy',
      args: [],
    );
  }

  /// `Data Usage`
  String get dataUsage {
    return Intl.message(
      'Data Usage',
      name: 'dataUsage',
      desc: 'Title for data usage section',
      args: [],
    );
  }

  /// `Scan to Donate`
  String get scanToDonate {
    return Intl.message(
      'Scan to Donate',
      name: 'scanToDonate',
      desc: 'Text for QR code scanning to donate',
      args: [],
    );
  }

  /// `Delete Settlement`
  String get deleteSettlement {
    return Intl.message(
      'Delete Settlement',
      name: 'deleteSettlement',
      desc: 'Button text for deleting a settlement',
      args: [],
    );
  }

  /// `Are you sure you want to delete this settlement?`
  String get confirmDeleteSettlement {
    return Intl.message(
      'Are you sure you want to delete this settlement?',
      name: 'confirmDeleteSettlement',
      desc: 'Confirmation message for deleting a settlement',
      args: [],
    );
  }

  /// `Settlement deleted successfully`
  String get settlementDeletedSuccessfully {
    return Intl.message(
      'Settlement deleted successfully',
      name: 'settlementDeletedSuccessfully',
      desc: 'Success message when settlement is deleted',
      args: [],
    );
  }

  /// `Error generating report: {error}`
  String errorGeneratingReport(String error) {
    return Intl.message(
      'Error generating report: $error',
      name: 'errorGeneratingReport',
      desc: 'Error message when report generation fails',
      args: [error],
    );
  }

  /// `Avg. Monthly Income`
  String get avgMonthlyIncome {
    return Intl.message(
      'Avg. Monthly Income',
      name: 'avgMonthlyIncome',
      desc: 'Label for average monthly income',
      args: [],
    );
  }

  /// `Avg. Monthly Expense`
  String get avgMonthlyExpense {
    return Intl.message(
      'Avg. Monthly Expense',
      name: 'avgMonthlyExpense',
      desc: 'Label for average monthly expense',
      args: [],
    );
  }

  /// `Growth Rate`
  String get growthRate {
    return Intl.message(
      'Growth Rate',
      name: 'growthRate',
      desc: 'Label for growth rate',
      args: [],
    );
  }

  /// `6-month trend`
  String get sixMonthTrend {
    return Intl.message(
      '6-month trend',
      name: 'sixMonthTrend',
      desc: 'Label for 6-month trend',
      args: [],
    );
  }

  /// `Projected Savings`
  String get projectedSavings {
    return Intl.message(
      'Projected Savings',
      name: 'projectedSavings',
      desc: 'Label for projected savings',
      args: [],
    );
  }

  /// `Budget Performance`
  String get budgetPerformance {
    return Intl.message(
      'Budget Performance',
      name: 'budgetPerformance',
      desc: 'Label for budget performance section',
      args: [],
    );
  }

  /// `Income vs Expenses (6 Months)`
  String get incomeVsExpensesSixMonths {
    return Intl.message(
      'Income vs Expenses (6 Months)',
      name: 'incomeVsExpensesSixMonths',
      desc: 'Label for income vs expenses analysis over six months',
      args: [],
    );
  }

  /// `Financial Health Indicators`
  String get financialHealthIndicators {
    return Intl.message(
      'Financial Health Indicators',
      name: 'financialHealthIndicators',
      desc: 'Label for financial health indicators section',
      args: [],
    );
  }

  /// `Overall Health Score`
  String get overallHealthScore {
    return Intl.message(
      'Overall Health Score',
      name: 'overallHealthScore',
      desc: 'Label for overall health score indicator',
      args: [],
    );
  }

  /// `Debt to Asset Ratio`
  String get debtToAssetRatio {
    return Intl.message(
      'Debt to Asset Ratio',
      name: 'debtToAssetRatio',
      desc: 'Label for debt to asset ratio indicator',
      args: [],
    );
  }

  /// `Good`
  String get good {
    return Intl.message(
      'Good',
      name: 'good',
      desc: 'Status indicating a positive condition',
      args: [],
    );
  }

  /// `Needs Attention`
  String get needsAttention {
    return Intl.message(
      'Needs Attention',
      name: 'needsAttention',
      desc: 'Status indicating a condition that requires attention',
      args: [],
    );
  }

  /// `Investment Rate`
  String get investmentRate {
    return Intl.message(
      'Investment Rate',
      name: 'investmentRate',
      desc: 'Label for investment rate indicator',
      args: [],
    );
  }

  /// `Could Improve`
  String get couldImprove {
    return Intl.message(
      'Could Improve',
      name: 'couldImprove',
      desc: 'Status indicating room for improvement',
      args: [],
    );
  }

  /// `Financial Overview`
  String get financialOverview {
    return Intl.message(
      'Financial Overview',
      name: 'financialOverview',
      desc: 'Title for the financial overview section',
      args: [],
    );
  }

  /// `Savings Analysis`
  String get savingsAnalysis {
    return Intl.message(
      'Savings Analysis',
      name: 'savingsAnalysis',
      desc: 'Title for the savings analysis section',
      args: [],
    );
  }

  /// `Savings Rate`
  String get savingsRate {
    return Intl.message(
      'Savings Rate',
      name: 'savingsRate',
      desc: 'Label for savings rate indicator',
      args: [],
    );
  }

  /// `Expense Ratio`
  String get expenseRatio {
    return Intl.message(
      'Expense Ratio',
      name: 'expenseRatio',
      desc: 'Label for expense ratio indicator',
      args: [],
    );
  }

  /// `Overall Performance`
  String get overallPerformance {
    return Intl.message(
      'Overall Performance',
      name: 'overallPerformance',
      desc: 'Title for the overall performance section',
      args: [],
    );
  }

  /// `Actual Expenses`
  String get actualExpenses {
    return Intl.message(
      'Actual Expenses',
      name: 'actualExpenses',
      desc: 'Label for actual expenses indicator',
      args: [],
    );
  }

  /// `Variance`
  String get variance {
    return Intl.message(
      'Variance',
      name: 'variance',
      desc: 'Label for variance indicator',
      args: [],
    );
  }

  /// `Budget Utilization`
  String get budgetUtilization {
    return Intl.message(
      'Budget Utilization',
      name: 'budgetUtilization',
      desc: 'Label for budget utilization indicator',
      args: [],
    );
  }

  /// `Category Breakdown`
  String get categoryBreakdown {
    return Intl.message(
      'Category Breakdown',
      name: 'categoryBreakdown',
      desc: 'Title for the category breakdown section',
      args: [],
    );
  }

  /// `Actual`
  String get actual {
    return Intl.message(
      'Actual',
      name: 'actual',
      desc: 'Label for actual value indicator',
      args: [],
    );
  }

  /// `Select Date Range`
  String get selectDateRange {
    return Intl.message(
      'Select Date Range',
      name: 'selectDateRange',
      desc: 'Label for selecting a date range',
      args: [],
    );
  }

  /// `Last 90 Days`
  String get last90Days {
    return Intl.message(
      'Last 90 Days',
      name: 'last90Days',
      desc: 'Option for selecting the last 90 days',
      args: [],
    );
  }

  /// `This Year`
  String get thisYear {
    return Intl.message(
      'This Year',
      name: 'thisYear',
      desc: 'Option for selecting the current year',
      args: [],
    );
  }

  /// `Transactions Report`
  String get transactionsReport {
    return Intl.message(
      'Transactions Report',
      name: 'transactionsReport',
      desc: 'Title for the transactions report section',
      args: [],
    );
  }

  /// `Detailed list of all transactions`
  String get detailedListOfAllTransactions {
    return Intl.message(
      'Detailed list of all transactions',
      name: 'detailedListOfAllTransactions',
      desc: 'Description for the transactions report',
      args: [],
    );
  }

  /// `Budget Report`
  String get budgetReport {
    return Intl.message(
      'Budget Report',
      name: 'budgetReport',
      desc: 'Title for the budget report section',
      args: [],
    );
  }

  /// `Budget vs actual spending analysis`
  String get budgetVsActualSpendingAnalysis {
    return Intl.message(
      'Budget vs actual spending analysis',
      name: 'budgetVsActualSpendingAnalysis',
      desc: 'Description for the budget report',
      args: [],
    );
  }

  /// `Assets & Liabilities Report`
  String get assetsLiabilitiesReport {
    return Intl.message(
      'Assets & Liabilities Report',
      name: 'assetsLiabilitiesReport',
      desc: 'Title for the assets and liabilities report section',
      args: [],
    );
  }

  /// `Net worth and financial position`
  String get netWorthAndFinancialPosition {
    return Intl.message(
      'Net worth and financial position',
      name: 'netWorthAndFinancialPosition',
      desc: 'Description for the assets and liabilities report',
      args: [],
    );
  }

  /// `Complete Financial Report`
  String get completeFinancialReport {
    return Intl.message(
      'Complete Financial Report',
      name: 'completeFinancialReport',
      desc: 'Title for the complete financial report section',
      args: [],
    );
  }

  /// `Comprehensive financial summary`
  String get comprehensiveFinancialSummary {
    return Intl.message(
      'Comprehensive financial summary',
      name: 'comprehensiveFinancialSummary',
      desc: 'Description for the complete financial report',
      args: [],
    );
  }

  /// `Generating...`
  String get generating {
    return Intl.message(
      'Generating...',
      name: 'generating',
      desc: 'Message displayed while generating a report',
      args: [],
    );
  }

  /// `Generate Report`
  String get generateReport {
    return Intl.message(
      'Generate Report',
      name: 'generateReport',
      desc: 'Button text for generating a report',
      args: [],
    );
  }

  /// `View All`
  String get viewAll {
    return Intl.message(
      'View All',
      name: 'viewAll',
      desc: 'Button text for viewing all items',
      args: [],
    );
  }

  /// `Repayment`
  String get repayment {
    return Intl.message('Repayment', name: 'repayment', desc: '', args: []);
  }

  /// `Amount to Repay`
  String get amountToRepay {
    return Intl.message(
      'Amount to Repay',
      name: 'amountToRepay',
      desc: '',
      args: [],
    );
  }

  /// `Amount Repaid`
  String get amountRepaid {
    return Intl.message(
      'Amount Repaid',
      name: 'amountRepaid',
      desc: '',
      args: [],
    );
  }

  /// `Repay Credit Card`
  String get repayCreditCard {
    return Intl.message(
      'Repay Credit Card',
      name: 'repayCreditCard',
      desc: '',
      args: [],
    );
  }

  /// `Pay`
  String get pay {
    return Intl.message('Pay', name: 'pay', desc: '', args: []);
  }

  /// `Repayment successful!`
  String get repaymentSuccessful {
    return Intl.message(
      'Repayment successful!',
      name: 'repaymentSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Amount cannot exceed the repayable amount.`
  String get amountExceedsRepay {
    return Intl.message(
      'Amount cannot exceed the repayable amount.',
      name: 'amountExceedsRepay',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'hi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
