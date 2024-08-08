// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:heathbridge_lao/package.dart';

class FacilityProvider extends ChangeNotifier {
  final List<Facilities> _approvedFacilities = [];
  List<Facilities> get approvedFacilities => _approvedFacilities;

  List<Facilities> _facData = [];
  List<Facilities> get facData => _facData;

  List<Facilities> _userFacData = [];
  List<Facilities> get userFacData => _userFacData;

  List<Facilities> _pendingFac = [];
  List<Facilities> get pendingFac => _pendingFac;

  List<Facilities> _statusThreeFacData = [];
  List<Facilities> get statusThreeFacData => _statusThreeFacData;

  Facilities? _oneFac;
  Facilities get oneFac => _oneFac!;

  bool _isGettingFacInfo = false;
  bool get isGettingFacInfo => _isGettingFacInfo;
  bool isGettingDetails = false;
  bool isGettingFacWithService = false;
  bool isLoading = false;

  Future<void> getRejectFacilities() async {
    isLoading = true;
    notifyListeners();

    try {
      _statusThreeFacData = await _searchFacilityByStatus(3);
      // print("Facilities fetched successfully: $_facData");
    } catch (e) {
      print("Error fetching facilities: $e");
      _statusThreeFacData = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getFacInfo() async {
    _isGettingFacInfo = true;
    notifyListeners();

    try {
      _facData = await _searchFacility();
      // print("Facilities fetched successfully: $_facData");
    } catch (e) {
      print("Error fetching facilities: $e");
      _facData = [];
    } finally {
      _isGettingFacInfo = false;
      notifyListeners();
    }
  }

  Future<void> getDetailEach({String? facId}) async {
    isGettingDetails = true;
    notifyListeners();

    try {
      _oneFac = await _getOneFacilities(id: facId);
      // print("Facilities fetched One successfully!!!$_oneFac");
    } catch (e) {
      print(e);
    }
    isGettingDetails = false;
    notifyListeners();
  }

  Future<void> searchFacilities(String search, String searchTypeName,
      {List<String>? facilityTypes}) async {
    _isGettingFacInfo = true;
    notifyListeners();

    try {
      _facData = await _searchFacility(
          search: search,
          searchTypeName: searchTypeName,
          facilityTypes: facilityTypes);
      // print("Facilities fetched successfully!!!");
    } catch (e) {
      print("Error fetching facilities: $e");
      _facData = [];
    } finally {
      _isGettingFacInfo = false;
      notifyListeners();
    }
  }

  Future<void> getFacilitiesByUserId(String userId) async {
    _isGettingFacInfo = true;
    notifyListeners();

    try {
      _userFacData = await _fetchFacilitiesByUserId(userId);
      print("Facilities for user $userId fetched successfully: $_userFacData");
    } catch (e) {
      print("Error fetching facilities for user $userId: $e");
      _userFacData = [];
    } finally {
      _isGettingFacInfo = false;
      notifyListeners();
    }
  }

  Future<void> getFacilitiesByUserIdAndStatus(String userId) async {
    _isGettingFacInfo = true;
    notifyListeners();

    try {
      _pendingFac = await _fetchFacilitiesByUserIdAndStatus(userId);
      print(
          "Facilities for user $userId with status 2 fetched successfully: $_userFacData");
    } catch (e) {
      print("Error fetching facilities for user $userId with status 2: $e");
      _pendingFac = [];
    } finally {
      _isGettingFacInfo = false;
      notifyListeners();
    }
  }

  Future<List<Facilities>> _fetchFacilitiesByUserIdAndStatus(
      String userId) async {
    HasuraConnect connection = HasuraHelper.hasuraHelper;
    String request = """
      query facilities(\$userId: uuid!, \$status: Int!) {
        facilities(where: {user_id: {_eq: \$userId}, status: {_eq: \$status}}) {
          fac_id
          fac_type_id
          name
          village
          district
          province
          contact_info
          Latitude
          Longitude
          status
          rating_count
          image_url
          facility_type {
          fac_type_id
            name_en
            name_la
            sub_type
            description
          }
        }
      }
    """;

    var data = await connection.query(request, variables: {
      'userId': userId,
      'status': 2,
    });
    List<dynamic> facilitiesData = data['data']['facilities'];
    return facilitiesData.map((e) => Facilities.fromJson(e)).toList();
  }

  Future<List<Facilities>> _fetchFacilitiesByUserId(String userId) async {
    HasuraConnect connection = HasuraHelper.hasuraHelper;
    String request = """
      query facilities(\$userId: uuid!, \$_status: [Int!] ) {
      facilities(where: {user_id: {_eq: \$userId}, status: {_in:  \$_status}}) {
          fac_id
          fac_type_id
          name
          village
          district
          province
          contact_info
          Latitude
          Longitude
          status
          rating_count
          image_url
          facility_type {
          fac_type_id
            name_en
            name_la
            sub_type
            description
          }
        }
      }
    """;

    var data = await connection.query(request, variables: {
      'userId': userId,
      '_status': [1, 0],
    });
    List<dynamic> facilitiesData = data['data']['facilities'];
    return facilitiesData.map((e) => Facilities.fromJson(e)).toList();
  }

  Future<List<Facilities>> _searchFacility({
    String search = "",
    String searchTypeName = "",
    List<String>? facilityTypes,
  }) async {
    HasuraConnect connection = HasuraHelper.hasuraHelper;
    String request = """
      query facilities(\$searchName: String = "%", \$searchTypeName: String = "%", \$facilityTypes: [String!] = []) {
        facilities(where: {
          _and: [
            { name: { _ilike: \$searchName } },
            { facility_type: { name_la: { _ilike: \$searchTypeName } } },
            { facility_type: { sub_type: { _in: \$facilityTypes } } },
         {status: {_eq: 1}}
          ]
        }) {
          fac_id
          fac_type_id
          name
          village
          district
          province
          contact_info
          Latitude
          Longitude
          status
          rating_count
          image_url
          facility_type {
          
            name_en
            name_la
            sub_type
            description
          }
        }
      }
    """;

    var data = await connection.query(request, variables: {
      'searchName': search.trim().isEmpty ? '%%' : '%${search.trim()}%',
      'searchTypeName':
          searchTypeName.trim().isEmpty ? '%%' : '%${searchTypeName.trim()}%',
      'facilityTypes': facilityTypes ??
          ["ສູນກາງ", "ເອກະຊົນ", "ເມືອງ", "ນ້ອຍ", "ພື້ນເມືຶອງ", "ສາທາລະນະສຸກ"],
    });
    List<dynamic> facilitiesData = data['data']['facilities'];
    return facilitiesData.map((e) => Facilities.fromJson(e)).toList();
  }

  Future<void> searchByServices({String search = ""}) async {
    _isGettingFacInfo = true;
    notifyListeners();

    HasuraConnect connection = HasuraHelper.hasuraHelper;
    String request = """
    query facilities(\$searchName: String ) {
      facilities(where: {service_details: {service: {name_la: {_ilike: \$searchName}}}  , status: {_eq: 1} }) {
        Latitude
        Longitude
        contact_info
        district
        fac_id
        fac_type_id
        image_url
        name
        province
        rating_count
        status
        village
        facility_type {
          name_en
          name_la
          sub_type
          description
        }
        service_details {
          service {
            name_la
          }
        }
      }
    }
  """;

    try {
      var data = await connection.query(request, variables: {
        'searchName': search == "" ? '%%' : '%$search%',
      });

      List<dynamic> facilitiesData = data['data']['facilities'];
      _facData = facilitiesData.map((e) => Facilities.fromJson(e)).toList();

      if (search == "") {
        _facData = await _searchFacility(
          search: search,
          // searchTypeName: searchTypeName,
          // facilityTypes: facilityTypes
        );
      }
      log("Search Service SUccess");
    } catch (e) {
      log("Error fetching facilities: $e");
      _facData = [];
    } finally {
      _isGettingFacInfo = false;
      notifyListeners();
    }
  }

  Future<void> searchByTypes({String search = ""}) async {
    _isGettingFacInfo = true;
    notifyListeners();

    HasuraConnect connection = HasuraHelper.hasuraHelper;
    String request = """
   query facilities(\$searchName: uuid  ) {
      facilities(where: {facility_type:  {fac_type_id: {_eq: \$searchName}} , status: {_eq: 1} }) {
        Latitude
        Longitude
        contact_info
        district
        fac_id
        fac_type_id
        image_url
        name
        province
        rating_count
        status
        village
        facility_type {
          name_en
          name_la
          sub_type
          description
        }
        service_details {
          service {
            name_la
          }
        }
      }
    }
  """;

    try {
      var data = await connection.query(request, variables: {
        'searchName': search,
      });

      List<dynamic> facilitiesData = data['data']['facilities'];
      _facData = facilitiesData.map((e) => Facilities.fromJson(e)).toList();

      if (search == "") {
        _facData = await _searchFacility(
          search: search,
        );
      }
      print("Facilities fetched By Type successfully!!!");
    } catch (e) {
      log("Error fetching from Type: $e");
      _facData = [];
    } finally {
      _isGettingFacInfo = false;
      notifyListeners();
    }
  }

  Future<List<Facilities>> _searchFacilityByStatus(int status) async {
    HasuraConnect connection = HasuraHelper.hasuraHelper;
    String request = """
      query facilities(\$status: Int!) {
        facilities(where: {status: {_eq: \$status}}) {
          fac_id
          fac_type_id
          name
          village
          district
          province
          contact_info
          Latitude
          Longitude
          status
          rating_count
          image_url
          facility_type {
            name_en
            name_la
            sub_type
            description
          }
        }
      }
    """;

    var data = await connection.query(request, variables: {
      'status': status,
    });
    List<dynamic> facilitiesData = data['data']['facilities'];
    return facilitiesData.map((e) => Facilities.fromJson(e)).toList();
  }
}

Future<Facilities> _getOneFacilities({String? id}) async {
  HasuraConnect connection = HasuraHelper.hasuraHelper;
  String request = """
     query fetchEachFac(\$fac_id: uuid! ) {
  facilities(where: {fac_id: {_eq: \$fac_id}}) {
    fac_id
    facility_type {
      name_en
      sub_type
      description
      name_la
    }
    service_details {
      service {
        name_en
        name_la
        type_name
      }
    }
    Latitude
    Longitude
    contact_info
    district
    name
    province
    image_url
    rating_count
      village
    status
  }
}
    """;

  var data = await connection.query(request, variables: {
    "fac_id": id,
  });

  return (data['data']['facilities'] as List)
      .map((e) => Facilities.fromJson(e))
      .first;
}
