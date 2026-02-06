class UserModel {
  final String? uid;
  final String? email;
  final String? username;
  final String? photoUrl;
  final String? bio;
  final List<String> followers;
  final List<String> following;
  final String? fcmToken;
  final List<String> savedPosts;
  final List<String> followRequests;
  final bool isPrivateProfile;
  final String? coverUrl;
  final String? usernameLower;

  UserModel({
    this.uid,
    this.email,
    this.username,
    this.photoUrl,
    this.bio,
    this.followers = const [],
    this.following = const [],
    this.fcmToken,
    this.savedPosts = const [],
    this.followRequests = const [],
    this.isPrivateProfile = false,
    this.coverUrl,
    this.usernameLower,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      username: map['username'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      bio: map['bio'],
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      fcmToken: map['fcmToken'],
      savedPosts: List<String>.from(map['savedPosts'] ?? []),
      followRequests: List<String>.from(map['followRequests'] ?? []),
      isPrivateProfile: map['isPrivateProfile'] ?? false,
      coverUrl: map['coverUrl'],
      usernameLower: map['usernameLower'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'followers': followers,
      'following': following,
      'fcmToken': fcmToken,
      'savedPosts': savedPosts,
      'followRequests': followRequests,
      'isPrivateProfile': isPrivateProfile,
      'coverUrl': coverUrl,
      'usernameLower': usernameLower ?? username?.toLowerCase(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? photoUrl,
    String? bio,
    List<String>? followers,
    List<String>? following,
    String? fcmToken,
    List<String>? savedPosts,
    List<String>? followRequests,
    bool? isPrivateProfile,
    String? coverUrl,
    String? usernameLower,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      fcmToken: fcmToken ?? this.fcmToken,
      savedPosts: savedPosts ?? this.savedPosts,
      followRequests: followRequests ?? this.followRequests,
      isPrivateProfile: isPrivateProfile ?? this.isPrivateProfile,
      coverUrl: coverUrl ?? this.coverUrl,
      usernameLower: usernameLower ?? this.usernameLower,
    );
  }
}
