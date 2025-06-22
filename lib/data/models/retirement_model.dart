import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class RetirementModel {
  final String id;
  final String userId;
  final int currentAge;
  final int retirementAge;
  final double currentSavings;
  final double monthlyContribution;
  final double expectedAnnualReturn;
  final double inflationRate;
  final double desiredRetirementIncome;
  final DateTime createdAt;
  final DateTime updatedAt;

  RetirementModel({
    required this.id,
    required this.userId,
    required this.currentAge,
    required this.retirementAge,
    required this.currentSavings,
    required this.monthlyContribution,
    required this.expectedAnnualReturn,
    required this.inflationRate,
    required this.desiredRetirementIncome,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RetirementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RetirementModel(
      id: doc.id,
      userId: data['userId'] as String,
      currentAge: data['currentAge'] as int,
      retirementAge: data['retirementAge'] as int,
      currentSavings: (data['currentSavings'] as num).toDouble(),
      monthlyContribution: (data['monthlyContribution'] as num).toDouble(),
      expectedAnnualReturn: (data['expectedAnnualReturn'] as num).toDouble(),
      inflationRate: (data['inflationRate'] as num).toDouble(),
      desiredRetirementIncome: (data['desiredRetirementIncome'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'currentAge': currentAge,
      'retirementAge': retirementAge,
      'currentSavings': currentSavings,
      'monthlyContribution': monthlyContribution,
      'expectedAnnualReturn': expectedAnnualReturn,
      'inflationRate': inflationRate,
      'desiredRetirementIncome': desiredRetirementIncome,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  RetirementModel copyWith({
    int? currentAge,
    int? retirementAge,
    double? currentSavings,
    double? monthlyContribution,
    double? expectedAnnualReturn,
    double? inflationRate,
    double? desiredRetirementIncome,
  }) {
    return RetirementModel(
      id: id,
      userId: userId,
      currentAge: currentAge ?? this.currentAge,
      retirementAge: retirementAge ?? this.retirementAge,
      currentSavings: currentSavings ?? this.currentSavings,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      expectedAnnualReturn: expectedAnnualReturn ?? this.expectedAnnualReturn,
      inflationRate: inflationRate ?? this.inflationRate,
      desiredRetirementIncome: desiredRetirementIncome ?? this.desiredRetirementIncome,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  double get yearsUntilRetirement => (retirementAge - currentAge).toDouble();
  
  double get projectedRetirementSavings {
    final r = expectedAnnualReturn / 100 / 12; // Monthly return rate
    final n = yearsUntilRetirement * 12; // Total months
    
    // Future value of current savings
    final futureValueSavings = currentSavings * pow((1 + r), n);
    
    // Future value of monthly contributions
    final futureValueContributions = monthlyContribution * 
        ((pow((1 + r), n) - 1) / r);
    
    return futureValueSavings + futureValueContributions;
  }

  double get monthlyRetirementIncome {
    final r = (expectedAnnualReturn - inflationRate) / 100 / 12;
    final years = 30; // Assuming 30 years in retirement
    final n = years * 12;
    
    return projectedRetirementSavings * 
        (r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
  }

  bool get isOnTrack {
    return monthlyRetirementIncome >= desiredRetirementIncome;
  }

  double get fundingRatio {
    return (monthlyRetirementIncome / desiredRetirementIncome) * 100;
  }
} 