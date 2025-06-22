import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication Methods
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<String?> getCurrentUserId() async {
    return _auth.currentUser?.uid;
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Firestore Transaction Methods
  Future<List<TransactionModel>> getTransactions({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    try {
      final currentUserId = userId ?? await getCurrentUserId();
      if (currentUserId == null) throw Exception('User not authenticated');

      var query = _firestore
          .collection('transactions')
          .where('userId', isEqualTo: currentUserId);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate);
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type.toString());
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => TransactionModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  Future<TransactionModel> createTransaction(
      TransactionModel transaction) async {
    try {
      final docRef =
          await _firestore.collection('transactions').add(transaction.toJson());

      return transaction.copyWith(id: docRef.id);
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toJson());
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).delete();
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  // Storage Methods for Attachments
  Future<String> uploadAttachment(String filePath, String fileName) async {
    try {
      final currentUserId = await getCurrentUserId();
      if (currentUserId == null) throw Exception('User not authenticated');

      final storageRef =
          _storage.ref().child('attachments/$currentUserId/$fileName');

      final uploadTask = await storageRef.putFile(File(filePath));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  Future<void> deleteAttachment(String attachmentUrl) async {
    try {
      final ref = _storage.refFromURL(attachmentUrl);
      await ref.delete();
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  // Analytics Methods
  Future<Map<String, double>> getCategoryTotals({
    required DateTime startDate,
    required DateTime endDate,
    required TransactionType type,
  }) async {
    try {
      final currentUserId = await getCurrentUserId();
      if (currentUserId == null) throw Exception('User not authenticated');

      final querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: currentUserId)
          .where('type', isEqualTo: type.toString())
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .get();

      final Map<String, double> categoryTotals = {};

      for (var doc in querySnapshot.docs) {
        final transaction = TransactionModel.fromJson({
          ...doc.data(),
          'id': doc.id,
        });

        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }

      return categoryTotals;
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  // Error Handling
  Exception _handleFirebaseError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return Exception('No user found with this email');
        case 'wrong-password':
          return Exception('Wrong password provided');
        case 'email-already-in-use':
          return Exception('Email is already registered');
        default:
          return Exception(error.message ?? 'Authentication error occurred');
      }
    } else if (error is FirebaseException) {
      return Exception(error.message ?? 'Firebase error occurred');
    }
    return Exception('An unexpected error occurred');
  }
}
