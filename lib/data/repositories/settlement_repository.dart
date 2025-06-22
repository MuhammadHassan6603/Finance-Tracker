import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/settlement_model.dart';
import '../../core/constants/console.dart';

class SettlementRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'settlements';

  SettlementRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<SettlementModel>> getSettlements(String userId) {
    try {
      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .snapshots()
          .handleError((error) {
            console('Failed to load settlements: $error', 
                    type: DebugType.error);
            throw Exception('Failed to load settlements. Please try again.');
          })
          .map((snapshot) => snapshot.docs
              .map((doc) => SettlementModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      console('Error in getSettlements: $e', type: DebugType.error);
      rethrow;
    }
  }

  Future<void> addSettlement(SettlementModel settlement) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(settlement.id)
          .set(settlement.toFirestore());
      console('Settlement added: ${settlement.id}', 
             type: DebugType.info, name: 'SETTLEMENT');
    } catch (e) {
      console('Error adding settlement: $e', 
             type: DebugType.error, name: 'SETTLEMENT');
      throw Exception('Failed to add settlement. Please try again.');
    }
  }

  Future<void> updateSettlement(SettlementModel settlement) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(settlement.id)
          .update(settlement.toFirestore());
      console('Settlement updated: ${settlement.id}', 
             type: DebugType.info, name: 'SETTLEMENT');
    } catch (e) {
      console('Error updating settlement: $e', 
             type: DebugType.error, name: 'SETTLEMENT');
      throw Exception('Failed to update settlement. Please try again.');
    }
  }

  Future<void> deleteSettlement(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      console('Settlement deleted: $id', 
             type: DebugType.info, name: 'SETTLEMENT');
    } catch (e) {
      console('Error deleting settlement: $e', 
             type: DebugType.error, name: 'SETTLEMENT');
      throw Exception('Failed to delete settlement. Please try again.');
    }
  }

  Future<void> markAsPaid(String id) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({'isOwed': false});
      console('Settlement marked as paid: $id', 
             type: DebugType.info, name: 'SETTLEMENT');
    } catch (e) {
      console('Error marking settlement as paid: $e', 
             type: DebugType.error, name: 'SETTLEMENT');
      throw Exception('Failed to update settlement status. Please try again.');
    }
  }
} 