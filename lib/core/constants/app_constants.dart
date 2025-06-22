class AppConstants {
  static const String appName = 'Finance Tracker';
  static const String appVersion = '1.0.0';

  // API URLs
  static const String baseUrl = 'https://api.example.com';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static final List<String> assetsList = [
    'Cash',
    'Bank',
    'Real Estate',
    'Trading Balance',
    'Stocks',
    'Mutual Funds',
    'Bonds',
    'ETFs',
    'CryptoCurrencies',
    'Retirement Accounts',
    'Business',
    'Intellectual Properties',
    'Receivables',
    'Others'
  ];
  static final List<String> liabilityList = [
    'Credit Card',
    'Personal Loan',
    'Home Loan',
    'Car Loan',
    'Student Loan',
    'Business Loan',
    'Bank Overdraft',
    'Unpaid Taxes',
    'Payable',
    'Others'
  ];
}
