import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skilltok/core/utils/constants/routes.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:skilltok/core/utils/constants/constants.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _routeUser();
    });
  }

  Future<void> _routeUser() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null) {
      context.pushReplacement<Object>(Routes.login);
      return;
    }

    // 👇 دخول سريع
    if (mounted) {
      userCubit.listenToUserData();
      context.pushReplacement<Object>(Routes.buttomnav);
    }

    // 👇 تحقق في الخلفية
    try {
      await user.reload();
    } catch (_) {
      await auth.signOut();
      if (mounted) {
        context.pushReplacement<Object>(Routes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
