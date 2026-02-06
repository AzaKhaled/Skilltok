import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/cubits/bottom_nav/bottom_nav_cubit.dart';
import 'package:skilltok/core/cubits/notification/notification_cubit.dart';
import 'package:skilltok/core/cubits/language/language_cubit.dart';
import 'package:skilltok/core/cubits/chat/chat_cubit.dart';
import 'package:skilltok/feuters/home/presentation/screen/buttom_items.dart';

class ButtomNav extends StatefulWidget {
  const ButtomNav({super.key});

  @override
  State<ButtomNav> createState() => _ButtomNavState();
}

class _ButtomNavState extends State<ButtomNav> {
  @override
  void initState() {
    super.initState();
    // Ensure we fetch chats to show badges
    if (userCubit.userModel != null) {
      chatCubit.getChats(userCubit.userModel!.uid!);
    } else {
      // Just in case user loads slower, listen to user state?
      // For now, assuming user is mostly loaded or will be loaded by HomeScreen logic which also runs.
      // Ideally, we start this in main or a startup logic.
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavCubit, BottomNavStates>(
      builder: (context, navState) {
        return BlocBuilder<NotificationCubit, NotificationStates>(
          builder: (context, notifState) {
            return BlocBuilder<ChatCubit, ChatStates>(
              builder: (context, chatState) {
                int chatUnreadCount = 0;
                final myId = userCubit.userModel?.uid;
                if (myId != null) {
                  for (var chat in chatCubit.chats) {
                    final unreadCounts =
                        chat['unreadCounts'] as Map<String, dynamic>?;
                    if (unreadCounts != null &&
                        unreadCounts.containsKey(myId)) {
                      chatUnreadCount += (unreadCounts[myId] as int);
                    }
                  }
                }

                return BlocBuilder<LanguageCubit, LanguageStates>(
                  builder: (context, langState) {
                    return Scaffold(
                      body: bottomNavCubit.pages[bottomNavCubit.currentIndex],
                      bottomNavigationBar: BottomNavigationBar(
                        type: BottomNavigationBarType.fixed,
                        showUnselectedLabels: false,
                        showSelectedLabels: false,
                        elevation: 0,
                        currentIndex: bottomNavCubit.currentIndex,
                        onTap: (index) {
                          bottomNavCubit.currentIndex = index;
                        },
                        items: [
                          BottomNavigationBarItem(
                            icon: BottomNavItemWidget(
                              icon: Icons.home_outlined,
                              activeIcon: Icons.home,
                              label: appTranslation().get('home'),
                              isActive: bottomNavCubit.currentIndex == 0,
                            ),
                            activeIcon: BottomNavItemWidget(
                              icon: Icons.home_outlined,
                              activeIcon: Icons.home,
                              label: appTranslation().get('home'),
                              isActive: true,
                            ),
                            label: '',
                          ),
                          BottomNavigationBarItem(
                            icon: BottomNavItemWidget(
                              icon: Icons.chat_bubble_outline,
                              activeIcon: Icons.chat_bubble,
                              label: appTranslation().get('chats'),
                              isActive: bottomNavCubit.currentIndex == 1,
                              badgeCount: chatUnreadCount,
                            ),
                            activeIcon: BottomNavItemWidget(
                              icon: Icons.chat_bubble_outline,
                              activeIcon: Icons.chat_bubble,
                              label: appTranslation().get('chats'),
                              isActive: true,
                              badgeCount: chatUnreadCount,
                            ),
                            label: '',
                          ),
                          BottomNavigationBarItem(
                            icon: BottomNavItemWidget(
                              icon: Icons.add_circle_outline,
                              activeIcon: Icons.add_circle,
                              label: appTranslation().get('add_post'),
                              isActive: bottomNavCubit.currentIndex == 2,
                            ),
                            activeIcon: BottomNavItemWidget(
                              icon: Icons.add_circle_outline,
                              activeIcon: Icons.add_circle,
                              label: appTranslation().get('add_post'),
                              isActive: true,
                            ),
                            label: '',
                          ),
                          BottomNavigationBarItem(
                            icon: BottomNavItemWidget(
                              icon: Icons.notifications_outlined,
                              activeIcon: Icons.notifications,
                              label: appTranslation().get('notifications'),
                              isActive: bottomNavCubit.currentIndex == 3,
                              badgeCount:
                                  notificationCubit.unreadNotificationsCount,
                            ),
                            activeIcon: BottomNavItemWidget(
                              icon: Icons.notifications_outlined,
                              activeIcon: Icons.notifications,
                              label: appTranslation().get('notifications'),
                              isActive: true,
                              badgeCount:
                                  notificationCubit.unreadNotificationsCount,
                            ),
                            label: '',
                          ),
                          BottomNavigationBarItem(
                            icon: BottomNavItemWidget(
                              icon: Icons.person_outline,
                              activeIcon: Icons.person,
                              label: appTranslation().get('profile'),
                              isActive: bottomNavCubit.currentIndex == 4,
                            ),
                            activeIcon: BottomNavItemWidget(
                              icon: Icons.person_outline,
                              activeIcon: Icons.person,
                              label: appTranslation().get('profile'),
                              isActive: true,
                            ),
                            label: '',
                          ),
                          // Settings hidden
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
