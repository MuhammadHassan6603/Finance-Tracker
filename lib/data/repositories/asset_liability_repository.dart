import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/asset_liability_model.dart';
import '../../core/constants/console.dart';

class AssetLiabilityRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'assets_liabilities';

  AssetLiabilityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<AssetLiabilityModel>> getAssetsLiabilities(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .handleError((error) {
          console('Asset/Liability fetch error: $error', type: DebugType.error);
          throw Exception('Failed to load items. Please try again.');
        })
        .map((snapshot) => snapshot.docs
            .map((doc) => AssetLiabilityModel.fromFirestore(doc))
            .toList());
  }

  Future<void> addAssetLiability(AssetLiabilityModel item) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(item.id)
          .set(item.toFirestore());
      console('Asset/Liability added: ${item.id}', type: DebugType.info);
    } catch (e) {
      console('Error adding asset/liability: $e', type: DebugType.error);
      throw Exception('Failed to create item. Please try again.');
    }
  }

  Future<void> updateAssetLiability(AssetLiabilityModel item) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(item.id)
          .update(item.toFirestore());
      console('Asset/Liability updated: ${item.id}', type: DebugType.info);
    } catch (e) {
      console('Error updating asset/liability: $e', type: DebugType.error);
      throw Exception('Failed to update item. Please try again.');
    }
  }

  Future<void> toggleActiveStatus(String id, bool isActive) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({'isActive': isActive});
    } catch (e) {
      console('Error toggling asset/liability status: $e', type: DebugType.error);
      throw Exception('Failed to update status. Please try again.');
    }
  }

  Future<void> deleteAssetLiability(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      console('Asset/Liability deleted: $id', type: DebugType.info);
    } catch (e) {
      console('Error deleting asset/liability: $e', type: DebugType.error);
      throw Exception('Failed to delete item. Please try again.');
    }
  }
} 