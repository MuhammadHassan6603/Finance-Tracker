import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/credit_card_statement_model.dart';

class CreditCardStatementRepository {
  final CollectionReference statementsCollection =
      FirebaseFirestore.instance.collection('credit_card_statements');

  Future<void> createStatement(CreditCardStatementModel statement) async {
    await statementsCollection.doc(statement.id).set(statement.toJson());
  }

  Future<void> updateStatement(CreditCardStatementModel statement) async {
    await statementsCollection.doc(statement.id).update(statement.toJson());
  }

  Future<void> deleteStatement(String id) async {
    await statementsCollection.doc(id).delete();
  }

  Future<List<CreditCardStatementModel>> getStatementsForCard(String cardId) async {
    final query = await statementsCollection
        .where('cardId', isEqualTo: cardId)
        .orderBy('periodStart', descending: true)
        .get();
    return query.docs
        .map((doc) => CreditCardStatementModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<CreditCardStatementModel?> getCurrentStatementForCard(String cardId) async {
    final now = DateTime.now();
    final query = await statementsCollection
        .where('cardId', isEqualTo: cardId)
        .where('periodStart', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .where('periodEnd', isGreaterThan: Timestamp.fromDate(now))
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return CreditCardStatementModel.fromJson(query.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }
} 