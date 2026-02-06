# Refactoring Complete: Setup Instructions

I have split the massive `HomeCubit` into 10 specialized Cubits:

1.  **ThemeCubit**: Manages light/dark mode.
2.  **LanguageCubit**: Manages translations and localization.
3.  **BottomNavCubit**: Handles bottom navigation, banner index, and segmented index.
4.  **AuthCubit**: Login, register, logout, and password visibility.
5.  **UserCubit**: User data fetching, stream listening, and follow/unfollow logic.
6.  **PostCubit**: Fetching, adding, updating, deleting posts and likes.
7.  **CommentCubit**: Adding and deleting comments.
8.  **ProfileCubit**: Picking images, updating profile, and fetching my posts.
9.  **NotificationCubit**: Notifications fetch and mark as read.
10. **VideoCubit**: Registration and playback control for video players.

---

### 1. Connecting Cubits to the App (Main)

Modify your `main.dart` to use `MultiBlocProvider`:

```dart
// main.dart
import 'package:skilltok/core/utils/bloc_providers.dart';

void main() async {
  // ... initialization code
  runApp(
    MultiBlocProvider(
      providers: getProviders(), // Uses the helper created in core/utils
      child: MyApp(),
    ),
  );
}
```

---

### 2. UI Usage Examples

#### Example: Using ThemeCubit and LanguageCubit
```dart
BlocBuilder<ThemeCubit, ThemeStates>(
  builder: (context, state) {
    final isDark = ThemeCubit.get(context).isDarkMode;
    return ThemeProvider(
      isDark: isDark,
      child: ...,
    );
  },
);
```

#### Example: Login Flow with AuthCubit and UserCubit
```dart
BlocListener<AuthCubit, AuthStates>(
  listener: (context, state) {
    if (state is AuthLoginSuccessState) {
      // Start listening to user data as soon as login succeeds
      UserCubit.get(context).listenToUserData();
      context.pushReplacement(Routes.home);
    }
  },
  child: BlocBuilder<AuthCubit, AuthStates>(
    builder: (context, state) {
      final auth = AuthCubit.get(context);
      return ElevatedButton(
        onPressed: state is AuthLoginLoadingState ? null : () => auth.login(),
        child: Text('Login'),
      );
    },
  ),
);
```

#### Example: Posts and Video Control
```dart
BlocBuilder<PostCubit, PostStates>(
  builder: (context, state) {
    final posts = PostCubit.get(context).posts;
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostWidget(
          post: posts[index],
          onPlay: () => VideoCubit.get(context).playOnly(controller),
        );
      },
    );
  },
);
```

---

### Important Notes
- **Parameter Passing**: Since `UserCubit` holds the logged-in user state, some methods in `PostCubit` or `CommentCubit` (like `addPost` or `addComment`) now take `UserModel` as a parameter to keep them independent.
- **NavigatorKey**: I used `navigatorKey.currentContext` inside `UserCubit`'s `listenToUserData` for forced logout when the FCM token changes, ensuring the logic remains identical to the original code.
- **Auto-getPosts**: `PostCubit` is initialized with `..getPosts()` in the provider list, but you can change this initialization as needed.
