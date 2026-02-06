import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/models/post_model.dart';
import 'package:skilltok/core/models/user_model.dart';
import 'package:skilltok/core/network/post_repository.dart';
import 'package:skilltok/core/network/user_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  ProfileCubit() : super(ProfileInitialState());

  // ignore: strict_top_level_inference
  static ProfileCubit get(context) => BlocProvider.of(context);

  final PostRepository postRepo = PostRepository();
  final UserRepository userRepo = UserRepository();

  List<PostModel> userPosts = [];
  List<PostModel> savedPosts = [];

  void getMyPosts(String uid) {
    emit(ProfileGetMyPostsLoadingState());
    try {
      postRepo.getUserPosts(uid).listen((posts) {
        userPosts = posts;
        emit(ProfileGetMyPostsSuccessState(posts));
      });
    } catch (e) {
      emit(ProfileGetMyPostsErrorState(e.toString()));
    }
  }

  Future<void> getSavedPosts(List<String> savedPostIds) async {
    emit(ProfileGetSavedPostsLoadingState());
    try {
      savedPosts = await postRepo.getPostsByIds(savedPostIds);
      emit(ProfileGetSavedPostsSuccessState(savedPosts));
    } catch (e) {
      emit(ProfileGetSavedPostsErrorState(e.toString()));
    }
  }

  File? profileImage;
  File? coverImage;

  final usernameController = TextEditingController();
  final bioController = TextEditingController();

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      emit(ProfileProfileImagePickedState());
    }
  }

  Future<void> pickCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      coverImage = File(pickedFile.path);
      emit(ProfileCoverImagePickedState());
    }
  }

  Future<String> uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'da1ytk4sk';
    const uploadPreset = 'skilltok';
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final response = await request.send();
    final res = await http.Response.fromStream(response);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['secure_url'];
    } else {
      debugPrint(res.body);
      throw Exception('Cloudinary upload failed');
    }
  }

  bool isPrivateProfile = false;

  Future<void> updateProfile({required UserModel userModel}) async {
    emit(ProfileUpdateProfileLoadingState());

    try {
      String profileUrl = userModel.photoUrl!;
      String? coverUrl = userModel.coverUrl;

      if (profileImage != null) {
        profileUrl = await uploadImageToCloudinary(profileImage!);
      }

      if (coverImage != null) {
        coverUrl = await uploadImageToCloudinary(coverImage!);
      }

      final updatedUser = userModel.copyWith(
        username: usernameController.text.trim(),
        bio: bioController.text.trim(),
        photoUrl: profileUrl,
        isPrivateProfile: isPrivateProfile,
        coverUrl: coverUrl,
      );

      await userRepo.updateUser(updatedUser);
      await postRepo.updateUserPosts(
        userId: updatedUser.uid!,
        username: updatedUser.username!,
        userProfilePic: updatedUser.photoUrl!,
      );

      profileImage = null;
      coverImage = null;

      emit(ProfileUpdateProfileSuccessState(updatedUser));
    } catch (e) {
      emit(ProfileUpdateProfileErrorState(e.toString()));
    }
  }
}
