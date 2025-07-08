import 'package:finance_tracker/core/constants/categories_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

enum RecurringPattern {
  daily,
  weekly,
  monthly,
  yearly,
}

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final String category; // Changed from TransactionCategory enum to String
  final String description;
  final DateTime date;
  final String? attachmentUrl; // For receipts or related documents
  final bool isRecurring; // For recurring transactions
  final String? recurringId; // To group recurring transactions
  final DateTime createdAt; // When the transaction was created
  final DateTime updatedAt; // When the transaction was last modified
  final String paymentMethod; // Added
  final String? recurringFrequency; // Added
  final List<Map<String, dynamic>>? splitWith; // Added

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    required this.date,
    required this.paymentMethod, // Added
    this.attachmentUrl,
    this.isRecurring = false,
    this.recurringId,
    this.recurringFrequency, // Added
    this.splitWith, // Added
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  // Validate if the category exists in the CategoryList
  static bool isValidCategory(String category) {
    return CategoryList.categories.any((cat) => cat['title'] == category);
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      if (value is Timestamp) return value.toDate();
      throw Exception('Invalid date format');
    }

    return TransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      category: json['category'] as String,
      description: json['description'] as String,
      date: parseDate(json['date']),
      paymentMethod: json['paymentMethod'] as String,
      attachmentUrl: json['attachmentUrl'] as String?,
      isRecurring: json['isRecurring'] as bool,
      recurringId: json['recurringId'] as String?,
      recurringFrequency: json['recurringFrequency'] as String?,
      splitWith: (json['splitWith'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>(),
      createdAt: json['createdAt'] != null ? parseDate(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.toString(),
      'category': category,
      'description': description,
      'date': date,
      'paymentMethod': paymentMethod, // Added
      'attachmentUrl': attachmentUrl,
      'isRecurring': isRecurring,
      'recurringId': recurringId,
      'recurringFrequency': recurringFrequency, // Added
      'splitWith': splitWith, // Added
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Add copyWith method for easy updates
  TransactionModel copyWith({
    String? id,
    String? userId,
    double? amount,
    TransactionType? type,
    String? category,
    String? description,
    DateTime? date,
    String? paymentMethod, // Added
    String? attachmentUrl,
    bool? isRecurring,
    String? recurringId,
    String? recurringFrequency, // Added
    List<Map<String, dynamic>>? splitWith, // Added
    String? relatedSettlement, // Add this
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod, // Added
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringId: recurringId ?? this.recurringId,
      recurringFrequency:
          recurringFrequency ?? this.recurringFrequency, // Added
      splitWith: splitWith ?? this.splitWith, // Added
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
