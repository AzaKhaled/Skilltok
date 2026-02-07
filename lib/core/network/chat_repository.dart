import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skilltok/core/models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate consistent chat ID for two users
  String getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join("_");
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
    String? imageUrl,
  }) async {
    final chatId = getChatId(senderId, receiverId);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final messageId = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc()
        .id;

    final message = MessageModel(
      id: messageId,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      imageUrl: imageUrl,
      timestamp: timestamp,
      seen: false,
    );

    // 1. Add message to subcollection
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    // 2. Update chat metadata (last message, unread count)
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();

    Map<String, dynamic> unreadCounts = {};
    if (chatDoc.exists && chatDoc.data()!.containsKey('unreadCounts')) {
      unreadCounts = Map<String, dynamic>.from(chatDoc.data()!['unreadCounts']);
    }

    // Increment unread count for receiver
    unreadCounts[receiverId] = (unreadCounts[receiverId] ?? 0) + 1;

    await _firestore.collection('chats').doc(chatId).set({
      'participants': [senderId, receiverId],
      'lastMessage': text,
      'lastMessageTime': timestamp,
      'unreadCounts': unreadCounts,
      'participantsData': {
        // We might want to store basic user data to avoid redundant fetches,
        // but for now relying on participants array is safer for keeping data fresh via separate fetches if needed.
        // However, standard practice often involves just IDs.
        // We will fetch User data in the list view based on ID.
      },
    }, SetOptions(merge: true));
  }

  Stream<List<Map<String, dynamic>>> getChats(String userId) {
    // Returns List of Chat Documents including metadata
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        // .orderBy('lastMessageTime', descending: true) // Removed to avoid index issues
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['chatId'] = doc.id;
            return data;
          }).toList(),
        );
  }

  Stream<List<MessageModel>> getMessages(String senderId, String receiverId) {
    final chatId = getChatId(senderId, receiverId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> markMessagesAsSeen(String senderId, String receiverId) async {
    try {
      final chatId = getChatId(senderId, receiverId);

      // 1. Reset unread count for current user
      final chatRef = _firestore.collection('chats').doc(chatId);

      _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(chatRef);
        if (!snapshot.exists) return;

        Map<String, dynamic> unreadCounts = {};
        if (snapshot.data()!.containsKey('unreadCounts')) {
          unreadCounts = Map<String, dynamic>.from(
            snapshot.data()!['unreadCounts'],
          );
        }

        // If I am reading, my unread count goes to 0
        unreadCounts[senderId] = 0;

        transaction.update(chatRef, {'unreadCounts': unreadCounts});
      });

      // 2. Mark actual message documents as seen
      final messagesQuery = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: senderId) // Messages sent TO me
          .where('seen', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in messagesQuery.docs) {
        batch.update(doc.reference, {'seen': true});
      }
      await batch.commit();
    } catch (e) {
      // Ignore permission errors if rules aren't set up yet, to avoid crashing UI
      debugPrint("Error marking messages as seen: $e");
    }
  }
}
