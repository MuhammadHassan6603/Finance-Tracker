import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/savings_goal_model.dart';

class SavingsGoalRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'savings_goals';

  SavingsGoalRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<SavingsGoalModel>> getSavingsGoals(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavingsGoalModel.fromFirestore(doc))
            .toList());
  }

  Future<void> addSavingsGoal(SavingsGoalModel goal) async {
    await _firestore.collection(_collection).add(goal.toFirestore());
  }

  Future<void> updateSavingsGoal(SavingsGoalModel goal) async {
    await _firestore
        .collection(_collection)
        .doc(goal.id)
        .update(goal.toFirestore());
  }

  Future<void> deleteSavingsGoal(String goalId) async {
    try {
      // First check if the document exists
      final docSnapshot = await _firestore.collection(_collection).doc(goalId).get();
      
      if (!docSnapshot.exists) {
        throw Exception('Savings goal not found');
      }

      // Delete the document
      await _firestore.collection(_collection).doc(goalId).delete();
      
      // Delete any related data (like contributions) if needed
      // You might want to store contributions in a subcollection
      final contributionsCollection = _firestore
          .collection(_collection)
          .doc(goalId)
          .collection('contributions');
      
      final contributionsSnapshot = await contributionsCollection.get();
      
      // Delete all contributions in a batch
      final batch = _firestore.batch();
      for (var doc in contributionsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete savings goal: ${e.toString()}');
    }
  }

  Future<void> addContribution(String goalId, double amount) async {
    final contribution = {
      'amount': amount,
      'date': Timestamp.now(),
    };

    await _firestore.collection(_collection).doc(goalId).update({
      'currentAmount': FieldValue.increment(amount),
      'contributions': FieldValue.arrayUnion([contribution]),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<bool> goalExists(String goalId) async {
    final docSnapshot = await _firestore.collection(_collection).doc(goalId).get();
    return docSnapshot.exists;
  }
} 