import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skilltok/core/models/user_model.dart';

class UserRepository {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );

  /// ----------------------------
  /// GET USER STREAM (for real-time updates)
  /// ----------------------------
  Stream<UserModel?> getUserStream(String uid) {
    return users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
    });
  }

  /// ----------------------------
  /// CREATE USER DOCUMENT
  /// ----------------------------
  Future<void> createUser(UserModel user) async {
    await users.doc(user.uid).set(user.toMap());
  }

  /// ----------------------------
  /// UPDATE USER DATA
  /// (name, bio, photo, username, token…)
  /// ----------------------------
  Future<void> updateUser(UserModel user) async {
    await users.doc(user.uid).update(user.toMap());
  }

  /// ----------------------------
  /// UPDATE a single field
  /// ----------------------------
  Future<void> updateUserField(String uid, Map<String, Object?> data) async {
    await users.doc(uid).update(data);
  }

  /// ----------------------------
  /// GET USER DATA
  /// ----------------------------
  Future<UserModel?> getUser(String uid) async {
    final doc = await users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
  }

  Future<void> followUser(String currentUserId, String userIdToFollow) async {
    final userDoc = await users.doc(userIdToFollow).get();
    if (!userDoc.exists) return;

    final targetUser = UserModel.fromMap(
      userDoc.data() as Map<String, dynamic>,
      userIdToFollow,
    );

    // If private profile, send request
    if (targetUser.isPrivateProfile) {
      await users.doc(userIdToFollow).update({
        'followRequests': FieldValue.arrayUnion([currentUserId]),
      });
    } else {
      // Public profile, follow directly
      await users.doc(currentUserId).update({
        'following': FieldValue.arrayUnion([userIdToFollow]),
      });
      await users.doc(userIdToFollow).update({
        'followers': FieldValue.arrayUnion([currentUserId]),
      });
    }
  }

  Future<void> unfollowUser(
    String currentUserId,
    String userIdToUnfollow,
  ) async {
    await users.doc(currentUserId).update({
      'following': FieldValue.arrayRemove([userIdToUnfollow]),
    });
    await users.doc(userIdToUnfollow).update({
      'followers': FieldValue.arrayRemove([currentUserId]),
    });
  }

  Future<void> cancelFollowRequest(
    String currentUserId,
    String targetUserId,
  ) async {
    await users.doc(targetUserId).update({
      'followRequests': FieldValue.arrayRemove([currentUserId]),
    });
  }

  Future<void> acceptFollowRequest(
    String currentUserId,
    String requesterId,
  ) async {
    // 1. Remove from requests
    await users.doc(currentUserId).update({
      'followRequests': FieldValue.arrayRemove([requesterId]),
      'followers': FieldValue.arrayUnion([requesterId]),
    });

    // 2. Add to following for requester
    await users.doc(requesterId).update({
      'following': FieldValue.arrayUnion([currentUserId]),
    });
  }

  Future<void> declineFollowRequest(
    String currentUserId,
    String requesterId,
  ) async {
    await users.doc(currentUserId).update({
      'followRequests': FieldValue.arrayRemove([requesterId]),
    });
  }

  /// ----------------------------
  /// CHECK IF USER EXISTS
  /// ----------------------------
  Future<bool> userExists(String uid) async {
    final doc = await users.doc(uid).get();
    return doc.exists;
  }

  /// ----------------------------
  /// CHECK IF USERNAME EXISTS
  /// ----------------------------
  Future<bool> usernameExists(String username) async {
    final result = await users
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  /// ----------------------------
  /// DELETE USER DATA
  /// (لو حبيت تعمل حذف كامل)
  /// ----------------------------
  Future<void> deleteUser(String uid) async {
    await users.doc(uid).delete();
  }

  Future<void> toggleSavePost(String uid, String postId) async {
    final doc = await users.doc(uid).get();
    if (doc.exists) {
      final user = UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      if (user.savedPosts.contains(postId)) {
        await users.doc(uid).update({
          'savedPosts': FieldValue.arrayRemove([postId]),
        });
      } else {
        await users.doc(uid).update({
          'savedPosts': FieldValue.arrayUnion([postId]),
        });
      }
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    // Simple search by prefix (case-insensitive via usernameLower)
    final lowerQuery = query.toLowerCase();
    final snapshot = await users
        .where('usernameLower', isGreaterThanOrEqualTo: lowerQuery)
        .where('usernameLower', isLessThan: '${lowerQuery}z')
        .get();

    return snapshot.docs
        .map(
          (doc) =>
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }
}
