import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skilltok/core/cubits/user/user_cubit.dart';
import 'package:skilltok/core/models/user_model.dart';
import 'package:skilltok/core/network/user_repository.dart';
import 'package:skilltok/core/theme/colors.dart';
import 'package:skilltok/core/utils/constants/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skilltok/core/utils/extensions/context_extension.dart';
import 'package:skilltok/core/utils/constants/routes.dart';

class FollowRequestsScreen extends StatelessWidget {
  const FollowRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(appTranslation().get('follow_request')),
      ),
      body: BlocBuilder<UserCubit, UserStates>(
        builder: (context, state) {
          final requests = userCubit.userModel?.followRequests ?? [];

          if (requests.isEmpty) {
            return const Center(child: Text("No pending follow requests"));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final requesterId = requests[index];
              return FutureBuilder<UserModel?>(
                future: UserRepository().getUser(requesterId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final requester = snapshot.data!;

                  return ListTile(
                    leading: GestureDetector(
                      onTap: () => context.push(
                        Routes.profile,
                        arguments: requester.uid,
                      ),
                      child: CircleAvatar(
                        backgroundImage:
                            (requester.photoUrl != null &&
                                requester.photoUrl!.isNotEmpty)
                            ? CachedNetworkImageProvider(requester.photoUrl!)
                            : null,
                        child:
                            (requester.photoUrl == null ||
                                requester.photoUrl!.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                    ),
                    title: Text(requester.username ?? 'Unknown'),
                    subtitle: Text(
                      requester.bio ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            userCubit.acceptFollowRequest(requester.uid!);
                          },
                          icon: const Icon(
                            Icons.check_circle,
                            color: ColorsManager.success,
                            size: 30,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            userCubit.declineFollowRequest(requester.uid!);
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
