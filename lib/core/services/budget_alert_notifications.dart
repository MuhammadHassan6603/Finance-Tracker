// lib/services/budget_notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Setup budget threshold listeners
  Future<void> setupBudgetListeners() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Subscribe to user-specific budget alerts topic
    await _messaging.subscribeToTopic('user_${userId}_budget_alerts');

    // Get user budget categories
    final budgetSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('budget_categories')
        .get();

    // For each category, set up a listener to monitor spending
    for (var doc in budgetSnapshot.docs) {
      final categoryId = doc.id;
      final data = doc.data();

      _firestore
         
          .collection('transactions')
          .where('category', isEqualTo: categoryId)
          .snapshots()
          .listen((snapshot) {
        _checkBudgetThreshold(
            userId: userId,
            categoryId: categoryId,
            categoryName: data['name'],
            budgetLimit: data['limit']);
      });
    }
  }

  Future<void> _checkBudgetThreshold({
    required String userId,
    required String categoryId,
    required String categoryName,
    required double budgetLimit,
  }) async {
    // Calculate total spending for this category this month
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    final transactionsSnapshot = await _firestore
      
        .collection('transactions')
        .where('category', isEqualTo: categoryId)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
        .get();

    double totalSpending = 0;
    for (var doc in transactionsSnapshot.docs) {
      totalSpending += doc['amount'];
    }

    // Check thresholds and send alerts if necessary
    final percentSpent = (totalSpending / budgetLimit) * 100;

    if (percentSpent >= 90 && percentSpent < 100) {
      _sendThresholdNotification(
          userId: userId,
          categoryId: categoryId,
          categoryName: categoryName,
          budgetLimit: budgetLimit,
          currentSpending: totalSpending,
          threshold: 90);
    } else if (percentSpent >= 100) {
      _sendThresholdNotification(
          userId: userId,
          categoryId: categoryId,
          categoryName: categoryName,
          budgetLimit: budgetLimit,
          currentSpending: totalSpending,
          threshold: 100);
    } else if (percentSpent >= 75 && percentSpent < 90) {
      _sendThresholdNotification(
          userId: userId,
          categoryId: categoryId,
          categoryName: categoryName,
          budgetLimit: budgetLimit,
          currentSpending: totalSpending,
          threshold: 75);
    }
  }

  Future<void> _sendThresholdNotification({
    required String userId,
    required String categoryId,
    required String categoryName,
    required double budgetLimit,
    required double currentSpending,
    required int threshold,
  }) async {
    // This would typically call a Cloud Function or backend API
    // to send the notification, but for demonstration:
    print(
        'Would send notification: $threshold% of $categoryName budget reached');

    // Example of implementing with Cloud Functions:
    /*
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('sendBudgetAlert');
      final fcmToken = await _messaging.getToken();

      final result = await callable.call({
        'fcmToken': fcmToken,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'currentSpending': currentSpending,
        'budgetLimit': budgetLimit,
        'threshold': threshold
      });

      print('Notification sent: ${result.data}');
    } catch (e) {
      print('Error sending notification: $e');
    }
    */
  }
}
