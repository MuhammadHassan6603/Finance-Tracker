import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';

class CreditCardStatementModel {
  final String id;
  final String cardId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<TransactionModel> transactions; // All spends
  final List<TransactionModel> repayments;   // All repayments
  final double interestCharged;
  final double openingBalance;
  final double closingBalance;
  final DateTime generatedAt;

  CreditCardStatementModel({
    required this.id,
    required this.cardId,
    required this.periodStart,
    required this.periodEnd,
    required this.transactions,
    required this.repayments,
    required this.interestCharged,
    required this.openingBalance,
    required this.closingBalance,
    required this.generatedAt,
  });

  factory CreditCardStatementModel.fromJson(Map<String, dynamic> json) {
    return CreditCardStatementModel(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      periodStart: (json['periodStart'] as Timestamp).toDate(),
      periodEnd: (json['periodEnd'] as Timestamp).toDate(),
      transactions: (json['transactions'] as List<dynamic>?)?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      repayments: (json['repayments'] as List<dynamic>?)?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      interestCharged: (json['interestCharged'] as num?)?.toDouble() ?? 0.0,
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      closingBalance: (json['closingBalance'] as num?)?.toDouble() ?? 0.0,
      generatedAt: (json['generatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardId': cardId,
      'periodStart': Timestamp.fromDate(periodStart),
      'periodEnd': Timestamp.fromDate(periodEnd),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'repayments': repayments.map((t) => t.toJson()).toList(),
      'interestCharged': interestCharged,
      'openingBalance': openingBalance,
      'closingBalance': closingBalance,
      'generatedAt': Timestamp.fromDate(generatedAt),
    };
  }

  CreditCardStatementModel copyWith({
    String? id,
    String? cardId,
    DateTime? periodStart,
    DateTime? periodEnd,
    List<TransactionModel>? transactions,
    List<TransactionModel>? repayments,
    double? interestCharged,
    double? openingBalance,
    double? closingBalance,
    DateTime? generatedAt,
  }) {
    return CreditCardStatementModel(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      transactions: transactions ?? this.transactions,
      repayments: repayments ?? this.repayments,
      interestCharged: interestCharged ?? this.interestCharged,
      openingBalance: openingBalance ?? this.openingBalance,
      closingBalance: closingBalance ?? this.closingBalance,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
} 