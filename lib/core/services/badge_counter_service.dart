import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BadgeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of unread notification count
  Stream<int> get unreadNotificationCount {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Update app badge number (iOS and some Android launchers)
  Future<void> updateAppBadge(int count) async {
    // if (await FlutterAppBadger.isAppBadgeSupported()) {
    //   if (count > 0) {
    //     await FlutterAppBadger.updateBadgeCount(count);
    //   } else {
    //     await FlutterAppBadger.removeBadge();
    //   }
    // }
  }
}
