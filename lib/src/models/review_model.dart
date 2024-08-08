// To parse this JSON data, do
//
//     final reviewModel = reviewModelFromJson(jsonString);

import 'dart:convert';

ReviewModel reviewModelFromJson(String str) =>
    ReviewModel.fromJson(json.decode(str));

String reviewModelToJson(ReviewModel data) => json.encode(data.toJson());

class ReviewModel {
  final DateTime? createdAt;
  final String? description;
  final double? rating;
  final int? status;
  final String? facId;
  final String? reviewId;
  final User? user;
  final Facility? facility;

  ReviewModel({
    this.createdAt,
    this.description,
    this.rating,
    this.status,
    this.facId,
    this.reviewId,
    this.user,
    this.facility,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        description: json["description"],
        rating: json["rating"]?.toDouble(),
        status: json["status"],
        facId: json["fac_id"],
        reviewId: json["review_id"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        facility: json["facility"] == null
            ? null
            : Facility.fromJson(json["facility"]),
      );

  Map<String, dynamic> toJson() => {
        "created_at": createdAt?.toIso8601String(),
        "description": description,
        "rating": rating,
        "status": status,
        "fac_id": facId,
        "review_id": reviewId,
        "user": user?.toJson(),
        "facility": facility?.toJson(),
      };
}

class Facility {
  final String? name;

  Facility({
    this.name,
  });

  factory Facility.fromJson(Map<String, dynamic> json) => Facility(
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}

class User {
  final String? firstname;
  final String? lastname;
  final String? email;
  final String? tel;
  final String? userId;

  User({
    this.firstname,
    this.lastname,
    this.email,
    this.tel,
    this.userId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        firstname: json["firstname"],
        lastname: json["lastname"],
        email: json["email"],
        tel: json["tel"],
        userId: json["user_id"],
      );

  Map<String, dynamic> toJson() => {
        "firstname": firstname,
        "lastname": lastname,
        "email": email,
        "tel": tel,
        "user_id": userId,
      };
}
