import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String userId;
  final String username;
  final String userProfilePic;
  final String text;
  final Timestamp timestamp;
  final String? parentId; // for replies
  final String? replyToUsername; // the username being replied to
  final List<String> reactions; // list of userIds who reacted (heart)

  CommentModel({
    required this.commentId,
    required this.userId,
    required this.username,
    required this.userProfilePic,
    required this.text,
    required this.timestamp,
    this.parentId,
    this.replyToUsername,
    this.reactions = const [],
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String commentId) {
    return CommentModel(
      commentId: commentId,
      userId: map['userId'] as String,
      username: map['username'] as String,
      userProfilePic: map['userProfilePic'] as String,
      text: map['text'] as String,
      timestamp: map['timestamp'] as Timestamp,
      parentId: map['parentId'] as String?,
      replyToUsername: map['replyToUsername'] as String?,
      reactions: List<String>.from(map['reactions'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'userId': userId,
      'username': username,
      'userProfilePic': userProfilePic,
      'text': text,
      'timestamp': timestamp,
      'parentId': parentId,
      'replyToUsername': replyToUsername,
      'reactions': reactions,
    };
  }
}
