import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart'; // Assuming you have this model
import '../../core/constants/console.dart';

class SplitTransactionRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'transactions';

  SplitTransactionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get transactions where splitWith is not null
  Stream<List<TransactionModel>> getSplitTransactions(String userId) {
    try {
      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('splitWith', isNotEqualTo: null)
          .orderBy('splitWith')
          .orderBy('date', descending: true)
          .snapshots()
          .handleError((error) {
        console('Failed to load split transactions: $error',
            type: DebugType.error);
        throw Exception('Failed to load split transactions. Please try again.');
      }).map((snapshot) => snapshot.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return TransactionModel.fromJson(data);
              })
              .where((transaction) =>
                  transaction.splitWith != null &&
                  transaction.splitWith!.isNotEmpty)
              .toList());
    } catch (e) {
      console('Error in getSplitTransactions: $e', type: DebugType.error);
      rethrow;
    }
  }

  // Get split data grouped by person from a list of TransactionModel
  static Map<String, List<SplitData>> groupSplitDataByPerson(
      List<TransactionModel> transactions) {
    Map<String, List<SplitData>> groupedData = {};

    for (var transaction in transactions) {
      if (transaction.id != null &&
          transaction.splitWith != null &&
          transaction.splitWith!.isNotEmpty) {
        for (var split in transaction.splitWith!) {
          final personName = split['name'] as String? ?? 'Unknown';
          final amount = (split['amount'] as num?)?.toDouble() ?? 0.0;
          final percentage = (split['percentage'] as num?)?.toDouble() ?? 0.0;

          if (!groupedData.containsKey(personName)) {
            groupedData[personName] = [];
          }

          groupedData[personName]!.add(SplitData(
            transactionId: transaction.id,
            transactionTitle: transaction.description,
            personName: personName,
            amount: amount,
            percentage: percentage,
            date: transaction.date,
            category: transaction.category,
            originalAmount: transaction.amount,
          ));
        }
      }
    }

    groupedData.forEach((person, splits) {
      splits.sort((a, b) => b.date.compareTo(a.date));
    });

    return groupedData;
  }

  // Update splitWith data for a specific transaction
  Future<void> updateSplitData(
      String transactionId, List<Map<String, dynamic>>? splitWith) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(transactionId)
          .update({'splitWith': splitWith});
      console('Split data updated for transaction: $transactionId',
          type: DebugType.info, name: 'SPLIT');
    } catch (e) {
      console('Error updating split data: $e',
          type: DebugType.error, name: 'SPLIT');
      throw Exception('Failed to update split data. Please try again.');
    }
  }

  // Remove split data from a transaction (can use updateSplitData with null)
  Future<void> removeSplitData(String transactionId) async {
    await updateSplitData(transactionId, null);
  }
}

// Model class for representing a single split entry from a transaction
// This model is typically used internally by the repository or viewmodel
// to structure the split data before presenting it.
class SplitData {
  final String transactionId;
  final String transactionTitle;
  final String personName;
  final double amount;
  final double percentage;
  final DateTime date;
  final String category;
  final double originalAmount;

  SplitData({
    required this.transactionId,
    required this.transactionTitle,
    required this.personName,
    required this.amount,
    required this.percentage,
    required this.date,
    required this.category,
    required this.originalAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'transactionTitle': transactionTitle,
      'personName': personName,
      'amount': amount,
      'percentage': percentage,
      'date': date.toIso8601String(),
      'category': category,
      'originalAmount': originalAmount,
    };
  }

  factory SplitData.fromMap(Map<String, dynamic> map) {
    return SplitData(
      transactionId: map['transactionId'] ?? '',
      transactionTitle: map['transactionTitle'] ?? '',
      personName: map['personName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      percentage: (map['percentage'] ?? 0).toDouble(),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      category: map['category'] ?? '',
      originalAmount: (map['originalAmount'] ?? 0).toDouble(),
    );
  }
}
