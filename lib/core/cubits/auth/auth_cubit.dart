import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:skilltok/core/cubits/bottom_nav/bottom_nav_cubit.dart';
import 'package:skilltok/core/models/user_model.dart';
import 'package:skilltok/core/network/notification_repository.dart';
import 'package:skilltok/core/network/user_repository.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/routes.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';

part 'auth_state.dart';
// HomeCubit get homeCubit => HomeCubit.get(navigatorKey.currentContext!);

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(AuthInitialState());

  // ignore: strict_top_level_inference
  static AuthCubit get(context) => BlocProvider.of(context);

  final UserRepository userRepo = UserRepository();
  final NotificationRepository notificationRepo = NotificationRepository();

  //login
  final Map<String, bool> _passwordVisibility = {
    'login': false,
    'register': false,
  };

  Map<String, bool> get passwordVisibility => _passwordVisibility;

  void togglePasswordVisibility(String key) {
    _passwordVisibility[key] = !_passwordVisibility[key]!;
    emit(AuthShowPasswordUpdatedState());
  }

  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController forgotEmailController = TextEditingController();

  StreamSubscription? _userSubscription;

  Future<void> login() async {
    emit(AuthLoginLoadingState());
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text.trim();
    try {
      final user = await _signInUser(email, password);
      // NEW: Update FCM Token on Login
      final fcmToken = await FirebaseMessaging.instance.getToken();
      await userRepo.updateUserField(user.uid, {'fcmToken': fcmToken});

      // NEW: Send Login Alert Notification
      await _sendLoginAlert(user);

      final refreshedUser = await _reloadUser(user);
      emit(AuthLoginSuccessState(refreshedUser));
    } on FirebaseAuthException catch (e) {
      emit(AuthLoginErrorState(_mapAuthError(e)));
    } catch (e) {
      debugPrint('Login error: $e');
      emit(AuthLoginErrorState("Something went wrong. Please try again."));
    }
  }

  Future<void> _sendLoginAlert(User user) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic> deviceData = {};

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'device': androidInfo.device,
          'version': androidInfo.version.release,
          'platform': 'Android',
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          'name': iosInfo.name,
          'model': iosInfo.model,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'platform': 'iOS',
        };
      }

      // Get current user data to ensure we have name/photo (might be null if just signed in, so we fetch)
      final userData = await userRepo.getUser(user.uid);
      if (userData == null) return;

      await notificationRepo.sendNotification(
        senderId: user.uid, // System or self
        senderName: "Security Alert", // Or App Name
        senderProfilePic: "", // Optional: App Logo
        receiverId: user.uid,
        type: 'login_alert',
        text:
            'New login detected from ${deviceData['model'] ?? 'Unknown Device'}',
        deviceInfo: deviceData,
      );
    } catch (e) {
      debugPrint("Error sending login alert: $e");
    }
  }

  Future<void> sendPasswordResetEmail() async {
    final email = loginEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      emit(
        AuthForgotPasswordErrorState(
          appTranslation().get('please_enter_email'),
        ),
      );
      return;
    }

    emit(AuthForgotPasswordLoadingState());
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      emit(
        AuthForgotPasswordSuccessState(
          appTranslation().get('password_reset_email_sent'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(
        AuthForgotPasswordErrorState(
          e.message ?? appTranslation().get('something_went_wrong'),
        ),
      );
    } catch (e) {
      emit(
        AuthForgotPasswordErrorState(
          appTranslation().get('something_went_wrong'),
        ),
      );
    }
  }

  /// ------------------ HELPERS ------------------
  Future<User> _signInUser(String email, String password) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<User> _registerUser(String email, String password) async {
    final res = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return res.user!;
  }

  Future<User> _reloadUser(User user) async {
    await user.reload();
    return FirebaseAuth.instance.currentUser!;
  }

  Future<void> _createUserInFirestore(User user) async {
    String photoUrl = "";

    if (registerProfileImage != null) {
      photoUrl = await uploadImageToCloudinary(registerProfileImage!);
    }
    final userModel = UserModel(
      uid: user.uid,
      email: user.email!,
      username: registerNameController.text.trim(),
      photoUrl: photoUrl,
      bio: "Hello i'm using skilltok",
    );

    await userRepo.createUser(userModel);
  }

  File? registerProfileImage;
  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController =
      TextEditingController();

  Future<void> pickRegisterProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      registerProfileImage = File(pickedFile.path);
      emit(AuthProfileImagePickedState());
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

  Future<void> register() async {
    emit(AuthRegisterLoadingState());

    final email = registerEmailController.text.trim();
    final password = registerPasswordController.text.trim();

    try {
      final user = await _registerUser(email, password);
      await _createUserInFirestore(user);

      emit(AuthRegisterSuccessState(user));
      registerProfileImage = null;
      registerNameController.clear();
      registerEmailController.clear();
      registerPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      emit(AuthRegisterErrorState(_mapAuthError(e)));
    } catch (e) {
      emit(AuthRegisterErrorState("Something went wrong. Please try again."));
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    debugPrint("Unhandled FirebaseAuthException: ${e.code}");
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password should be at least 8 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'invalid-credential':
        return 'Email or password is incorrect.';

      default:
        return 'Authentication failed. Please try again.';
    }
  }

  void logout(BuildContext context) {
    _userSubscription?.cancel(); // Cancel subscription before logging out
    FirebaseAuth.instance.signOut().then((value) {
      if (context.mounted) {
        context.pushReplacement<Object>(Routes.login);
        BottomNavCubit.get(context).currentIndex =
            0; // Updated to use BottomNavCubit
      }
    });
  }
}
