import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String _collection = 'transactions';
  final _uuid = const Uuid();

  TransactionRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // Get all transactions for a user with optional filters
  Future<List<TransactionModel>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? paymentMethod,
  }) async {
    try {
      var query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate);
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type.toString());
      }
      if (paymentMethod != null) {
        query = query.where('paymentMethod', isEqualTo: paymentMethod);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Add a new transaction
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(transaction.toJson());

      return transaction.copyWith(id: docRef.id);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Update an existing transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(transaction.id)
          .update(transaction.toJson());
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Upload attachment for a transaction
  Future<String> uploadAttachment(String userId, File file) async {
    try {
      final fileName = '${_uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}';
      final ref = _storage.ref().child('attachments/$userId/$fileName');
      
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Delete attachment
  Future<void> deleteAttachment(String attachmentUrl) async {
    try {
      final ref = _storage.refFromURL(attachmentUrl);
      await ref.delete();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get transaction statistics
  Future<Map<String, double>> getCategoryTotals({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required TransactionType type,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type.toString())
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .get();

      final Map<String, double> totals = {};
      for (var doc in snapshot.docs) {
        final transaction = TransactionModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
        totals[transaction.category] =
            (totals[transaction.category] ?? 0) + transaction.amount;
      }
      return totals;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is FirebaseException) {
      return Exception(error.message ?? 'Firebase error occurred');
    }
    return Exception('An unexpected error occurred');
  }
} 