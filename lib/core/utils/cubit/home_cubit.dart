// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:skilltok/core/models/comment_model.dart';
// import 'package:skilltok/core/models/notification_model.dart';
// import 'package:skilltok/core/models/post_model.dart';
// import 'package:skilltok/core/models/user_model.dart';
// import 'package:skilltok/core/network/local/cache_helper.dart';
// import 'package:skilltok/core/network/notification_repository.dart';
// import 'package:skilltok/core/network/post_repository.dart';
// import 'package:skilltok/core/network/service/notification_service.dart';
// import 'package:skilltok/core/network/user_repository.dart';
// import 'package:skilltok/core/utils/constants/constants.dart';
// import 'package:skilltok/core/utils/constants/routes.dart';
// import 'package:skilltok/core/utils/constants/translations.dart';
// import 'package:skilltok/core/utils/cubit/home_state.dart';
// import 'package:skilltok/core/utils/extensions/context_extension.dart';
// import 'package:skilltok/feuters/home/presentation/screen/home_screen.dart';
// import 'package:skilltok/feuters/home/presentation/widgets/notifications_screen.dart';
// import 'package:skilltok/feuters/profile/presentation/screen/profile_screen.dart';
// import 'package:skilltok/feuters/settings/presentation/screen/settings_screen.dart';
// import 'package:skilltok/main.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:video_player/video_player.dart';

// HomeCubit get homeCubit => HomeCubit.get(navigatorKey.currentContext!);

// class HomeCubit extends Cubit<HomeStates> {
//   HomeCubit() : super(HomeInitialState());

//   static HomeCubit get(BuildContext context) => BlocProvider.of(context);
//   final PostRepository postRepo = PostRepository();
//   final NotificationRepository notificationRepo = NotificationRepository();

//   bool _isDarkMode = false;

//   bool get isDarkMode => _isDarkMode;

//   void changeTheme({bool? fromShared}) {
//     _isDarkMode = fromShared ?? !_isDarkMode;
//     CacheHelper.saveData(key: 'isDark', value: _isDarkMode);
//     emit(HomeChangeThemeState());
//   }

//   bool _isArabicLang = false;
//   TranslationModel? _translationModel;

//   // Getters فقط (لا نسمح لأي كود خارجي يعدل القيمة)
//   bool get isArabicLang => _isArabicLang;

//   TranslationModel? get translationModel => _translationModel;

//   /// تغيير اللغة — الدالة الرسمية الوحيدة
//   Future<void> changeLanguage({
//     required bool isArabic,
//     required String translations,
//   }) async {
//     try {
//       if (_isArabicLang == isArabic && _translationModel != null) {
//         emit(HomeLanguageUpdatedState());
//         return;
//       }
//       emit(HomeLanguageLoadingState());
//       final model = TranslationModel.fromJson(json.decode(translations));
//       _isArabicLang = isArabic;
//       _translationModel = model;
//       emit(HomeLanguageUpdatedState());
//     } catch (e) {
//       emit(HomeLanguageErrorState(e.toString()));
//     }
//   }

//   Future<void> initializeLanguage({
//     required bool isArabic,
//     required String translations,
//   }) async {
//     try {
//       _isArabicLang = isArabic;
//       _translationModel = TranslationModel.fromJson(json.decode(translations));
//       emit(HomeLanguageLoadedState());
//     } catch (e) {
//       emit(HomeLanguageErrorState(e.toString()));
//     }
//   }

//   int _currentIndex = 0;

//   int get currentIndex => _currentIndex;

//   set currentIndex(int index) {
//     _currentIndex = index;
//     pauseAllVideos();
//     emit(ChangeBottomNavBarState());
//   }

//   int _currentBannerIndex = 0;

//   int get currentBannerIndex => _currentBannerIndex;

//   set currentBannerIndex(int index) {
//     _currentBannerIndex = index;
//     emit(ChangeBannerIndexState());
//   }

//   int _selectedSegmentedIndex = 0;

