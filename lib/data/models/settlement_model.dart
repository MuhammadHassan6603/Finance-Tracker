import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class SettlementModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final bool isOwed; // True if user owes someone, false if someone owes user
  final List<String> relatedTransactions;
  final List<String> participants;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SettlementModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.isOwed,
    required this.relatedTransactions,
    required this.participants,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SettlementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SettlementModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      isOwed: data['isOwed'] ?? false,
      relatedTransactions: List<String>.from(data['relatedTransactions'] ?? []),
      participants: List<String>.from(data['participants'] ?? []),
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'isOwed': isOwed,
      'relatedTransactions': relatedTransactions,
      'participants': participants,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  SettlementModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    bool? isOwed,
    List<String>? relatedTransactions,
    List<String>? participants,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SettlementModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isOwed: isOwed ?? this.isOwed,
      relatedTransactions: relatedTransactions ?? this.relatedTransactions,
      participants: participants ?? this.participants,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 