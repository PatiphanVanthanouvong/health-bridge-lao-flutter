// To parse this JSON data, do
//
//     final facTypeModel = facTypeModelFromJson(jsonString);

import 'dart:convert';

FacTypeModel facTypeModelFromJson(String str) =>
    FacTypeModel.fromJson(json.decode(str));

String facTypeModelToJson(FacTypeModel data) => json.encode(data.toJson());

class FacTypeModel {
  final String? facTypeId;
  final String? nameEn;
  final String? nameLa;
  final String? sub_type;
  final String? description;

  FacTypeModel(
      {this.facTypeId,
      this.nameEn,
      this.nameLa,
      this.sub_type,
      this.description});

  // create empty in this class for me
  FacTypeModel.empty()
      : facTypeId = '0',
        nameEn = 'All',
        nameLa = 'ທັງໝົດ',
        sub_type = 'All',
        description = '';

  factory FacTypeModel.fromJson(Map<String, dynamic> json) => FacTypeModel(
      facTypeId: json["fac_type_id"],
      nameEn: json["name_en"],
      nameLa: json["name_la"],
      sub_type: json["sub_type"],
      description: json["description"]);

  Map<String, dynamic> toJson() => {
        "fac_type_id": facTypeId,
        "name_en": nameEn,
        "name_la": nameLa,
        "sub_type": sub_type,
        "description": description,
      };
}
