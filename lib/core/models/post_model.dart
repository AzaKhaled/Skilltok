import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skilltok/core/models/comment_model.dart';

class PostModel {
  final String postId;
  final String userId;
  final String username;
  final String userProfilePic;
  final Timestamp timestamp;
  final String? text;
  final String? imageUrl;
  final List<String> likes;
  final List<CommentModel> comments;
  final bool isPrivate;

  PostModel({
    required this.postId,
    required this.userId,
    required this.username,
    required this.userProfilePic,
    required this.timestamp,
    this.text,
    this.imageUrl,
    required this.likes,
    required this.comments,
    this.isPrivate = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'userProfilePic': userProfilePic,
      'timestamp': timestamp,
      'text': text,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments.map((c) => c.toMap()).toList(),
      'isPrivate': isPrivate,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      postId: id,
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userProfilePic: map['userProfilePic'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      text: map['text'],
      imageUrl: map['imageUrl'],
      likes: List<String>.from(map['likes'] ?? []),
      comments: (map['comments'] as List<dynamic>? ?? [])
          .asMap()
          .entries
          .map((e) => CommentModel.fromMap(e.value, e.key.toString()))
          .toList(),
      isPrivate: map['isPrivate'] ?? false,
    );
  }

  PostModel copyWith({
    String? postId,
    String? userId,
    String? username,
    String? userProfilePic,
    Timestamp? timestamp,
    String? text,
    String? imageUrl,
    List<String>? likes,
    List<CommentModel>? comments,
    bool? isPrivate,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userProfilePic: userProfilePic ?? this.userProfilePic,
      timestamp: timestamp ?? this.timestamp,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}
