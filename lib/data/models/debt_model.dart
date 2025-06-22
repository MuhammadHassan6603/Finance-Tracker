import 'package:cloud_firestore/cloud_firestore.dart';

enum DebtType {
  creditCard,
  personalLoan,
  studentLoan,
  mortgage,
  carLoan,
  other
}

class DebtModel {
  final String id;
  final String userId;
  final String name;
  final DebtType type;
  final double totalAmount;
  final double remainingAmount;
  final double interestRate;
  final DateTime startDate;
  final DateTime? dueDate;
  final String paymentFrequency; // monthly, weekly, etc.
  final double minimumPayment;
  final List<Map<String, dynamic>> paymentHistory;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DebtModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.totalAmount,
    required this.remainingAmount,
    required this.interestRate,
    required this.startDate,
    this.dueDate,
    required this.paymentFrequency,
    required this.minimumPayment,
    this.paymentHistory = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DebtModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DebtModel(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      type: DebtType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => DebtType.other,
      ),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      remainingAmount: (data['remainingAmount'] as num).toDouble(),
      interestRate: (data['interestRate'] as num).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null 
          ? (data['dueDate'] as Timestamp).toDate() 
          : null,
      paymentFrequency: data['paymentFrequency'] as String,
      minimumPayment: (data['minimumPayment'] as num).toDouble(),
      paymentHistory: List<Map<String, dynamic>>.from(data['paymentHistory'] ?? []),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type.toString(),
      'totalAmount': totalAmount,
      'remainingAmount': remainingAmount,
      'interestRate': interestRate,
      'startDate': Timestamp.fromDate(startDate),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'paymentFrequency': paymentFrequency,
      'minimumPayment': minimumPayment,
      'paymentHistory': paymentHistory,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  double get paidAmount => totalAmount - remainingAmount;
  double get progressPercentage => (paidAmount / totalAmount) * 100;
  
  double get monthlyInterest => (remainingAmount * interestRate) / 1200;
  
  int get remainingMonths {
    if (minimumPayment <= monthlyInterest) return -1; // Will never be paid off
    final effectivePayment = minimumPayment - monthlyInterest;
    return (remainingAmount / effectivePayment).ceil();
  }

  DateTime get projectedPayoffDate {
    if (remainingMonths < 0) return DateTime(9999); // Far future date for never
    return DateTime.now().add(Duration(days: remainingMonths * 30));
  }

  DebtModel copyWith({
    String? name,
    DebtType? type,
    double? totalAmount,
    double? remainingAmount,
    double? interestRate,
    DateTime? startDate,
    DateTime? dueDate,
    String? paymentFrequency,
    double? minimumPayment,
    List<Map<String, dynamic>>? paymentHistory,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return DebtModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      type: type ?? this.type,
      totalAmount: totalAmount ?? this.totalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      interestRate: interestRate ?? this.interestRate,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}