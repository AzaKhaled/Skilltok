import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:skilltok/core/models/post_model.dart';
import 'package:skilltok/core/models/user_model.dart';
import 'package:skilltok/core/utils/constants/routes.dart';

class NotificationService {
  static const String _projectId = 'skilltok-bf45d';
  static Future<String> getAccessToken() async {
    final jsonString = await rootBundle.loadString(
      'assets/firebase/skilltok-bf45d-firebase-adminsdk-fbsvc-208634cead.json',
    );

    final accountCredentials = auth.ServiceAccountCredentials.fromJson(
      jsonString,
    );

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await auth.clientViaServiceAccount(
      accountCredentials,
      scopes,
    );

    return client.credentials.accessToken.data;
  }

  static Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    try {
      final String accessToken = await getAccessToken();
      const String fcmUrl =
          'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          'message': {
            'token': token,
            'notification': {'title': title, 'body': body},
            'data': data,
            'android': {
              'notification': {
                // "sound": "custom_sound",
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'channel_id': 'high_importance_channel',
              },
            },
            // 'apns': {
            //   'payload': {
            //     'aps': {"sound": "custom_sound.caf", 'content-available': 1},
            //   },
            // },
          },
        }),
      );

      if (response.statusCode == 200) {
        log('Notification sent successfully');
      } else {
        log('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      log('Error sending notification: $e');
    }
  }

  static Future<void> send({
    required String receiverId,
    required String title,
    required Map<String, String> contents,
    required Map<String, dynamic> data,
  }) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .get();

      if (!userDoc.exists) return;

      final user = UserModel.fromMap(userDoc.data()!, receiverId);
      final token = user.fcmToken;

      if (token != null && token.isNotEmpty) {
        // Use English content by default, or the first available
        final body = contents['en'] ?? contents.values.first;

        // Convert data values to String as FCM data expects Map<String, String>
        final stringData = data.map(
          (key, value) => MapEntry(key, value.toString()),
        );

        await sendNotification(
          token: token,
          title: title,
          body: body,
          data: stringData,
        );
      }
    } catch (e) {
      log("Error fetching user for notification: $e");
    }
  }

  static Future<void> handleNotification(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    log("Handling notification with data: $data");

    final String? type = data['type'];
    final String? postId = data['postId'];
    final String? senderId = data['senderId'];

    if (type == 'comment') {
      if (postId != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .get();
          if (doc.exists) {
            final post = PostModel.fromMap(doc.data()!, doc.id);
            if (context.mounted) {
              Navigator.pushNamed(context, Routes.comments, arguments: post);
            }
          }
        } catch (e) {
          log("Error fetching post for notification: $e");
        }
      }
    } else if (type == 'like') {
      if (postId != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .get();
          if (doc.exists) {
            final post = PostModel.fromMap(doc.data()!, doc.id);
            if (context.mounted) {
              Navigator.pushNamed(context, Routes.likesList, arguments: post);
            }
          }
        } catch (e) {
          log("Error fetching post for notification: $e");
        }
      }
    } else if (type == 'follow') {
      if (senderId != null) {
        if (context.mounted) {
          Navigator.pushNamed(context, Routes.profile, arguments: senderId);
        }
      }
    } else if (type == 'follow_request') {
      if (context.mounted) {
        Navigator.pushNamed(context, Routes.followRequests);
      }
    }
  }
}
