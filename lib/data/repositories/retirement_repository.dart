import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/retirement_model.dart';

class RetirementRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'retirement_plans';

  RetirementRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<RetirementModel?> getRetirementPlan(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty
            ? null
            : RetirementModel.fromFirestore(snapshot.docs.first));
  }

  Future<void> saveRetirementPlan(RetirementModel plan) async {
    if (plan.id.isEmpty) {
      await _firestore.collection(_collection).add(plan.toFirestore());
    } else {
      await _firestore
          .collection(_collection)
          .doc(plan.id)
          .update(plan.toFirestore());
    }
  }

  Future<void> deleteRetirementPlan(String planId) async {
    await _firestore.collection(_collection).doc(planId).delete();
  }
} 