//   int get selectedSegmentedIndex => _selectedSegmentedIndex;

//   set setSegmentedIndex(int index) {
//     _selectedSegmentedIndex = index;
//     emit(HomeSelectedIndexUpdatedState());
//   }

//   final List<Widget> pages = const [
//     HomeScreen(),
//     NotificationsScreen(),
//     ProfileScreen(),
//     SettingsScreen(),
//   ];

//   // final List<String> titles = [
//   //   'Home',
//   //   'notification',
//   //   'Profile',
//   //   'setting',
//   // ];

//   //login
//   final Map<String, bool> _passwordVisibility = {
//     'login': false,
//     'register': false,
//   };

//   Map<String, bool> get passwordVisibility => _passwordVisibility;

//   void togglePasswordVisibility(String key) {
//     _passwordVisibility[key] = !_passwordVisibility[key]!;
//     emit(HomeShowPasswordUpdatedState());
//   }

//   final TextEditingController loginEmailController = TextEditingController();
//   final TextEditingController loginPasswordController = TextEditingController();
//   final TextEditingController forgotEmailController = TextEditingController();

//   final UserRepository userRepo = UserRepository();
//   StreamSubscription? _userSubscription;

//   Future<void> login() async {
//     emit(HomeLoginLoadingState());
//     final email = loginEmailController.text.trim();
//     final password = loginPasswordController.text.trim();
//     try {
//       final user = await _signInUser(email, password);
//       // NEW: Update FCM Token on Login
//       final fcmToken = await FirebaseMessaging.instance.getToken();
//       await userRepo.updateUserField(user.uid, {'fcmToken': fcmToken});

//       // NEW: Send Login Alert Notification
//       await _sendLoginAlert(user);

//       listenToUserData(); // Start listening to user data changes

//       final refreshedUser = await _reloadUser(user);
//       emit(HomeLoginSuccessState(refreshedUser));
//     } on FirebaseAuthException catch (e) {
//       emit(HomeLoginErrorState(_mapAuthError(e)));
//     } catch (e) {
//       debugPrint('Login error: $e');
//       emit(HomeLoginErrorState("Something went wrong. Please try again."));
//     }
//   }

//   Future<void> _sendLoginAlert(User user) async {
//     try {
//       final deviceInfo = DeviceInfoPlugin();
//       Map<String, dynamic> deviceData = {};

//       if (Platform.isAndroid) {
//         final androidInfo = await deviceInfo.androidInfo;
//         deviceData = {
//           'brand': androidInfo.brand,
//           'model': androidInfo.model,
//           'device': androidInfo.device,
//           'version': androidInfo.version.release,
//           'platform': 'Android',
//         };
//       } else if (Platform.isIOS) {
//         final iosInfo = await deviceInfo.iosInfo;
//         deviceData = {
//           'name': iosInfo.name,
//           'model': iosInfo.model,
//           'systemName': iosInfo.systemName,
//           'systemVersion': iosInfo.systemVersion,
//           'platform': 'iOS',
//         };
//       }

//       // Get current user data to ensure we have name/photo (might be null if just signed in, so we fetch)
//       final userData = await userRepo.getUser(user.uid);
//       if (userData == null) return;

//       await notificationRepo.sendNotification(
//         senderId: user.uid, // System or self
//         senderName: "Security Alert", // Or App Name
//         senderProfilePic: "", // Optional: App Logo
//         receiverId: user.uid,
//         type: 'login_alert',
//         text:
//             'New login detected from ${deviceData['model'] ?? 'Unknown Device'}',
//         deviceInfo: deviceData,
//       );
//     } catch (e) {
//       debugPrint("Error sending login alert: $e");
//     }
//   }

//   Future<void> sendPasswordResetEmail() async {
//     final email = loginEmailController.text.trim();
//     if (email.isEmpty || !email.contains('@')) {
//       emit(
//         HomeForgotPasswordErrorState(
//           appTranslation().get('please_enter_email'),
//         ),
//       );
//       return;
//     }

