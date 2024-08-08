import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hasura_connect/hasura_connect.dart';
import 'package:heathbridge_lao/src/models/facility_type.model.dart';
import 'package:heathbridge_lao/src/utils/hasura_helper.dart';

class FacTypeProvider extends ChangeNotifier {
  List<FacTypeModel> _typeList = [];
  List<FacTypeModel> get typeList => _typeList;

  List<FacTypeModel> types = [];
  List<FacTypeModel> listInfo = [];
  bool isGettingService = false;
  bool isLoading = false;

  Future<List<FacTypeModel>> fetchFactype() async {
    HasuraConnect connection = HasuraHelper.hasuraHelper;
    String request = """
    query MyQuery {
      facility_type(order_by: {name_en: asc}) {
        fac_type_id
        name_en
        name_la
        sub_type
      }
    }
  """;

    var data = await connection.query(request, variables: {});
    if (data['data'] != null && data['data']['facility_type'] != null) {
      List<dynamic> serviceData = data['data']['facility_type'];

      Set<String> uniqueNames = {};
      List<FacTypeModel> types = [];

      for (var item in serviceData) {
        String nameLa = item['name_la'];
        if (!uniqueNames.contains(nameLa)) {
          uniqueNames.add(nameLa);
          types.add(FacTypeModel.fromJson(item));
        }
      }

      return types;
    } else {
      return [];
    }
  }

  Future<void> getFacType() async {
    if (isGettingService) return;

    isGettingService = true;
    notifyListeners();

    try {
      _typeList = await fetchFactype();
    } catch (e) {
      log("Error fetching services: $e");
    } finally {
      isGettingService = false;
      notifyListeners();
    }
  }

  Future<void> getType() async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      listInfo = await fetchonSearchPage();
    } catch (e) {
      log("Error fetching services: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<FacTypeModel>> fetchonSearchPage() async {
    HasuraConnect connection = HasuraHelper.hasuraHelper;
    String request = """
      query MyQuery {
        facility_type(order_by: {name_en: asc}) {
          fac_type_id
          name_en
          name_la
          sub_type
          description
        }
      }
    """;

    try {
      var data = await connection.query(request, variables: {});
      List<FacTypeModel> listInfo = [];
      if (data['data'] != null && data['data']['facility_type'] != null) {
        List<dynamic> dataList = data['data']['facility_type'];
        listInfo = dataList.map((e) => FacTypeModel.fromJson(e)).toList();
        log("Fetched info successfully: $listInfo");
      }
      return listInfo;
    } catch (e) {
      log("Error fetching search page data: $e");
      return [];
    }
  }
}
