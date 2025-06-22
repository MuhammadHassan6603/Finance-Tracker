import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';
import '../../core/constants/console.dart';

class BudgetRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'budgets';

  BudgetRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<BudgetModel>> getBudgetsByUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .handleError((error) {
          console('Budget fetch error: $error', type: DebugType.error);
          throw Exception('Failed to load budgets. Please try again.');
        })
        .map((snapshot) => snapshot.docs
            .map((doc) => BudgetModel.fromFirestore(doc))
            .toList());
  }

  Future<bool> isBudgetExistsForCategory(String userId, String category, DateTime date) async {
    try {
      final startOfMonth = DateTime(date.year, date.month, 1);
      final endOfMonth = DateTime(date.year, date.month + 1, 0);

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      console('Error checking budget existence: $e', type: DebugType.error);
      throw Exception('Failed to check budget existence. Please try again.');
    }
  }

  Future<void> addBudget(BudgetModel budget) async {
    try {
      // Check if budget already exists for this category in the same month
      final exists = await isBudgetExistsForCategory(
        budget.userId,
        budget.category,
        budget.startDate,
      );

      if (exists) {
        throw Exception('A budget for this category already exists in the selected month.');
      }

      await _firestore
          .collection(_collection)
          .doc(budget.id)
          .set(budget.toFirestore());
      console('Budget added: ${budget.id}', type: DebugType.info);
    } catch (e) {
      console('Error adding budget: $e', type: DebugType.error);
      throw Exception(e.toString());
    }
  }

  Future<void> updateBudget(BudgetModel budget) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(budget.id)
          .update(budget.toFirestore());
      console('Budget updated: ${budget.id}', type: DebugType.info);
    } catch (e) {
      console('Error updating budget: $e', type: DebugType.error);
      throw Exception('Failed to update budget. Please try again.');
    }
  }

  Future<void> toggleBudgetStatus(String id, bool isActive) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({'isActive': isActive});
    } catch (e) {
      console('Error toggling budget status: $e', type: DebugType.error);
      throw Exception('Failed to update budget status. Please try again.');
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      console('Budget deleted: $id', type: DebugType.info);
    } catch (e) {
      console('Error deleting budget: $e', type: DebugType.error);
      throw Exception('Failed to delete budget. Please try again.');
    }
  }

  Future<void> addSpending(String budgetId, double amount) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(budgetId)
          .update({
            'spent': FieldValue.increment(amount),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      console('Error updating budget spending: $e', type: DebugType.error);
      throw Exception('Failed to update budget spending. Please try again.');
    }
  }
} 