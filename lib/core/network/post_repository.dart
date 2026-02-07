import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skilltok/core/models/comment_model.dart';
import 'package:skilltok/core/models/post_model.dart';
import 'package:uuid/uuid.dart';

class PostRepository {
  final FirebaseFirestore _firestore;

  PostRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addPost({
    required String userId,
    required String username,
    required String userProfilePic,
    String? text,
    String? imageUrl,
    bool isPrivate = false,
  }) async {
    final postRef = _firestore.collection('posts').doc();

    final newPost = PostModel(
      postId: postRef.id,
      userId: userId,
      username: username,
      userProfilePic: userProfilePic,
      timestamp: Timestamp.now(),
      text: text,
      imageUrl: imageUrl,
      likes: [],
      comments: [],
      isPrivate: isPrivate,
    );

    await postRef.set(newPost.toMap());
  }

  Stream<List<PostModel>> getPosts() {
    return _firestore.collection('posts').snapshots().map((snapshot) {
      final posts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data(), doc.id))
          .toList();

      posts.shuffle(); // 🔀 هنا الشفل

      return posts;
    });
  }

  Stream<PostModel> getPostStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .map((doc) => PostModel.fromMap(doc.data()!, doc.id));
  }

  Stream<List<PostModel>> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PostModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> toggleLike({
    required String postId,
    required String currentUserId,
    required List<String> likes,
  }) async {
    final postRef = _firestore.collection('posts').doc(postId);

    if (likes.contains(currentUserId)) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([currentUserId]),
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([currentUserId]),
      });
    }
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String username,
    required String userProfilePic,
    required String text,
    String? parentCommentId,
    String? replyToUsername,
  }) async {
    final commentId = const Uuid().v4();
    final comment = CommentModel(
      commentId: commentId,
      userId: userId,
      username: username,
      userProfilePic: userProfilePic,
      text: text,
      timestamp: Timestamp.now(),
      parentId: parentCommentId,
      replyToUsername: replyToUsername,
      reactions: [],
    );

    await _firestore.collection('posts').doc(postId).update({
      'comments': FieldValue.arrayUnion([comment.toMap()]),
    });
  }

  Future<void> toggleCommentReaction({
    required String postId,
    required String commentId,
    required String currentUserId,
  }) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final doc = await postRef.get();
    if (!doc.exists) return;

    final comments = List<Map<String, dynamic>>.from(
      doc.data()?['comments'] ?? [],
    );
    // find by embedded commentId if present, otherwise match by index string (legacy)
    int idx = comments.indexWhere((c) => c['commentId'] == commentId);
    if (idx == -1) {
      idx = comments.indexWhere(
        (c) => comments.indexOf(c).toString() == commentId,
      );
    }
    if (idx == -1) return;

    final commentMap = Map<String, dynamic>.from(comments[idx]);
    final List<String> reactions = List<String>.from(
      commentMap['reactions'] ?? [],
    );

    final updatedReactions = List<String>.from(reactions);
    if (updatedReactions.contains(currentUserId)) {
      updatedReactions.remove(currentUserId);
    } else {
      updatedReactions.add(currentUserId);
    }

    final updatedComment = Map<String, dynamic>.from(commentMap);
    updatedComment['reactions'] = updatedReactions;

    // Perform update in place to preserve order
    comments[idx] = updatedComment;

    await postRef.update({'comments': comments});
  }

  Future<void> deleteComment({
    required String postId,
    required CommentModel comment,
  }) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final doc = await postRef.get();
    if (!doc.exists) return;

    final comments = List<Map<String, dynamic>>.from(
      doc.data()?['comments'] ?? [],
    );

    // 1. Find the comment in the list
    int idx = comments.indexWhere((c) => c['commentId'] == comment.commentId);

    // Fallback for legacy (index-based ID)
    if (idx == -1) {
      idx = comments.indexWhere(
        (c) => comments.indexOf(c).toString() == comment.commentId,
      );
    }

    if (idx == -1) return;

    // 2. Identify target map and Real ID
    final targetMap = comments[idx];
    final String? realCommentId = targetMap['commentId'] as String?;

    // 3. Mark for removal (use indices to be safe)
    final indicesToRemove = <int>{idx};

    // 4. If we have a real ID, find descendants
    if (realCommentId != null) {
      void collectDescendantIndices(String parentId) {
        for (int i = 0; i < comments.length; i++) {
          if (indicesToRemove.contains(i)) continue;
          final c = comments[i];
          if (c['parentId'] == parentId) {
            indicesToRemove.add(i);
            // Recurse
            final childId = c['commentId'] as String?;
            if (childId != null) {
              collectDescendantIndices(childId);
            }
          }
        }
      }

      collectDescendantIndices(realCommentId);
    }

    // 5. Build remaining list
    final remaining = <Map<String, dynamic>>[];
    for (int i = 0; i < comments.length; i++) {
      if (!indicesToRemove.contains(i)) {
        remaining.add(comments[i]);
      }
    }

    await postRef.update({'comments': remaining});
  }

  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String newText,
  }) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final doc = await postRef.get();
    if (!doc.exists) return;

    final comments = List<Map<String, dynamic>>.from(
      doc.data()?['comments'] ?? [],
    );

    int idx = comments.indexWhere((c) => c['commentId'] == commentId);
    if (idx == -1) {
      idx = comments.indexWhere(
        (c) => comments.indexOf(c).toString() == commentId,
      );
    }
    if (idx == -1) return;

    final commentMap = Map<String, dynamic>.from(comments[idx]);
    final updatedComment = Map<String, dynamic>.from(commentMap);
    updatedComment['text'] = newText;

    await postRef.update({
      'comments': FieldValue.arrayRemove([commentMap]),
    });
    await postRef.update({
      'comments': FieldValue.arrayUnion([updatedComment]),
    });
  }

  Future<void> updateUserPosts({
    required String userId,
    required String username,
    required String userProfilePic,
  }) async {
    final posts = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .get();
    final batch = _firestore.batch();
    for (final doc in posts.docs) {
      batch.update(doc.reference, {
        'username': username,
        'userProfilePic': userProfilePic,
      });
    }
    await batch.commit();
  }

  Future<void> updatePost({
    required String postId,
    required String text,
    String? imageUrl,
  }) async {
    await _firestore.collection('posts').doc(postId).update({
      'text': text,
      'imageUrl': imageUrl,
    });
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  Future<List<PostModel>> getPostsByIds(List<String> postIds) async {
    if (postIds.isEmpty) return [];

    // Firestore LIMIT: whereIn supports up to 10 values.
    // We need to chunk the requests.
    final List<PostModel> allPosts = [];
    final int chunkSize = 10;

    for (var i = 0; i < postIds.length; i += chunkSize) {
      final chunk = postIds.sublist(
        i,
        i + chunkSize > postIds.length ? postIds.length : i + chunkSize,
      );

      final snapshot = await _firestore
          .collection('posts')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      allPosts.addAll(
        snapshot.docs.map((doc) => PostModel.fromMap(doc.data(), doc.id)),
      );
    }

    return allPosts;
  }
}
