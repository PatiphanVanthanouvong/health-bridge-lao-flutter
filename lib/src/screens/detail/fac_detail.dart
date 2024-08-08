// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:heathbridge_lao/package.dart';
import 'package:heathbridge_lao/src/provider/review_provider.dart';
import 'package:heathbridge_lao/src/screens/review/review_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class FacDetail extends StatefulWidget {
  const FacDetail({super.key, required this.facId});
  final String facId;

  @override
  State<FacDetail> createState() => _FacDetailState();
}

class _FacDetailState extends State<FacDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var auth = FirebaseAuth.instance;
  var peopleCount;
  void openGoogleMaps(String latitude, String longitude) async {
    String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    Uri uri = Uri.parse(googleMapsUrl);
    if (!await launchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // showDialog(
      //   context: context,
      //   builder: (context) => AlertDialog(
      //     title: const Text('Error'),
      //     content: const Text('Could not open the map.'),
      //     actions: [
      //       TextButton(
      //         onPressed: () => Navigator.of(context).pop(),
      //         child: const Text('OK'),
      //       ),
      //     ],
      //   ),
      // );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      peopleCount = Provider.of<ReviewProvider>(context, listen: false)
          .fetchReviews(widget.facId);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.index == 1) {
      context.read<ReviewProvider>().refreshReviews(widget.facId);
    }
  }

  void checkAuthGoReview(double rating) {
    if (auth.currentUser == null) {
      context.go("/signin");
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReviewScreen(
                  initialRating: rating,
                  facId: widget.facId,
                )),
      );
    }
  }

  final int rating = 3;
  final int reviews = 40;

  @override
  Widget build(BuildContext context) {
    return Consumer<FacilityProvider>(builder: (context, provider, child) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 1.0,
        minChildSize: 0.5,
        shouldCloseOnMinExtent: true,
        builder: (context, ScrollController scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: provider.isGettingDetails
                ? const Padding(
                    padding: EdgeInsets.all(100.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Divider(
                          color: Colors.grey,
                          thickness: 4,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 220,
                        width: double.infinity,
                        color: Colors.black,
                        child: provider.oneFac.imageUrl == null ||
                                provider.oneFac.imageUrl == ""
                            ? const Center(
                                child: Text(
                                  "ຍັງບໍ່ມີຮູບພາບ",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Image.network(
                                provider.oneFac.imageUrl!,
                                fit: BoxFit.fitHeight,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  return const Center(
                                    child: Text(
                                      "Failed to load image",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.oneFac.name ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${provider.oneFac.facilityType?.nameLa}  ${provider.oneFac.facilityType?.sub_type}", // Assuming facilityTye has a nameLa field
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text(
                                          "(${provider.oneFac.ratingCount ?? 0})",
                                          style: const TextStyle(
                                              fontSize: 13, color: Colors.grey),
                                        ),
                                        const SizedBox(width: 5),
                                        SizedBox(
                                          height: 15,
                                          width: 120,
                                          child: RatingBar.builder(
                                            itemSize: 15,
                                            initialRating:
                                                provider.oneFac.ratingCount ==
                                                        null
                                                    ? 0.0
                                                    : double.tryParse(provider
                                                            .oneFac
                                                            .ratingCount) ??
                                                        0,
                                            minRating: 0.1,
                                            maxRating: 5.0,
                                            direction: Axis.horizontal,
                                            ignoreGestures: true,
                                            allowHalfRating: true,
                                            // itemCount: 5,
                                            itemPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 0.0),
                                            itemBuilder: (context, _) =>
                                                const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (rating) {
                                              // checkAuthGoReview();
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                  ],
                                ),
                                Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: IconButton(
                                        icon: const Icon(Icons.directions),
                                        color: Colors.white,
                                        onPressed: () {
                                          // Add directions logic here
                                          if (provider.oneFac.latitude !=
                                                  null &&
                                              provider.oneFac.longitude !=
                                                  null) {
                                            openGoogleMaps(
                                                provider.oneFac.latitude!,
                                                provider.oneFac.longitude!);
                                          } else {
                                            debugPrint(
                                                "Latitude and Longitude not available");
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text("ຊອກທິດທາງ",
                                        style: TextStyle(fontSize: 13)),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Divider(),
                      // TabBar

                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: "ຂໍ້ມູນພາບລວມ"),
                          Tab(text: "ການສະເເດງຄວາມຄິດເຫັນ"),
                        ],
                      ),
                      // TabBarView
                      SizedBox(
                        height: 730, // Adjust the height as needed
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.location_on),
                                        Text(
                                          "  ບ້ານ, ເມືອງ, ເເຂວງ:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          "${provider.oneFac.village}, ${provider.oneFac.district}, ${provider.oneFac.province}.",
                                          overflow: TextOverflow.fade,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    Row(
                                      children: [
                                        const Icon(Icons.call),
                                        const Text(
                                          "  ຂໍ້ມູນການຕິດຕໍ່:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          provider.oneFac.contactInfo == null ||
                                                  provider.oneFac.contactInfo ==
                                                      ""
                                              ? "ບໍ່ມີຂໍ້ມູນຕິດຕໍ່"
                                              : provider.oneFac.contactInfo!,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    const Row(
                                      children: [
                                        Icon(Icons.medical_services),
                                        Text(
                                          "  ການບໍລິການ:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 0),
                                    provider.oneFac.serviceDetails == null ||
                                            provider
                                                .oneFac.serviceDetails!.isEmpty
                                        ? const Text(
                                            "ຍັງບໍ່ມີຂໍ້ມູນ",
                                            style: TextStyle(fontSize: 13),
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: provider
                                                .oneFac.serviceDetails!
                                                .map((serviceDetail) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 3.0),
                                                child: Text(
                                                  "${serviceDetail.service?.nameLa ?? 'No service name'} (${serviceDetail.service?.type_name ?? 'No service type'})",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                    const Divider(),
                                  ]),
                            ),
                            //* REVIEW SCREEN
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const CircleAvatar(
                                        radius: 16,
                                        child: Icon(Icons.person),
                                      ),
                                      RatingBar.builder(
                                        // ignoreGestures: true,
                                        initialRating: 1.5,
                                        minRating: 1,
                                        maxRating: 5,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemPadding: const EdgeInsets.symmetric(
                                            horizontal: 3.0),
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (rating) {
                                          // checkAuthGoReview();
                                          if (auth.currentUser == null) {
                                            AwesomeDialog(
                                              context: context,
                                              dialogType: DialogType.warning,
                                              headerAnimationLoop: false,
                                              animType: AnimType.bottomSlide,
                                              title:
                                                  'ທ່ານຍັງບໍ່ໄດ້ເຂົ້າບັນຊີໃນລະບົບ',
                                              desc:
                                                  'ກະລຸນາເຂົ້າຊື່ໃຊ້ລະບົບກ່ອນ...',
                                              buttonsTextStyle: const TextStyle(
                                                  color: Colors.white),
                                              showCloseIcon: true,
                                              btnCancelOnPress: () {},
                                              btnOkOnPress: () {
                                                context.push("/signin");
                                              },
                                            ).show();
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ReviewScreen(
                                                        initialRating: rating,
                                                        facId: widget.facId,
                                                      )),
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Consumer<ReviewProvider>(
                                    builder: (context, reviewProvider, child) {
                                      if (reviewProvider.isLoading) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (reviewProvider.reviews.isEmpty) {
                                        return const Center(
                                            child: Text(
                                                "ຍັງບໍ່ມີການສະເເດງຄວາມຄິດເຫັນ..."));
                                      } else {
                                        return ListView.builder(
                                          itemCount:
                                              reviewProvider.reviews.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            final review =
                                                reviewProvider.reviews[index];
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              child: Card(
                                                color: Colors.grey.shade200,
                                                elevation: 2,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "${review.user?.firstname ?? 'No Name'} ${review.user?.lastname ?? ''}",
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      RatingBarIndicator(
                                                        rating:
                                                            review.rating ?? 0,
                                                        itemBuilder:
                                                            (context, _) =>
                                                                const Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                        ),
                                                        itemCount: 5,
                                                        itemSize: 20,
                                                        direction:
                                                            Axis.horizontal,
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        review.description ??
                                                            'No Review',
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        "${review.createdAt ?? 'Date not available'}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      );
    });
  }
}
