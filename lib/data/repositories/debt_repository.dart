import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/debt_model.dart';

class DebtRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'debts';

  DebtRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<DebtModel>> getDebts(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DebtModel.fromFirestore(doc))
            .toList());
  }

  Future<void> addDebt(DebtModel debt) async {
    await _firestore.collection(_collection).add(debt.toFirestore());
  }

  Future<void> updateDebt(DebtModel debt) async {
    await _firestore
        .collection(_collection)
        .doc(debt.id)
        .update(debt.toFirestore());
  }

  Future<void> deleteDebt(String debtId) async {
    await _firestore.collection(_collection).doc(debtId).delete();
  }

  Future<void> addPayment(String debtId, double amount) async {
    final payment = {
      'amount': amount,
      'date': Timestamp.now(),
    };

    await _firestore.collection(_collection).doc(debtId).update({
      'remainingAmount': FieldValue.increment(-amount),
      'paymentHistory': FieldValue.arrayUnion([payment]),
      'updatedAt': Timestamp.now(),
    });
  }
} 