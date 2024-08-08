// ignore_for_file: deprecated_member_use, unused_field, override_on_non_overriding_member, unused_local_variable
import 'dart:async';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:heathbridge_lao/package.dart';
import 'package:heathbridge_lao/src/models/facility_type.model.dart';
import 'package:heathbridge_lao/src/screens/home/widget/showdropdown.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.5,
  );
  final bool _isDialogShown = false;
  var currentLocation = AppConstants.myLocation;
  LatLng? userLocation;
  int selectedIndex = 0;
  String _location = "Fetching location...";
  Timer? _debounce;
  var hee = dotenv.env['HASURA_ENDPOINT']!;
  @override
  late final MapController mapController;
  @override
  void initState() {
    super.initState();
    _getLocation();
    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FacilityProvider>().getFacInfo();
      context.read<FacTypeProvider>().getFacType();
    });
    userLocation = currentLocation;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Call search function here
      if (_searchController.text.isNotEmpty) {
        Provider.of<FacilityProvider>(context, listen: false).searchFacilities(
            _searchController.text.trim(), "",
            facilityTypes: null);
      }
    });
  }

  Future<void> _getLocation() async {
    try {
      log("try_get_location");
      Position position = await LocationService().getCurrentLocation();
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        // currentLocation = userLocation!;
        _location = "Lat: ${position.latitude}, Long: ${position.longitude}";
        log(_location);
        // Move the map to the user's current location
        mapController.move(currentLocation, 14);
      });
    } catch (e) {
      log(e.toString());
    }
  }

  void showCustomBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 1.0,
          minChildSize: 0.5,
          shouldCloseOnMinExtent: true,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: const BottomSheetContent(),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: ConstantColor.colorMain,
                      width: 2.0,
                    ),
                  ),
                  width: 50,
                  height: 50,
                  child: IconButton(
                    onPressed: () {
                      context.push("/search");
                    },
                    icon: const Icon(Icons.menu),
                  ),
                ),
              ],
              title: InkWell(
                onTap: () {},
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: ConstantColor.colorMain,
                      width: 2.0,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _onSearchChanged();
                    },
                    // onSubmitted: _searchController.text,
                    enabled: true,
                    autofocus: false,
                    decoration: const InputDecoration(
                      // isDense: true,
                      contentPadding: EdgeInsets.all(1),
                      hintText: 'ຄົ້ນຫາສະຖານທີ່...',
                      icon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50, // Adjust height as needed
              child: Consumer<FacTypeProvider>(
                  builder: (context, provider, child) {
                if (provider.isGettingService) {
                  return const Center(
                    child: Text('Loading....'),
                  );
                }
                if (provider.typeList.isEmpty) {
                  return const Center(
                    child: Text('No facility types available'),
                  );
                }
                String selectTypeName = 'ທັງໝົດ';
                String selectedType = 'ທັງໝົດ';

                if (provider.typeList
                    .where((element) => element.nameLa == "ທັງໝົດ")
                    .isEmpty) {
                  provider.typeList.insert(0, FacTypeModel.empty());
                }
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.typeList.length, // Number of chips
                  // itemCount: AppConstants().factype.length,
                  itemBuilder: (BuildContext context, int index) {
                    FacTypeModel facility = provider.typeList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () async {
                          final item = provider.typeList[index];
                          _searchController.text = item.nameLa ?? "";

                          if (item.nameLa == FacTypeModel.empty().nameLa) {
                            await context
                                .read<FacilityProvider>()
                                .searchFacilities("", "", facilityTypes: null);
                          } else {
                            await context
                                .read<FacilityProvider>()
                                .searchFacilities("", _searchController.text);
                          }
                        },

                        child: Chip(
                          label: Text("${facility.nameLa}"),
                        ),
                        // child: Chip(label: Text(AppConstants().factype[index])),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      body: Consumer<FacilityProvider>(builder: (context, provider, child) {
        final markers = provider.facData.map((facility) {
          final lat = double.tryParse(facility.latitude ?? '0') ?? 0;
          final lng = double.tryParse(facility.longitude ?? '0') ?? 0;
          final location = LatLng(lat, lng);
          String markerImage;

          if (facility.facilityType?.nameEn?.toLowerCase() == 'hospital') {
            markerImage = 'assets/images/hospitol-marker.png';
          } else if (facility.facilityType?.nameEn?.toLowerCase() ==
              'pharmacy') {
            markerImage = 'assets/images/pharmacy-marker.png';
          } else if (facility.facilityType?.nameEn?.toLowerCase() == 'clinic') {
            markerImage = 'assets/images/clinic-marker.png';
          } else {
            markerImage = 'assets/images/logo.png';
          }
          return Marker(
            height: 50,
            width: 50,
            point: location,
            child: GestureDetector(
              onTap: () {
                final index = provider.facData.indexOf(facility);
                pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
                setState(() {
                  selectedIndex = index;
                  currentLocation = location;
                });
                _animatedMapMove(currentLocation, 14);
              },
              onDoubleTap: () {
                context
                    .read<FacilityProvider>()
                    .getDetailEach(facId: facility.facId!);
                showBottomSheet(
                  context: context,
                  builder: (ctx) => FacDetail(facId: facility.facId!),
                );
              },
              child: AnimatedScale(
                duration: const Duration(milliseconds: 500),
                scale: selectedIndex == provider.facData.indexOf(facility)
                    ? 1
                    : 0.7,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: selectedIndex == provider.facData.indexOf(facility)
                      ? 1
                      : 0.9,
                  child: Image.asset(markerImage, fit: BoxFit.contain),
                ),
              ),
            ),
          );
        }).toList();
        if (userLocation != null) {
          markers.add(
            Marker(
                height: 50,
                width: 50,
                point: userLocation!,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 30,
                )),
          );
        }
        return Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                minZoom: 5,
                maxZoom: 18,
                initialZoom: 12,
                initialCenter: currentLocation,
              ),
              children: [
                TileLayer(
                  urlTemplate: dotenv.env['MAP_API']!,
                  additionalOptions: {
                    'accessToken': dotenv.env['ACCESS_TOKEN']!,
                    'mapStyleId': dotenv.env['MAP_STYLE_ID']!,
                  },
                  tileProvider: NetworkTileProvider(),
                ),
                MarkerLayer(markers: markers),
              ],
            ),
            Consumer<FacilityProvider>(builder: (context, provider, child) {
              if (provider.isGettingFacInfo) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (provider.facData.isEmpty) {
                return const Center(
                  child: Text('ບໍ່ພົບສະຖານທີ່ທີ່ຄົ້ນຫາ'),
                );
              }
              return Positioned(
                left: 0,
                right: 0,
                bottom: 75,
                height: MediaQuery.of(context).size.height * 0.2,
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (value) {
                    setState(() {
                      selectedIndex = value;
                      final facility = provider.facData[value];
                      currentLocation = LatLng(
                        double.tryParse(facility.latitude ?? '0') ?? 0,
                        double.tryParse(facility.longitude ?? '0') ?? 0,
                      );
                    });
                    _animatedMapMove(currentLocation, 13.5);
                  },
                  itemCount: provider.facData.length,
                  itemBuilder: (_, index) {
                    final facility = provider.facData[index];
                    return GestureDetector(
                      onTap: () {
                        context
                            .read<FacilityProvider>()
                            .getDetailEach(facId: facility.facId!);
                        showBottomSheet(
                          context: context,
                          builder: (ctx) => FacDetail(facId: facility.facId!),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                child: Container(
                                  height: 90,
                                  width: double.infinity,
                                  color: Colors.white,
                                  child: facility.imageUrl == null ||
                                          facility.imageUrl == ""
                                      ? const Center(
                                          child: Text(
                                            "ຍັງບໍ່ມີຮູບພາບ",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        )
                                      : Image.network(
                                          facility.imageUrl!,
                                          fit: BoxFit.fitWidth,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            } else {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                          },
                                          errorBuilder: (BuildContext context,
                                              Object error,
                                              StackTrace? stackTrace) {
                                            return const Center(
                                              child: Text(
                                                "ຮູບມີການຜິດພາດ",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 10),
                                    Text(
                                      facility.name ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          facility.facilityType?.nameLa ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          facility.facilityType?.sub_type ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            Positioned(
              right: 15,
              bottom: 75,
              height: MediaQuery.of(context).size.height * 0.45,
              child: Center(
                child: InkWell(
                  onTap: () {
                    _animatedMapMove(currentLocation, 14);
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: SvgPicture.asset(
                        "assets/icons/location-targer-icon.svg"),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }
}
