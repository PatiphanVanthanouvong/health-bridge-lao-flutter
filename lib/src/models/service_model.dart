// To parse this JSON data, do
//
//     final services = servicesFromJson(jsonString);

import 'dart:convert';

Services servicesFromJson(String str) => Services.fromJson(json.decode(str));

String servicesToJson(Services data) => json.encode(data.toJson());

class Services {
  final String? nameEn;
  final String? nameLa;
  final String? serviceId;
  final String? type_name;

  Services({
    this.nameEn,
    this.nameLa,
    this.serviceId,
    this.type_name,
  });

  factory Services.fromJson(Map<String, dynamic> json) => Services(
        nameEn: json["name_en"],
        nameLa: json["name_la"],
        serviceId: json["service_id"],
        type_name: json["type_name"],
      );

  Map<String, dynamic> toJson() => {
        "name_en": nameEn,
        "name_la": nameLa,
        "service_id": serviceId,
        "type_name": type_name,
      };
}
