// lib/services/bill_reminder_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class BillReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Set up scheduled bill checking
  // This would typically be done on the server-side with a cron job
  // Here we'll show how to manually check for upcoming bills
  Future<void> checkUpcomingBills() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final now = DateTime.now();
    final threeDaysLater = now.add(Duration(days: 3));

    // Get bills due in the next 3 days
    final billsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('bills')
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where('dueDate',
            isLessThanOrEqualTo: Timestamp.fromDate(threeDaysLater))
        .where('isPaid', isEqualTo: false)
        .get();

    for (var doc in billsSnapshot.docs) {
      final billData = doc.data();
      final billId = doc.id;
      final billName = billData['name'];
      final dueDate = (billData['dueDate'] as Timestamp).toDate();
      final amount = billData['amount'];

      // Calculate days until due
      final daysUntilDue = dueDate.difference(now).inDays;

      // Send reminder notification
      await _sendBillReminder(
          billId: billId,
          billName: billName,
          dueDate: dueDate,
          amount: amount,
          daysUntilDue: daysUntilDue);
    }
  }

  Future<void> _sendBillReminder({
    required String billId,
    required String billName,
    required DateTime dueDate,
    required double amount,
    required int daysUntilDue,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendBillReminder');

      await callable.call({
        'billId': billId,
        'billName': billName,
        'dueDate': dueDate.toIso8601String(),
        'amount': amount,
        'daysUntilDue': daysUntilDue
      });

      print('Bill reminder sent for: $billName');
    } catch (e) {
      print('Error sending bill reminder: $e');
    }
  }
}
