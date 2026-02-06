import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationId;
  final String senderId;
  final String senderName;
  final String senderProfilePic;
  final String receiverId;
  final String type; // 'like', 'comment', 'follow', 'login_alert'
  final String? postId;
  final String? text; // For comments or logic display
  final Map<String, dynamic>? deviceInfo; // For login alerts
  final Timestamp timestamp;
  final bool isRead;

  NotificationModel({
    required this.notificationId,
    required this.senderId,
    required this.senderName,
    required this.senderProfilePic,
    required this.receiverId,
    required this.type,
    this.postId,
    this.text,
    this.deviceInfo,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderProfilePic': senderProfilePic,
      'receiverId': receiverId,
      'type': type,
      'postId': postId,
      'text': text,
      'deviceInfo': deviceInfo,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      notificationId: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderProfilePic: map['senderProfilePic'] ?? '',
      receiverId: map['receiverId'] ?? '',
      type: map['type'] ?? '',
      postId: map['postId'],
      text: map['text'],
      deviceInfo: map['deviceInfo'] as Map<String, dynamic>?,
      timestamp: map['timestamp'] ?? Timestamp.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  NotificationModel copyWith({
    String? notificationId,
    String? senderId,
    String? senderName,
    String? senderProfilePic,
    String? receiverId,
    String? type,
    String? postId,
    String? text,
    Map<String, dynamic>? deviceInfo,
    Timestamp? timestamp,
    bool? isRead,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderProfilePic: senderProfilePic ?? this.senderProfilePic,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      postId: postId ?? this.postId,
      text: text ?? this.text,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
