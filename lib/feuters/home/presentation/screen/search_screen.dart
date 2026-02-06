import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/cubits/user/user_cubit.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:skilltok/core/utils/constants/routes.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: appTranslation().get('find_friends'),
            border: InputBorder.none,
            hintStyle: TextStyle(color: Theme.of(context).hintColor),
          ),
          onChanged: (value) {
            userCubit.searchUsers(value);
          },
        ),
        elevation: 1,
      ),
      body: BlocBuilder<UserCubit, UserStates>(
        builder: (context, state) {
          final cubit = userCubit;
          if (state is UserSearchLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cubit.searchResults.isEmpty &&
              _searchController.text.isNotEmpty) {
            return const Center(child: Text("No users found"));
          }

          return ListView.builder(
            itemCount: cubit.searchResults.length,
            itemBuilder: (context, index) {
              final user = cubit.searchResults[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      user.photoUrl != null && user.photoUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null || user.photoUrl!.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(user.username ?? 'Unknown'),
                subtitle: Text(user.bio ?? ''),
                onTap: () {
                  context.push(Routes.profile, arguments: user.uid);
                },
              );
            },
          );
        },
      ),
    );
  }
}
