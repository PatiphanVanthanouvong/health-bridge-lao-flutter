// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  final String? email;
  final String? firstname;
  final String? gender;
  final String? lastname;
  final String? firebaseId;
  final dynamic status;
  final String? tel;
  final String? userId;
  final String? userType;

  UserModel({
    this.email,
    this.firstname,
    this.gender,
    this.lastname,
    this.firebaseId,
    this.status,
    this.tel,
    this.userId,
    this.userType,
  });
  UserModel update({
    String? email,
    String? firstname,
    String? gender,
    String? lastname,
    String? firebaseId,
    dynamic status,
    String? tel,
    String? userId,
    String? userType,
  }) {
    return UserModel(
      email: email ?? this.email,
      firstname: firstname ?? this.firstname,
      gender: gender ?? this.gender,
      lastname: lastname ?? this.lastname,
      firebaseId: firebaseId ?? this.firebaseId,
      status: status ?? this.status,
      tel: tel ?? this.tel,
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        email: json["email"],
        firstname: json["firstname"],
        gender: json["gender"],
        lastname: json["lastname"],
        firebaseId: json["firebase_id"],
        status: json["status"],
        tel: json["tel"],
        userId: json["user_id"],
        userType: json["user_type"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "firstname": firstname,
        "gender": gender,
        "lastname": lastname,
        "firebaseId": firebaseId,
        "status": status,
        "tel": tel,
        "user_id": userId,
        "user_type": userType,
      };
}
