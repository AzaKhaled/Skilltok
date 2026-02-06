import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skilltok/core/models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> sendNotification({
    required String senderId,
    required String senderName,
    required String senderProfilePic,
    required String receiverId,
    required String type,
    String? postId,
    String? text,
    Map<String, dynamic>? deviceInfo,
  }) async {
    final notificationRef = _firestore.collection('notifications').doc();
    final notification = NotificationModel(
      notificationId: notificationRef.id,
      senderId: senderId,
      senderName: senderName,
      senderProfilePic: senderProfilePic,
      receiverId: receiverId,
      type: type,
      postId: postId,
      text: text,
      deviceInfo: deviceInfo,
      timestamp: Timestamp.now(),
    );

    await notificationRef.set(notification.toMap());
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }
}
