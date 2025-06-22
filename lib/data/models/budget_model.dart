import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_tracker/core/constants/categories_list.dart';
import 'package:flutter/material.dart';

class BudgetModel {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final double spent;
  final String icon;
  final String iconFontFamily;
  final DateTime startDate;
  final DateTime endDate;
  final String periodType; // 'monthly', 'yearly', 'custom'
  final String? customPeriod;
  final bool isRecurring;
  final List<String> collaborators;
  final List<String> alerts;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    this.spent = 0.0,
    required this.icon,
    required this.iconFontFamily,
    required this.startDate,
    required this.endDate,
    required this.periodType,
    this.customPeriod,
    this.isRecurring = false,
    this.collaborators = const [],
    this.alerts = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      userId: data['userId'] as String,
      category: data['category'] as String,
      amount: (data['amount'] as num).toDouble(),
      spent: (data['spent'] as num).toDouble(),
      icon: data['icon'] as String? ?? '',
      iconFontFamily: data['iconFontFamily'] as String? ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      periodType: data['periodType'] as String,
      customPeriod: data['customPeriod'] as String?,
      isRecurring: data['isRecurring'] as bool? ?? false,
      collaborators: List<String>.from(data['collaborators'] ?? []),
      alerts: List<String>.from(data['alerts'] ?? []),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
      'amount': amount,
      'spent': spent,
      'icon': icon,
      'iconFontFamily': iconFontFamily,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'periodType': periodType,
      'customPeriod': customPeriod,
      'isRecurring': isRecurring,
      'collaborators': collaborators,
      'alerts': alerts,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper methods
  double get remaining => amount - spent;
  double get progress => spent / amount;
  bool get isOverBudget => spent > amount;

  Map<String, dynamic> getCategoryIcon() {
    final categoryData = CategoryList.categories.firstWhere(
      (cat) => cat['title'] == category,
      orElse: () => {'icon': Icons.category, 'title': category},
    );
    return {
      'icon': categoryData['icon'],
      'title': categoryData['title'],
    };
  }

  BudgetModel copyWith({
    String? category,
    double? amount,
    double? spent,
    String? icon,
    String? iconFontFamily,
    DateTime? startDate,
    DateTime? endDate,
    String? periodType,
    String? customPeriod,
    bool? isRecurring,
    List<String>? collaborators,
    List<String>? alerts,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    final categoryData = category != null ? CategoryList.categories.firstWhere(
      (cat) => cat['title'] == category,
      orElse: () => {'icon': Icons.category, 'title': category},
    ) : null;

    return BudgetModel(
      id: id,
      userId: userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      icon: icon ?? this.icon,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      periodType: periodType ?? this.periodType,
      customPeriod: customPeriod ?? this.customPeriod,
      isRecurring: isRecurring ?? this.isRecurring,
      collaborators: collaborators ?? this.collaborators,
      alerts: alerts ?? this.alerts,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
} 