//     emit(HomeForgotPasswordLoadingState());
//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
//       emit(
//         HomeForgotPasswordSuccessState(
//           appTranslation().get('password_reset_email_sent'),
//         ),
//       );
//     } on FirebaseAuthException catch (e) {
//       emit(
//         HomeForgotPasswordErrorState(
//           e.message ?? appTranslation().get('something_went_wrong'),
//         ),
//       );
//     } catch (e) {
//       emit(
//         HomeForgotPasswordErrorState(
//           appTranslation().get('something_went_wrong'),
//         ),
//       );
//     }
//   }

//   /// ------------------ HELPERS ------------------
//   Future<User> _signInUser(String email, String password) async {
//     final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//     return credential.user!;
//   }

//   Future<User> _registerUser(String email, String password) async {
//     final res = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//     return res.user!;
//   }

//   Future<User> _reloadUser(User user) async {
//     await user.reload();
//     return FirebaseAuth.instance.currentUser!;
//   }

//   Future<void> _createUserInFirestore(User user) async {
//     String photoUrl = "";

//     if (registerProfileImage != null) {
//       photoUrl = await uploadImageToCloudinary(registerProfileImage!);
//     }
//     final userModel = UserModel(
//       uid: user.uid,
//       email: user.email!,
//       username: registerNameController.text.trim(),
//       photoUrl: photoUrl,
//       coverUrl: "",
//       bio: "Hello i'm using skilltok",
//       createdAt: DateTime.now(),
//     );

//     await userRepo.createUser(userModel);
//   }

//   File? registerProfileImage;
//   final TextEditingController registerNameController = TextEditingController();
//   final TextEditingController registerEmailController = TextEditingController();
//   final TextEditingController registerPasswordController =
//       TextEditingController();

//   Future<void> pickRegisterProfileImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       registerProfileImage = File(pickedFile.path);
//       emit(HomeProfileImagePickedState());
//     }
//   }

//   Future<String> uploadImageToCloudinary(File imageFile) async {
//     const cloudName = 'da1ytk4sk';
//     const uploadPreset = 'skilltok';
//     final uri = Uri.parse(
//       'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
//     );
//     final request = http.MultipartRequest('POST', uri)
//       ..fields['upload_preset'] = uploadPreset
//       ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
//     final response = await request.send();
//     final res = await http.Response.fromStream(response);
//     if (res.statusCode == 200) {
//       final data = jsonDecode(res.body);
//       return data['secure_url'];
//     } else {
//       debugPrint(res.body);
//       throw Exception('Cloudinary upload failed');
//     }
//   }

//   final List<VideoPlayerController> _activeVideos = [];

//   void registerVideoController(VideoPlayerController controller) {
//     _activeVideos.add(controller);
//   }

//   void unregisterVideoController(VideoPlayerController controller) {
//     _activeVideos.remove(controller);
//   }

//   bool _userPaused = false;

//   bool get userPaused => _userPaused;
//   void togglePlayPause(VideoPlayerController controller) {
//     if (controller.value.isPlaying) {
//       controller.pause();
//       _userPaused = true; // يمنع التشغيل التلقائي فقط
//     } else {
//       controller.play(); // شغل الفيديو مباشرة مهما كان _userPaused
//       _userPaused = false; // السماح للتشغيل التلقائي بعد كده
//     }
//   }

//   void playOnly(VideoPlayerController activeController) {
//     if (_userPaused) return; // يمنع التشغيل التلقائي فقط

//     for (final controller in _activeVideos) {
//       if (controller == activeController) {
//         if (!controller.value.isPlaying) {
//           controller
//             ..setLooping(true)
//             ..play();
//         }
//       } else {
//         controller.pause();
//       }
//     }
//   }

//   // دالة الطباعة نفسها

//   void pauseAllVideos() {
//     for (final controller in _activeVideos) {
//       if (controller.value.isPlaying) {
//         controller.pause();
//       }
//     }
//   }

