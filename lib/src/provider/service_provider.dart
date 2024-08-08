import 'package:heathbridge_lao/package.dart';

class ServiceProvider extends ChangeNotifier {
  List<Services> _serviceList = [];
  List<Services> get serviceList => _serviceList;

  bool isGettingService = false;

  Future<List<Services>> fetchServices() async {
    HasuraConnect connection = HasuraHelper.hasuraHelper;
    String request = """
    query MyQuery {
      services {
        name_en
        name_la
        service_id
        type_name
      }
    }
  """;

    var data = await connection.query(request, variables: {});
    if (data['data'] != null && data['data']['services'] != null) {
      List<dynamic> serviceData = data['data']['services'];
      return serviceData
          .map((e) => Services.fromJson(e))
          .map((service) => Services(
              nameEn: service.nameEn ?? "", // Handle null with ?? ""
              nameLa: service.nameLa,
              serviceId: service.serviceId,
              type_name: service.type_name ?? "")) // Handle null with ?? ""
          .toList();
    } else {
      return [];
    }
  }

  Future<void> getServiceList() async {
    isGettingService = true;
    notifyListeners();

    try {
      _serviceList = await fetchServices();
      print("Services fetched successfully: $_serviceList");
    } catch (e) {
      print("Error fetching services: $e");
    } finally {
      isGettingService = false;
      notifyListeners();
    }
  }
}
