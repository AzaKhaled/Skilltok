import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/feuters/home/presentation/screen/home_screen.dart';
import 'package:skilltok/feuters/home/presentation/widgets/notifications/notifications_screen.dart';
import 'package:skilltok/feuters/home/presentation/widgets/add_post_screen.dart';
import 'package:skilltok/feuters/profile/presentation/screen/profile_screen.dart';
import 'package:skilltok/feuters/chat/presentation/screen/chats_screen.dart';

part 'bottom_nav_state.dart';

class BottomNavCubit extends Cubit<BottomNavStates> {
  BottomNavCubit() : super(BottomNavInitialState());

  // ignore: strict_top_level_inference
  static BottomNavCubit get(context) => BlocProvider.of(context);

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    // pauseAllVideos(); // Handled by BlocListener in UI
    emit(BottomNavChangeState());
  }

  int _currentBannerIndex = 0;

  int get currentBannerIndex => _currentBannerIndex;

  set currentBannerIndex(int index) {
    _currentBannerIndex = index;
    emit(BottomNavBannerChangeState());
  }

  int _selectedSegmentedIndex = 0;

  int get selectedSegmentedIndex => _selectedSegmentedIndex;

  set setSegmentedIndex(int index) {
    _selectedSegmentedIndex = index;
    emit(BottomNavSegmentedIndexChangedState());
  }

  final List<Widget> pages = const [
    HomeScreen(),
    ChatsScreen(),
    AddPostScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];
}