//   Future<String> uploadVideoToCloudinary(File videoFile) async {
//     const cloudName = 'da1ytk4sk';
//     const uploadPreset = 'skilltok';

//     final uri = Uri.parse(
//       'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
//     );

//     final request = http.MultipartRequest('POST', uri)
//       ..fields['upload_preset'] = uploadPreset
//       ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

//     final response = await request.send();
//     final res = await http.Response.fromStream(response);

//     if (res.statusCode == 200) {
//       final data = jsonDecode(res.body);
//       return data['secure_url'];
//     } else {
//       debugPrint(res.body);
//       throw Exception('Cloudinary video upload failed');
//     }
//   }

//   Future<void> register() async {
//     emit(HomeRegisterLoadingState());

//     final email = registerEmailController.text.trim();
//     final password = registerPasswordController.text.trim();

//     try {
//       final user = await _registerUser(email, password);
//       await _createUserInFirestore(user);

//       emit(HomeRegisterSuccessState(user));
//       registerProfileImage = null;
//       registerNameController.clear();
//       registerEmailController.clear();
//       registerPasswordController.clear();
//     } on FirebaseAuthException catch (e) {
//       emit(HomeRegisterErrorState(_mapAuthError(e)));
//     } catch (e) {
//       emit(HomeRegisterErrorState("Something went wrong. Please try again."));
//     }
//   }

//   String _mapAuthError(FirebaseAuthException e) {
//     debugPrint("Unhandled FirebaseAuthException: ${e.code}");
//     switch (e.code) {
//       case 'user-not-found':
//         return 'No account found with this email.';
//       case 'wrong-password':
//         return 'Incorrect password.';
//       case 'email-already-in-use':
//         return 'This email is already registered.';
//       case 'weak-password':
//         return 'Password should be at least 8 characters.';
//       case 'invalid-email':
//         return 'Invalid email address.';
//       case 'invalid-credential':
//         return 'Email or password is incorrect.';

//       default:
//         return 'Authentication failed. Please try again.';
//     }
//   }

//   //getDataUser
//   UserModel? userModel;

//   Future<void> cacheUser(UserModel? model) async {
//     final json = jsonEncode(model!.toMap());
//     await CacheHelper.saveData(key: 'userModel', value: json);
//   }

//   UserModel? getCachedUser() {
//     final json = CacheHelper.getData(key: 'userModel');
//     if (json == null) return null;
//     return UserModel.fromMap(
//       jsonDecode(json),
//       FirebaseAuth.instance.currentUser!.uid,
//     );
//   }

//   void listenToUserData() {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;

//     _userSubscription?.cancel(); // Cancel any existing subscription

//     _userSubscription = userRepo
//         .getUserStream(uid)
//         .listen(
//           (user) async {
//             if (user == null) return; // Should not happen if user is logged in

//             final currentToken = await FirebaseMessaging.instance.getToken();

//             if (user.fcmToken != currentToken) {
//               // Another device has logged in, log this one out
//               logout(navigatorKey.currentContext!);
//               return;
//             }

//             userModel = user;
//             await cacheUser(user);
//             emit(HomeGetUserSuccessState());
//           },
//           onError: (dynamic error) {
//             debugPrint("Error in user stream: $error");
//             emit(HomeGetUserErrorState(error.toString()));
//           },
//         );
//   }

