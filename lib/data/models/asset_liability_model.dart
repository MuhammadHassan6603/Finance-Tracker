import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AssetLiabilityModel {
  final String id;
  final String userId;
  final bool isAsset;
  final String type;
  final double amount;
  final String name;
  final DateTime startDate;
  final double? interestRate;
  final String? paymentSchedule;
  final List<String> attachments;
  final List<String> trackingPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<Map<String, dynamic>> history;
  final String? description;
  final String? cardId;

  AssetLiabilityModel({
    required this.id,
    required this.userId,
    required this.isAsset,
    required this.type,
    required this.amount,
    required this.name,
    required this.startDate,
    this.interestRate,
    this.paymentSchedule,
    this.attachments = const [],
    this.trackingPreferences = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.history = const [],
    this.description,
    this.cardId,
  });

  factory AssetLiabilityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssetLiabilityModel(
      id: doc.id,
      userId: data['userId'] as String,
      isAsset: data['isAsset'] as bool,
      type: data['type'] as String,
      amount: (data['amount'] as num).toDouble(),
      name: data['name'] as String,
      startDate: (data['startDate'] as Timestamp).toDate(),
      interestRate: data['interestRate'] != null
          ? (data['interestRate'] as num).toDouble()
          : null,
      paymentSchedule: data['paymentSchedule'] as String?,
      attachments: List<String>.from(data['attachments'] ?? []),
      trackingPreferences: List<String>.from(data['trackingPreferences'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
      history: List<Map<String, dynamic>>.from(data['history'] ?? []),
      description: data['description'] as String?,
      cardId: data['cardId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'isAsset': isAsset,
      'type': type,
      'amount': amount,
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'interestRate': interestRate,
      'paymentSchedule': paymentSchedule,
      'attachments': attachments,
      'trackingPreferences': trackingPreferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'history': history,
      'description': description,
      'cardId': cardId,
    };
  }

  // Helper methods for assets
  double get appreciationRate =>
      isAsset ? 0.0 : 0.0; // Can be calculated based on historical data

  // Helper methods for liabilities
  double get monthlyPayment {
    if (!isAsset && interestRate != null && paymentSchedule == 'Monthly') {
      // Basic monthly payment calculation (P * r * (1+r)^n) / ((1+r)^n - 1)
      // This is a simplified calculation; you may want to use a more precise formula
      double monthlyRate = (interestRate! / 100) / 12;
      return amount * monthlyRate; // Simplified version
    }
    return 0.0;
  }

  // Helper method to determine overall financial health
  bool get isGoodFinancialIndicator => isAsset || (isActive == false);

  // Add a getter for EMI
  double get emi {
    if (!isAsset && interestRate != null && paymentSchedule == 'Monthly') {
      // Calculate EMI using the formula: [P * r * (1 + r)^n] / [(1 + r)^n - 1]
      // Where:
      // P = Principal amount (loan amount)
      // r = monthly interest rate (annual rate / 12 / 100)
      // n = loan term in months
      final double principal = amount;
      final double monthlyRate = (interestRate! / 12) / 100;
      final int loanTermInMonths = calculateLoanTermInMonths();

      if (monthlyRate == 0) {
        return principal / loanTermInMonths;
      }

      final double numerator = principal * monthlyRate * _pow(1 + monthlyRate, loanTermInMonths);
      final double denominator = _pow(1 + monthlyRate, loanTermInMonths) - 1;
      return numerator / denominator;
    }
    return 0.0;
  }

  // Helper method to calculate loan term in months
  int calculateLoanTermInMonths() {
    final DateTime now = DateTime.now();
    final Duration remainingTerm = startDate.difference(now);
    return (remainingTerm.inDays / 30).ceil();
  }

  // Helper method to calculate power
  double _pow(double base, int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  AssetLiabilityModel copyWith({
    String? type,
    double? amount,
    String? name,
    DateTime? startDate,
    double? interestRate,
    String? paymentSchedule,
    List<String>? attachments,
    List<String>? trackingPreferences,
    bool? isActive,
    DateTime? updatedAt,
    String? userId,
    List<Map<String, dynamic>>? history,
    String? description,
    String? cardId,
  }) {
    return AssetLiabilityModel(
      id: id,
      userId: userId ?? this.userId,
      isAsset: isAsset,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      interestRate: interestRate ?? this.interestRate,
      paymentSchedule: paymentSchedule ?? this.paymentSchedule,
      attachments: attachments ?? this.attachments,
      trackingPreferences: trackingPreferences ?? this.trackingPreferences,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      history: history ?? this.history,
      description: description ?? this.description,
      cardId: cardId ?? this.cardId,
    );
  }

  // Add method to record historical values
  AssetLiabilityModel recordHistory(double newAmount) {
    final newHistory = List<Map<String, dynamic>>.from(history)
      ..add({
        'amount': newAmount,
        'timestamp': DateTime.now(),
      });

    return copyWith(
      amount: newAmount,
      history: newHistory,
      updatedAt: DateTime.now(),
    );
  }

  // Add method to get percentage change
  double getPercentageChange(Duration period) {
    if (history.isEmpty) return 0.0;

    final now = DateTime.now();
    final cutoff = now.subtract(period);
    final previous = history.lastWhere(
      (entry) => entry['timestamp'].toDate().isAfter(cutoff),
      orElse: () => history.first,
    );

    final previousAmount = previous['amount'] as double;
    return ((amount - previousAmount) / previousAmount) * 100;
  }

  // Add new properties for performance tracking
  double get currentValue {
    if (history.isEmpty) return amount;
    return (history.last['amount'] as num).toDouble();
  }

  double get performancePercentage {
    if (amount == 0) return 0;
    return ((currentValue - amount) / amount) * 100;
  }

  double getValueAtDate(DateTime date) {
    final historicalEntry = history
        .where((entry) => (entry['date'] as Timestamp).toDate().isBefore(date))
        .lastOrNull;
    return historicalEntry != null
        ? (historicalEntry['amount'] as num).toDouble()
        : amount;
  }

  Map<String, double> getPerformanceHistory(int months) {
    final Map<String, double> performanceData = {};
    final now = DateTime.now();

    for (int i = 0; i < months; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final value = getValueAtDate(date);
      performanceData[DateFormat('MMM yyyy').format(date)] = value;
    }

    return performanceData;
  }

  DateTime get nextPaymentDate => startDate.add(const Duration(days: 30)); // Example
 
}
