import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsGoalModel {
  final String id;
  final String userId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime targetDate;
  final String category;
  final bool isCompleted;
  final List<Map<String, dynamic>> contributions;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavingsGoalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.startDate,
    required this.targetDate,
    required this.category,
    this.isCompleted = false,
    this.contributions = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavingsGoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavingsGoalModel(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      targetAmount: (data['targetAmount'] as num).toDouble(),
      currentAmount: (data['currentAmount'] as num).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      targetDate: (data['targetDate'] as Timestamp).toDate(),
      category: data['category'] as String,
      isCompleted: data['isCompleted'] as bool? ?? false,
      contributions: List<Map<String, dynamic>>.from(data['contributions'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'startDate': Timestamp.fromDate(startDate),
      'targetDate': Timestamp.fromDate(targetDate),
      'category': category,
      'isCompleted': isCompleted,
      'contributions': contributions,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  double get progressPercentage => (currentAmount / targetAmount) * 100;
  
  bool get isOnTrack {
    final totalDays = targetDate.difference(startDate).inDays;
    final daysElapsed = DateTime.now().difference(startDate).inDays;
    final expectedAmount = (targetAmount / totalDays) * daysElapsed;
    return currentAmount >= expectedAmount;
  }

  double get monthlyTargetAmount {
    final months = targetDate.difference(startDate).inDays / 30;
    return targetAmount / months;
  }

  SavingsGoalModel copyWith({
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? category,
    bool? isCompleted,
    List<Map<String, dynamic>>? contributions,
    DateTime? updatedAt,
  }) {
    return SavingsGoalModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      startDate: startDate,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      contributions: contributions ?? this.contributions,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
