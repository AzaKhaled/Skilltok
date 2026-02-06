import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skilltok/core/models/post_model.dart';
import 'package:skilltok/core/network/post_repository.dart';
import 'package:skilltok/core/network/service/notification_service.dart';
import 'package:skilltok/core/network/notification_repository.dart';
import 'package:skilltok/core/models/user_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

part 'post_state.dart';

class PostCubit extends Cubit<PostStates> {
  PostCubit() : super(PostInitialState());

  // ignore: strict_top_level_inference
  static PostCubit get(context) => BlocProvider.of(context);

  final PostRepository postRepo = PostRepository();
  final NotificationRepository notificationRepo = NotificationRepository();

  final postTextController = TextEditingController();
  List<PostModel> posts = [];
  File? postVideo;
  bool isPrivate = false;

  void togglePrivacy(bool value) {
    isPrivate = value;
    emit(PostPrivacyChangedState(isPrivate));
  }

  Future<void> pickPostVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      postVideo = File(pickedFile.path);
      emit(PostPickPostVideoState());
    }
  }

  void removePostVideo() {
    postVideo = null;
    emit(PostRemovePostVideoState());
  }

  Future<String> uploadVideoToCloudinary(File videoFile) async {
    const cloudName = 'da1ytk4sk';
    const uploadPreset = 'skilltok';

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['secure_url'];
    } else {
      debugPrint(res.body);
      throw Exception('Cloudinary video upload failed');
    }
  }

  Future<void> addPost({
    required String text,
    required UserModel userModel,
  }) async {
    emit(PostAddPostLoadingState());
    try {
      String? imageUrl;
      if (postVideo != null) {
        imageUrl = await uploadVideoToCloudinary(postVideo!);
      }

      await postRepo.addPost(
        userId: userModel.uid!,
        username: userModel.username!,
        userProfilePic: userModel.photoUrl!,
        text: text,
        imageUrl: imageUrl,
        isPrivate: isPrivate,
      );

      postVideo = null;
      postTextController.clear();
      isPrivate = false;

      emit(PostAddPostSuccessState());
    } catch (e) {
      emit(PostAddPostErrorState(e.toString()));
    }
  }

  StreamSubscription? _postsSubscription;

  void getPosts() {
    emit(PostGetPostsLoadingState());
    try {
      _postsSubscription?.cancel();
      _postsSubscription = postRepo.getPosts().listen((posts) {
        this.posts = posts;
        emit(PostGetPostsSuccessState(posts));
      });
    } catch (e) {
      emit(PostGetPostsErrorState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }

  Stream<PostModel> getPostStream(String postId) {
    return postRepo.getPostStream(postId);
  }

  Future<void> togglePostLike({
    required PostModel post,
    required UserModel userModel,
  }) async {
    final isLiked = post.likes.contains(userModel.uid);

    try {
      await postRepo.toggleLike(
        postId: post.postId,
        currentUserId: userModel.uid!,
        likes: post.likes,
      );
      if (!isLiked && post.userId != userModel.uid) {
        await NotificationService.send(
          receiverId: post.userId,
          title: userModel.username!,
          contents: {"en": "liked your post ❤️", "ar": "أعجب بمنشورك ❤️"},
          data: {
            "type": "like",
            "postId": post.postId,
            "senderId": userModel.uid!,
          },
        );
        await notificationRepo.sendNotification(
          senderId: userModel.uid!,
          senderName: userModel.username!,
          senderProfilePic: userModel.photoUrl!,
          receiverId: post.userId,
          type: 'like',
          postId: post.postId,
          text: 'liked your post ❤️',
        );
      }
      emit(PostLikePostSuccessState());
    } catch (e) {
      emit(PostLikePostErrorState(e.toString()));
    }
  }

  Future<void> deletePost(String postId) async {
    emit(PostDeletePostLoadingState());
    try {
      await postRepo.deletePost(postId);
      posts.removeWhere((post) => post.postId == postId);
      emit(PostDeletePostSuccessState());
    } catch (e) {
      emit(PostDeletePostErrorState(e.toString()));
    }
  }

  // Edit Post
  final TextEditingController editPostController = TextEditingController();
  File? editpostVideo;
  String? editpostVideoUrl;

  void initEditPost(PostModel post) {
    editPostController.text = post.text ?? '';
    editpostVideo = null;
    editpostVideoUrl = post.imageUrl;
  }

  Future<void> updatePost({required String postId}) async {
    emit(PostUpdatePostLoadingState());
    try {
      String? imageUrl;
      final oldPost = posts.firstWhere((p) => p.postId == postId);
      if (editpostVideo != null) {
        imageUrl = await uploadVideoToCloudinary(editpostVideo!);
      } else if (editpostVideoUrl == null) {
        imageUrl = null;
      } else {
        imageUrl = oldPost.imageUrl;
      }
      await postRepo.updatePost(
        postId: postId,
        text: editPostController.text.trim(),
        imageUrl: imageUrl,
      );
      final index = posts.indexWhere((p) => p.postId == postId);
      if (index != -1) {
        posts[index] = posts[index].copyWith(
          text: editPostController.text.trim(),
          imageUrl: imageUrl,
        );
      }
      editPostController.clear();
      editpostVideo = null;
      editpostVideoUrl = null;
      emit(PostUpdatePostSuccessState());
    } catch (e) {
      emit(PostUpdatePostErrorState(e.toString()));
    }
  }

  void removeEditpostVideo() {
    editpostVideo = null;
    editpostVideoUrl = null;
    emit(PostRemoveEditpostVideoState());
  }
}
