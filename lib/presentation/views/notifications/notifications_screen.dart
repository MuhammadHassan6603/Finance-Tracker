import 'package:finance_tracker/core/constants/theme_constants.dart';
import 'package:finance_tracker/data/models/notification_model.dart';
import 'package:finance_tracker/data/repositories/notification_repository.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationRepository _repository = NotificationRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking notifications as read: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification removed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (!notification.isRead) {
      try {
        await _repository.markAsRead(notification.id);
        // Handle navigation based on notification data
        if (notification.data != null) {
          _handleNotificationNavigation(notification);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error marking notification as read: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleNotificationNavigation(AppNotification notification) {
    if (notification.data == null) return;

    final screen = notification.data!['screen'];
    final action = notification.data!['action'];

    switch (screen) {
      case 'budget_details':
        // Navigate to budget details
        break;
      case 'transaction_details':
        // Navigate to transaction details
        break;
      // Add more cases as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: ThemeConstants.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: _markAllAsRead,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
          ],
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: _repository.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final notifications = snapshot.data!;
          final unreadNotifications = notifications.where((n) => !n.isRead).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationsList(notifications),
              _buildNotificationsList(unreadNotifications),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    IconData getIconForCategory(String category) {
      switch (category) {
        case 'transaction':
          return Icons.account_balance_wallet_outlined;
        case 'budget':
          return Icons.money;
        case 'asset':
          return Icons.arrow_upward;
        case 'liability':
          return Icons.arrow_downward;
        case 'alert':
          return Icons.warning_amber_outlined;
        default:
          return Icons.notifications_outlined;
      }
    }

    Color getColorForCategory(String category) {
      switch (category) {
        case 'transaction':
          return Colors.blue;
        case 'budget':
          return Colors.orange;
        case 'asset':
          return Colors.green;
        case 'liability':
          return Colors.red;
        case 'alert':
          return Colors.amber;
        default:
          return Colors.grey;
      }
    }

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteNotification(notification.id),
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead ? null : Colors.blue.shade50,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: getColorForCategory(notification.category).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              getIconForCategory(notification.category),
              color: getColorForCategory(notification.category),
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(notification.message),
              const SizedBox(height: 4),
              Text(
                timeago.format(notification.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          isThreeLine: true,
          onTap: () => _markAsRead(notification),
          trailing: notification.isRead
              ? null
              : Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ),
    );
  }
}

// Sample notification data
final List<Map<String, dynamic>> allNotifications = [
  {
    'id': '1',
    'title': 'Budget Alert',
    'message': 'You\'ve reached 80% of your Food budget for this month.',
    'time': '10 minutes ago',
    'isRead': false,
    'category': 'budget',
  },
  {
    'id': '2',
    'title': 'New Transaction',
    'message': 'Payment of ₹2,500 to Amazon has been recorded.',
    'time': '2 hours ago',
    'isRead': false,
    'category': 'transaction',
  },
  {
    'id': '3',
    'title': 'Bill Reminder',
    'message': 'Your electricity bill of ₹1,200 is due tomorrow.',
    'time': 'Yesterday',
    'isRead': true,
    'category': 'alert',
  },
  {
    'id': '4',
    'title': 'Asset Update',
    'message': 'Your investment portfolio has increased by 2.5%.',
    'time': '2 days ago',
    'isRead': true,
    'category': 'asset',
  },
  {
    'id': '5',
    'title': 'Loan Payment',
    'message': 'Your home loan EMI of ₹15,000 has been paid.',
    'time': '3 days ago',
    'isRead': true,
    'category': 'liability',
  },
  {
    'id': '6',
    'title': 'Budget Exceeded',
    'message': 'You\'ve exceeded your Shopping budget by ₹1,500.',
    'time': '5 days ago',
    'isRead': true,
    'category': 'budget',
  },
];
