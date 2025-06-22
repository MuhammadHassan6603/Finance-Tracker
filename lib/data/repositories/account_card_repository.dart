import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account_card_model.dart';

class AccountCardRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'account_cards';

  AccountCardRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Create a new account card
  Future<AccountCardModel> createAccountCard(AccountCardModel accountCard) async {
    final docRef = _firestore.collection(_collection).doc(accountCard.id);
    await docRef.set(accountCard.toFirestore());
    return accountCard;
  }

  // Get all account cards for a user
  Stream<List<AccountCardModel>> getAccountCards(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AccountCardModel.fromFirestore(doc))
            .toList());
  }

  // Get a single account card by ID
  Future<AccountCardModel?> getAccountCard(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return AccountCardModel.fromFirestore(doc);
  }

  // Update an account card
  Future<void> updateAccountCard(AccountCardModel accountCard) async {
    await _firestore
        .collection(_collection)
        .doc(accountCard.id)
        .update(accountCard.toFirestore());
  }

  // Delete an account card
  Future<void> deleteAccountCard(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