//   Future<void> getUserData() async {
//     final cached = getCachedUser();
//     if (cached != null) {
//       userModel = cached;
//       emit(HomeGetUserSuccessState());
//     }
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     try {
//       final fresh = await userRepo.getUser(uid);

//       // Update FCM Token
//       final token = await FirebaseMessaging.instance.getToken();
//       if (token != null && fresh!.fcmToken != token) {
//         final updatedUser = fresh.copyWith(fcmToken: token);
//         await userRepo.updateUser(updatedUser);
//         userModel = updatedUser;
//         await cacheUser(updatedUser);
//       } else {
//         userModel = fresh;
//         await cacheUser(fresh);
//       }

//       emit(HomeGetUserSuccessState());
//     } catch (e) {
//       debugPrint("Error fetching user data: $e");
//       if (cached == null) {
//         emit(HomeGetUserErrorState(e.toString()));
//       }
//     }
//   }

//   // Posts
//   final postTextController = TextEditingController();
//   List<PostModel> posts = [];
//   File? postVideo;

//   Future<void> pickPostVideo() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       postVideo = File(pickedFile.path);
//       emit(HomePickPostVideoState()); // يفضل تعمل state جديدة
//     }
//   }

//   void removePostVideo() {
//     postVideo = null;
//     emit(HomeRemovePostVideoState());
//   }

//   Future<void> addPost(String text) async {
//     if (userModel == null) {
//       emit(HomeAddPostErrorState("User not logged in"));
//       return;
//     }
//     emit(HomeAddPostLoadingState());
//     try {
//       String? imageUrl;
//       if (postVideo != null) {
//         imageUrl = await uploadVideoToCloudinary(postVideo!);
//       }

//       await postRepo.addPost(
//         userId: userModel!.uid!,
//         username: userModel!.username!,
//         userProfilePic: userModel!.photoUrl!,
//         text: text,
//         imageUrl: imageUrl,
//       );

//       // Reset state after successful post
//       postVideo = null;
//       postTextController.clear();

//       emit(HomeAddPostSuccessState());
//     } catch (e) {
//       emit(HomeAddPostErrorState(e.toString()));
//     }
//   }

//   void getPosts() {
//     emit(HomeGetPostsLoadingState());
//     try {
//       postRepo.getPosts().listen((posts) {
//         this.posts = posts;
//         emit(HomeGetPostsSuccessState(posts));
//       });
//     } catch (e) {
//       emit(HomeGetPostsErrorState(e.toString()));
//     }
//   }

//   Stream<PostModel> getPostStream(String postId) {
//     return postRepo.getPostStream(postId);
//   }

//   Future<void> togglePostLike(PostModel post) async {
//     if (userModel == null) return;
//     final isLiked = post.likes.contains(userModel!.uid);

//     try {
//       await postRepo.toggleLike(
//         postId: post.postId,
//         currentUserId: userModel!.uid!,
//         likes: post.likes,
//       );
//       if (!isLiked && post.userId != userModel!.uid) {
//         await NotificationService.send(
//           receiverId: post.userId,
//           title: userModel!.username!,
//           contents: {"en": "liked your post ❤️", "ar": "أعجب بمنشورك ❤️"},
//           data: {
//             "type": "like",
//             "postId": post.postId,
//             "senderId": userModel!.uid!,
//           },
//         );
//         await notificationRepo.sendNotification(
//           senderId: userModel!.uid!,
//           senderName: userModel!.username!,
//           senderProfilePic: userModel!.photoUrl!,
//           receiverId: post.userId,
//           type: 'like',
//           postId: post.postId,
//           text: 'liked your post ❤️',
//         );
//       }
//       emit(HomeLikePostSuccessState());
//     } catch (e) {
//       emit(HomeLikePostErrorState(e.toString()));
//     }
//   }

//   final commentController = TextEditingController();

//   Future<void> addComment(String postId, String postOwnerId) async {
//     if (userModel == null) {
//       emit(HomeAddCommentErrorState("User not logged in"));
//       return;
//     }
//     emit(HomeAddCommentLoadingState());
//     try {
//       await postRepo.addComment(
//         postId: postId,
//         userId: userModel!.uid!,
//         username: userModel!.username!,
//         userProfilePic: userModel!.photoUrl!,
//         text: commentController.text.trim(),
//       );
//       if (postOwnerId != userModel!.uid) {
//         await NotificationService.send(
//           receiverId: postOwnerId,
//           title: userModel!.username!,
//           contents: {
//             "en": "commented on your post 💬",
//             "ar": "علّق على منشورك 💬",
//           },
//           data: {
//             "type": "comment",
//             "postId": postId,
//             "senderId": userModel!.uid!,
//           },
//         );
//         await notificationRepo.sendNotification(
//           senderId: userModel!.uid!,
//           senderName: userModel!.username!,
//           senderProfilePic: userModel!.photoUrl!,
//           receiverId: postOwnerId,
//           type: 'comment',
//           postId: postId,
//           text: commentController.text.trim(),
//         );
//       }
//       commentController.clear();
//       emit(HomeAddCommentSuccessState());
//     } catch (e) {
//       emit(HomeAddCommentErrorState(e.toString()));
//     }
//   }

//   Future<void> deleteComment(String postId, CommentModel comment) async {
//     emit(HomeDeleteCommentLoadingState());
//     try {
//       await postRepo.deleteComment(postId: postId, comment: comment);
//       emit(HomeDeleteCommentSuccessState());
//     } catch (e) {
//       emit(HomeDeleteCommentErrorState(e.toString()));
//     }
//   }

//   Future<void> followUser(String userIdToFollow) async {
//     if (userModel == null) return;
//     emit(HomeFollowUserLoadingState());
//     try {
//       await userRepo.followUser(userModel!.uid!, userIdToFollow);
//       await NotificationService.send(
//         receiverId: userIdToFollow,
//         title: userModel!.username!,
//         contents: {"en": "started following you 👤", "ar": "بدأ بمتابعتك 👤"},
//         data: {"type": "follow", "senderId": userModel!.uid!},
//       );
//       await notificationRepo.sendNotification(
//         senderId: userModel!.uid!,
//         senderName: userModel!.username!,
//         senderProfilePic: userModel!.photoUrl!,
//         receiverId: userIdToFollow,
//         type: 'follow',
//         text: 'started following you',
//       );
//       await getUserData();
//       emit(HomeFollowUserSuccessState());
//     } catch (e) {
//       debugPrint("Follow error: $e");
//       emit(HomeFollowUserErrorState(e.toString()));
//     }
//   }

//   Future<void> unfollowUser(String userIdToUnfollow) async {
//     if (userModel == null) return;
//     emit(HomeUnfollowUserLoadingState());
//     try {
//       await userRepo.unfollowUser(userModel!.uid!, userIdToUnfollow);
//       await getUserData();
//       emit(HomeUnfollowUserSuccessState());
//     } catch (e) {
//       debugPrint("Unfollow error: $e");
//       emit(HomeUnfollowUserErrorState(e.toString()));
//     }
//   }

//   Future<void> deletePost(String postId) async {
//     emit(HomeDeletePostLoadingState());
//     try {
//       await postRepo.deletePost(postId);
//       posts.removeWhere((post) => post.postId == postId);
//       emit(HomeDeletePostSuccessState());
//     } catch (e) {
//       emit(HomeDeletePostErrorState(e.toString()));
//     }
//   }

//   void logout(BuildContext context) {
//     _userSubscription?.cancel(); // Cancel subscription before logging out
//     FirebaseAuth.instance.signOut().then((value) {
//       if (context.mounted) {
//         context.pushReplacement<Object>(Routes.login);
//         currentIndex = 0;
//       }
//     });
//   }

//   //profile
//   List<PostModel> userPosts = [];

//   void getMyPosts() {
//     emit(HomeGetMyPostsLoadingState());
//     try {
//       postRepo.getUserPosts(userModel!.uid!).listen((posts) {
//         userPosts = posts;
//         emit(HomeGetMyPostsSuccessState(posts));
//       });
//     } catch (e) {
//       emit(HomeGetMyPostsErrorState(e.toString()));
//     }
//   }

//   //editProile
//   File? profileImage;
//   File? coverImage;

//   final usernameController = TextEditingController();
//   final bioController = TextEditingController();

//   Future<void> pickProfileImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       profileImage = File(pickedFile.path);
//       emit(HomeProfileImagePickedState());
//     }
//   }

//   Future<void> pickCoverImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       coverImage = File(pickedFile.path);
//       emit(HomeCoverImagePickedState());
//     }
//   }

//   Future<void> updateProfile() async {
//     if (userModel == null) return;

//     emit(HomeUpdateProfileLoadingState());

//     try {
//       String profileUrl = userModel!.photoUrl!;
//       String coverUrl = userModel!.coverUrl!;

//       if (profileImage != null) {
//         profileUrl = await uploadImageToCloudinary(profileImage!);
//       }

//       if (coverImage != null) {
//         coverUrl = await uploadImageToCloudinary(coverImage!);
//       }

//       final updatedUser = userModel!.copyWith(
//         username: usernameController.text.trim(),
//         bio: bioController.text.trim(),
//         photoUrl: profileUrl,
//         coverUrl: coverUrl,
//       );

//       await userRepo.updateUser(updatedUser);
//       await postRepo.updateUserPosts(
//         userId: updatedUser.uid!,
//         username: updatedUser.username!,
//         userProfilePic: updatedUser.photoUrl!,
//       );
//       userModel = updatedUser;

//       profileImage = null;
//       coverImage = null;

//       emit(HomeUpdateProfileSuccessState());
//     } catch (e) {
//       emit(HomeUpdateProfileErrorState(e.toString()));
//     }
//   }

//   //editPost
//   final TextEditingController editPostController = TextEditingController();
//   File? editpostVideo;
//   String? editpostVideoUrl;

//   void initEditPost(PostModel post) {
//     editPostController.text = post.text ?? '';
//     editpostVideo = null;
//     editpostVideoUrl = post.imageUrl;
//   }

//   Future<void> updatePost({required String postId}) async {
//     emit(HomeUpdatePostLoadingState());
//     try {
//       String? imageUrl;
//       final oldPost = posts.firstWhere((p) => p.postId == postId);
//       if (editpostVideo != null) {
//         imageUrl = await uploadVideoToCloudinary(editpostVideo!);
//       } else if (editpostVideoUrl == null) {
//         imageUrl = null;
//       } else {
//         imageUrl = oldPost.imageUrl;
//       }
//       await postRepo.updatePost(
//         postId: postId,
//         text: editPostController.text.trim(),
//         imageUrl: imageUrl,
//       );
//       final index = posts.indexWhere((p) => p.postId == postId);
//       if (index != -1) {
//         posts[index] = posts[index].copyWith(
//           text: editPostController.text.trim(),
//           imageUrl: imageUrl,
//         );
//       }
//       editPostController.clear();
//       editpostVideo = null;
//       editpostVideoUrl = null;
//       emit(HomeUpdatePostSuccessState());
//     } catch (e) {
//       emit(HomeUpdatePostErrorState(e.toString()));
//     }
//   }

//   void removeEditpostVideo() {
//     homeCubit.editpostVideo = null;
//     homeCubit.editpostVideoUrl = null;
//     emit(HomeRemoveEditpostVideoState());
//   }

//   List<NotificationModel> notifications = [];
//   int unreadNotificationsCount = 0;

//   void getNotifications() {
//     if (userModel == null) return;
//     emit(HomeGetNotificationsLoadingState());
//     try {
//       notificationRepo.getUserNotifications(userModel!.uid!).listen((event) {
//         notifications = event;
//         unreadNotificationsCount = notifications.where((n) => !n.isRead).length;
//         emit(HomeGetNotificationsSuccessState(event));
//       });
//     } catch (e) {
//       emit(HomeGetNotificationsErrorState(e.toString()));
//     }
//   }

//   Future<void> markNotificationAsRead(String notificationId) async {
//     try {
//       await notificationRepo.markNotificationAsRead(notificationId);
//     } catch (e) {
//       debugPrint("Error marking notification as read: $e");
//     }
//   }
// }
