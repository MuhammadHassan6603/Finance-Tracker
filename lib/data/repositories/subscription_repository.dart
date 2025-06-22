import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription_model.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'subscriptions';

  SubscriptionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<SubscriptionModel?> getCurrentSubscription(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.isEmpty
            ? null
            : SubscriptionModel.fromFirestore(snapshot.docs.first));
  }

  Future<void> saveSubscription(SubscriptionModel subscription) async {
    if (subscription.id.isEmpty) {
      await _firestore.collection(_collection).add(subscription.toFirestore());
    } else {
      await _firestore
          .collection(_collection)
          .doc(subscription.id)
          .update(subscription.toFirestore());
    }
  }
} 