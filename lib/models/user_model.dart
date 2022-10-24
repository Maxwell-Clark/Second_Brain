class UserModel {
  final String email;
  final String name;
  final String profilePic;
  final String uid;
  final String token;

  UserModel({
    required this.email,
    required this.name,
    required this.profilePic,
    required this.uid,
    required this.token
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json["email"] ?? "",
      name: json["name"] ?? "",
      profilePic: json["profilePic"] ?? "",
      uid: json["_id"] ?? "",
      token: json["token"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "email": this.email,
      "name": this.name,
      "profilePic": this.profilePic,
      "uid": this.uid,
      "token": this.token,
    };
  }

  UserModel copyWith({
    String? email,
    String? name,
    String? profilePic,
    String? uid,
    String? token,
  }) {
    return UserModel(
        email: email ?? this.email,
        name: name ?? this.name,
        profilePic: profilePic ?? this.profilePic,
        uid: uid ?? this.uid,
        token: token ?? this.token,
    );
  }

//

}