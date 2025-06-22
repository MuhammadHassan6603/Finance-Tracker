// lib/core/services/recurring_transaction_notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:convert';
import '../../data/models/transaction_model.dart';
import '../../data/models/app_notification_model.dart';
import 'notification_storeage_service.dart';

class RecurringTransactionNotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationStorageService _storageService =
      NotificationStorageService();

  RecurringTransactionNotificationService() {
    tz_data.initializeTimeZones();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _localNotifications.initialize(initSettings);

      // Create notification channels
      await _createNotificationChannels();
    } catch (e) {
      print('Error initializing notifications: $e');
      // You might want to rethrow or handle this error differently
    }
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel recurringChannel =
        AndroidNotificationChannel(
      'recurring_transactions',
      'Recurring Transactions',
      description: 'Notifications for recurring transaction processing',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const AndroidNotificationChannel reminderChannel =
        AndroidNotificationChannel(
      'transaction_reminders',
      'Transaction Reminders',
      description: 'Reminders for upcoming recurring transactions',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(recurringChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reminderChannel);
  }

  // Schedule notifications for recurring transactions
  Future<void> scheduleRecurringTransactionNotifications(
      TransactionModel transaction) async {
    try {
      if (!transaction.isRecurring) return;

      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('User not authenticated');
        return;
      }

      // Schedule reminder notification (1 day before due)
      await _scheduleReminderNotification(transaction);

      // Schedule processing notification (on due date)
      await _scheduleProcessingNotification(transaction);

      // Store scheduled notification info in Firestore
      await _storeScheduledNotificationInfo(transaction);
    } catch (e) {
      print('Error scheduling recurring transaction notifications: $e');
    }
  }

  Future<void> _scheduleReminderNotification(
      TransactionModel transaction) async {
    try {
      final nextDueDate = _calculateNextDueDate(transaction);
      final reminderDate = nextDueDate.subtract(const Duration(days: 1));

      // Only schedule if reminder date is in the future
      if (reminderDate.isAfter(DateTime.now())) {
        final notificationId =
            _generateNotificationId(transaction.id!, 'reminder');

        await _localNotifications.zonedSchedule(
          notificationId,
          '📅 Recurring Transaction Reminder',
          '${transaction.description} (${transaction.amount.toStringAsFixed(2)}) is due tomorrow',
          tz.TZDateTime.from(reminderDate, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'transaction_reminders',
              'Transaction Reminders',
              channelDescription: 'Reminders for upcoming recurring transactions',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/launcher_icon',
              color: transaction.type == TransactionType.income
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFF44336),
              styleInformation: BigTextStyleInformation(
                '${transaction.description} (${_formatCurrency(transaction.amount)}) is scheduled for tomorrow. Make sure you have sufficient funds.',
                contentTitle: '📅 Recurring Transaction Reminder',
              ),
            ),
            iOS: DarwinNotificationDetails(
              categoryIdentifier: 'RECURRING_REMINDER',
              threadIdentifier: 'recurring_${transaction.id}',
              subtitle: transaction.category,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: jsonEncode({
            'type': 'recurring_reminder',
            'transactionId': transaction.id,
            'screen': 'transaction_details',
            'action': 'view_recurring'
          }),
        );
      }
    } catch (e) {
      print('Error scheduling reminder notification: $e');
    }
  }

  Future<void> _scheduleProcessingNotification(
      TransactionModel transaction) async {
    try {
      final nextDueDate = _calculateNextDueDate(transaction);

      // Only schedule if due date is in the future
      if (nextDueDate.isAfter(DateTime.now())) {
        final notificationId =
            _generateNotificationId(transaction.id!, 'process');

        await _localNotifications.zonedSchedule(
          notificationId,
          '💰 Recurring Transaction Processed',
          '${transaction.description} has been automatically processed',
          tz.TZDateTime.from(nextDueDate, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'recurring_transactions',
              'Recurring Transactions',
              channelDescription:
                  'Notifications for recurring transaction processing',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/launcher_icon',
              color: transaction.type == TransactionType.income
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFF44336),
              styleInformation: BigTextStyleInformation(
                '${transaction.description} (${_formatCurrency(transaction.amount)}) has been automatically added to your ${transaction.type.name}.',
                contentTitle: '💰 Recurring Transaction Processed',
              ),
              actions: [
                AndroidNotificationAction(
                  'view_transaction',
                  'View Details',
                  icon: DrawableResourceAndroidBitmap('@drawable/ic_view'),
                ),
                AndroidNotificationAction(
                  'edit_recurring',
                  'Edit Recurring',
                  icon: DrawableResourceAndroidBitmap('@drawable/ic_edit'),
                ),
              ],
            ),
            iOS: DarwinNotificationDetails(
              categoryIdentifier: 'RECURRING_PROCESSED',
              threadIdentifier: 'recurring_${transaction.id}',
              subtitle: transaction.category,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: jsonEncode({
            'type': 'recurring_processed',
            'transactionId': transaction.id,
            'screen': 'transaction_details',
            'action': 'view_processed'
          }),
        );
      }
    } catch (e) {
      print('Error scheduling processing notification: $e');
    }
  }

  // Send immediate notification when recurring transaction is processed
  Future<void> sendRecurringTransactionProcessedNotification(
      TransactionModel processedTransaction) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('User not authenticated');
        return;
      }

      // Send local notification
      await _sendLocalProcessedNotification(processedTransaction);

      // Send push notification via FCM (if backend is configured)
      await _sendPushNotification(processedTransaction);

      // Store notification in Firestore
      await _storeProcessedNotificationInFirestore(processedTransaction);
    } catch (e) {
      print('Error sending processed notification: $e');
    }
  }

  Future<void> _sendLocalProcessedNotification(
      TransactionModel transaction) async {
    const notificationId = 999999; // Unique ID for immediate notifications

    await _localNotifications.show(
      notificationId,
      '✅ Transaction Added Successfully',
      '${transaction.description} (${_formatCurrency(transaction.amount)}) has been processed',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'recurring_transactions',
          'Recurring Transactions',
          channelDescription:
              'Notifications for recurring transaction processing',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          color: transaction.type == TransactionType.income
              ? const Color(0xFF4CAF50)
              : const Color(0xFFF44336),
          styleInformation: BigTextStyleInformation(
            'Your recurring ${transaction.type.name} "${transaction.description}" for ${_formatCurrency(transaction.amount)} has been automatically added to your account.',
            contentTitle: '✅ Recurring Transaction Processed',
          ),
          actions: [
            AndroidNotificationAction(
              'view_transaction',
              'View Transaction',
              icon: DrawableResourceAndroidBitmap('@drawable/ic_view'),
            ),
            AndroidNotificationAction(
              'view_balance',
              'Check Balance',
              icon: DrawableResourceAndroidBitmap('@drawable/ic_balance'),
            ),
          ],
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'TRANSACTION_PROCESSED',
          threadIdentifier: 'processed_${transaction.id}',
          subtitle: 'Recurring ${transaction.type.name}',
        ),
      ),
      payload: jsonEncode({
        'type': 'transaction_processed',
        'transactionId': transaction.id,
        'screen': 'transaction_details',
        'action': 'view_new_transaction'
      }),
    );
  }

  Future<void> _sendPushNotification(TransactionModel transaction) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final fcmToken = await _messaging.getToken();
      if (fcmToken == null) {
        print('FCM token not available');
        return;
      }

      await _firestore.collection('notification_queue').add({
        'userId': userId,
        'fcmToken': fcmToken,
        'type': 'recurring_transaction_processed',
        'title': '💰 Recurring Transaction Processed',
        'body':
            '${transaction.description} (${_formatCurrency(transaction.amount)}) has been processed',
        'data': {
          'transactionId': transaction.id,
          'screen': 'transaction_details',
          'type': 'recurring_processed',
        },
        'timestamp': FieldValue.serverTimestamp(),
        'processed': false,
      });
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  Future<void> _storeProcessedNotificationInFirestore(
      TransactionModel transaction) async {
    try {
      final notification = AppNotification(
        id: '',
        title: 'Recurring Transaction Processed',
        body:
            '${transaction.description} (${_formatCurrency(transaction.amount)}) has been automatically processed',
        type: 'recurring_processed',
        isRead: false,
        timestamp: DateTime.now(),
        data: {
          'transactionId': transaction.id,
          'transactionType': transaction.type.name,
          'amount': transaction.amount,
          'category': transaction.category,
        },
      );

      await _storageService.storeNotification(notification);
    } catch (e) {
      print('Error storing notification in Firestore: $e');
    }
  }

  Future<void> _storeScheduledNotificationInfo(
      TransactionModel transaction) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('scheduled_notifications')
        .doc(transaction.id)
        .set({
      'transactionId': transaction.id,
      'nextDueDate': _calculateNextDueDate(transaction),
      'reminderScheduled': true,
      'processingScheduled': true,
      'recurringPattern': transaction.recurringFrequency,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Cancel notifications for a recurring transaction
  Future<void> cancelRecurringNotifications(String transactionId) async {
    try {
      final reminderNotificationId =
          _generateNotificationId(transactionId, 'reminder');
      final processNotificationId =
          _generateNotificationId(transactionId, 'process');

      await _localNotifications.cancel(reminderNotificationId);
      await _localNotifications.cancel(processNotificationId);

      // Remove from Firestore
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('scheduled_notifications')
            .doc(transactionId)
            .delete();
      }
    } catch (e) {
      print('Error cancelling recurring notifications: $e');
    }
  }

  // Update notifications when recurring transaction is modified
  Future<void> updateRecurringNotifications(
      TransactionModel transaction) async {
    // Cancel existing notifications
    await cancelRecurringNotifications(transaction.id!);

    // Schedule new notifications with updated details
    if (transaction.isRecurring) {
      await scheduleRecurringTransactionNotifications(transaction);
    }
  }

  // Check and process due recurring transactions
  Future<void> checkAndProcessDueTransactions() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final recurringSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('isRecurring', isEqualTo: true)
          .get();

      for (var doc in recurringSnapshot.docs) {
        try {
          final transaction = TransactionModel.fromJson(doc.data());
          final nextDueDate = _calculateNextDueDate(transaction);
          final now = DateTime.now();
          final timeDiff = nextDueDate.difference(now).inMinutes;

          if (timeDiff <= 60 && timeDiff >= -60) {
            // Process the recurring transaction
            await _processRecurringTransaction(transaction);
          }
        } catch (e) {
          print('Error processing individual recurring transaction: $e');
          // Continue processing other transactions
        }
      }
    } catch (e) {
      print('Error checking and processing due transactions: $e');
    }
  }

  Future<void> _processRecurringTransaction(
      TransactionModel recurringTransaction) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Create new transaction from recurring template
      final newTransaction = recurringTransaction.copyWith(
        id: null, // Will be generated
        date: DateTime.now(),
        isRecurring: false, // The processed transaction is not recurring
        recurringFrequency: null,
      );

      // Add the new transaction to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .add(newTransaction.toJson());

      // Send notification about processed transaction
      await sendRecurringTransactionProcessedNotification(newTransaction);

      // Update the recurring transaction's next due date
      await _updateRecurringTransactionNextDue(recurringTransaction);
    } catch (e) {
      print('Error processing recurring transaction: $e');
    }
  }

  Future<void> _updateRecurringTransactionNextDue(
      TransactionModel recurringTransaction) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final nextDueDate = _calculateNextDueDate(recurringTransaction);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(recurringTransaction.id)
          .update({
        'lastProcessed': FieldValue.serverTimestamp(),
        'nextDueDate': Timestamp.fromDate(nextDueDate),
      });

      // Reschedule notifications for the next occurrence
      await scheduleRecurringTransactionNotifications(recurringTransaction);
    } catch (e) {
      print('Error updating recurring transaction next due date: $e');
    }
  }

  DateTime _calculateNextDueDate(TransactionModel transaction) {
    final now = DateTime.now();

    switch (transaction.recurringFrequency) {
      case RecurringPattern.daily:
        return DateTime(now.year, now.month, now.day + 1);
      case RecurringPattern.weekly:
        return DateTime(now.year, now.month, now.day + 7);
      case RecurringPattern.monthly:
        return DateTime(now.year, now.month + 1, now.day);
      case RecurringPattern.yearly:
        return DateTime(now.year + 1, now.month, now.day);
      default:
        return now.add(const Duration(days: 30)); // Default to monthly
    }
  }

  int _generateNotificationId(String transactionId, String type) {
    final combined = '$transactionId$type';
    return combined.hashCode.abs() % 2147483647; // Ensure positive int32
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Get pending notifications
  Future<List<Map<String, dynamic>>> getPendingNotifications() async {
    final pending = await _localNotifications.pendingNotificationRequests();
    return pending
        .map((request) => {
              'id': request.id,
              'title': request.title,
              'body': request.body,
              'payload': request.payload,
            })
        .toList();
  }

  // Cancel all recurring notifications
  Future<void> cancelAllRecurringNotifications() async {
    await _localNotifications.cancelAll();
  }
}
