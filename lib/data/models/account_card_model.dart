import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AccountCardModel {
  final String id;
  final String userId;
  final String name;
  final String accountName;
  final String number;
  final String type;
  final double balance;
  final Color color;
  final IconData icon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? linkedBankAssetId;
  final DateTime? firstStatementDate;
  final int? statementDayOfMonth;

  AccountCardModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.number,
    required this.type,
    required this.balance,
    required this.color,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
    required this.accountName,
    this.linkedBankAssetId,
    this.firstStatementDate,
    this.statementDayOfMonth,
  });

  // Create a new account card
  factory AccountCardModel.create({
    required String userId,
    required String name,
    required String accountName,
    required String number,
    required String type,
    required double balance,
    required Color color,
    required IconData icon,
    String? linkedBankAssetId,
    DateTime? firstStatementDate,
    int? statementDayOfMonth,
  }) {
    final now = DateTime.now();
    return AccountCardModel(
      id: const Uuid().v4(),
      userId: userId,
      name: name,
      number: number,
      type: type,
      balance: balance,
      color: color,
      icon: icon,
      createdAt: now,
      updatedAt: now,
      accountName: accountName,
      linkedBankAssetId: linkedBankAssetId,
      firstStatementDate: firstStatementDate,
      statementDayOfMonth: statementDayOfMonth,
    );
  }

  // Create from Firestore document
  factory AccountCardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AccountCardModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      number: data['number'] ?? '',
      type: data['type'] ?? '',
      balance: (data['balance'] ?? 0.0).toDouble(),
      color: Color(data['color'] ?? 0xFF000000),
      icon: IconData(data['icon'] ?? 0, fontFamily: 'MaterialIcons'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      accountName: data['accountName'] ?? '',
      linkedBankAssetId: data['linkedBankAssetId'],
      firstStatementDate: data['firstStatementDate'] != null ? (data['firstStatementDate'] as Timestamp).toDate() : null,
      statementDayOfMonth: data['statementDayOfMonth'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'accountName': accountName,
      'number': number,
      'type': type,
      'balance': balance,
      'color': color.value,
      'icon': icon.codePoint,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'linkedBankAssetId': linkedBankAssetId,
      'firstStatementDate': firstStatementDate != null ? Timestamp.fromDate(firstStatementDate!) : null,
      'statementDayOfMonth': statementDayOfMonth,
    };
  }

  // Create a copy with updated fields
  AccountCardModel copyWith({
    String? name,
    String? accountName,
    String? number,
    String? type,
    double? balance,
    Color? color,
    IconData? icon,
    String? linkedBankAssetId,
    DateTime? firstStatementDate,
    int? statementDayOfMonth,
  }) {
    return AccountCardModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      accountName: accountName ?? this.accountName,
      number: number ?? this.number,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      linkedBankAssetId: linkedBankAssetId ?? this.linkedBankAssetId,
      firstStatementDate: firstStatementDate ?? this.firstStatementDate,
      statementDayOfMonth: statementDayOfMonth ?? this.statementDayOfMonth,
    );
  }

  // Convert to Map for UI
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'accountName': accountName,
      'number': number,
      'type': type,
      'balance': balance,
      'color': color,
      'icon': icon,
      'linkedBankAssetId': linkedBankAssetId,
      'firstStatementDate': firstStatementDate,
      'statementDayOfMonth': statementDayOfMonth,
    };
  }
}
