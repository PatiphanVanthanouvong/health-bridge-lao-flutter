import 'package:flutter/material.dart';
import 'package:heathbridge_lao/package.dart';
import 'package:heathbridge_lao/src/provider/facilities_provider.dart';
import 'package:heathbridge_lao/src/screens/detail/fac_detail.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ListSearch extends StatefulWidget {
  const ListSearch({super.key});

  @override
  _ListSearchState createState() => _ListSearchState();
}

class _ListSearchState extends State<ListSearch>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _performSearch(String query) {
    // Implement your search logic here
    print('Searching for: $query');
  }

  void _updateFilteredSuggestions(String query) {
    // Implement your suggestions logic here
    print('Filtering suggestions for: $query');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(125), // Adjust the height as needed
        child: Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0, // Remove elevation if not needed
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
                    onPressed: () => context.push("/search"),
                    icon: const Icon(Icons.menu),
                  ),
                ),
              ],
              title: InkWell(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: ConstantColor.colorMain,
                      width: 2.0,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () => context.push("/search"),
                    child: TextField(
                      enabled: false,
                      controller: _searchController,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'ເຂົ້າໜ້າການຄົ້ນຫາ...',
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            _performSearch(_searchController.text);
                          },
                        ),
                      ),
                      onChanged: _updateFilteredSuggestions,
                      onSubmitted: _performSearch,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 66, // Adjust height as needed
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
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  // itemCount: provider.typeList.length, // Number of chips
                  itemCount: AppConstants().factype.length,
                  itemBuilder: (BuildContext context, int index) {
                    // FacTypeModel facility = provider.typeList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () async {
                          var query = AppConstants().factype[index];
                          var selectTypeName = AppConstants().factype[index];
                          await context
                              .read<FacilityProvider>()
                              .searchFacilities(
                                  selectTypeName == query || query == "ທັງໝົດ"
                                      ? ""
                                      : query,
                                  selectTypeName == "ທັງໝົດ"
                                      ? ""
                                      : selectTypeName,
                                  facilityTypes: selectedType == "ທັງໝົດ"
                                      ? null
                                      : [selectedType.toLowerCase()]);
                          _searchController.text = query;
                        },
                        // child: Chip(
                        //   label: Text("${facility.nameLa} ${facility.type}"),
                        // ),
                        child: Chip(label: Text(AppConstants().factype[index])),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Consumer<FacilityProvider>(
                builder: (context, provider, child) {
                  // if (provider.isGettingFacInfo) {
                  //   return _buildLoadingSkeleton();
                  // }

                  if (provider.facData.isEmpty) {
                    return const Center(
                      child: Text('No facilities found'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: provider.facData.length,
                    itemBuilder: (context, index) {
                      final facility = provider.facData[index];
                      return GestureDetector(
                        onTap: () {
                          context
                              .read<FacilityProvider>()
                              .getDetailEach(facId: facility.facId!);
                          showBottomSheet(
                            elevation: 4,
                            context: context,
                            builder: (ctx) => FacDetail(facId: facility.facId!),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(
                              color: ConstantColor.colorMain,
                              width: 1.0,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8.0),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                height: 90,
                                width: 60,
                                color: Colors.white,
                                child: facility.imageUrl == null ||
                                        facility.imageUrl == ""
                                    ? const Center(
                                        child: Text(
                                          "No image yet",
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      )
                                    : Image.network(
                                        facility.imageUrl!,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
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
                                              "Failed to load image",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            title: Text(
                              facility.name ?? 'No Name',
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${facility.facilityType?.nameLa}${facility.facilityType?.sub_type} ", // Assuming facilityTye has a nameLa field
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                ),
                                Text(
                                    overflow: TextOverflow.ellipsis,
                                    '${facility.village},  ${facility.district},  ${facility.province}.'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: const BorderSide(
                color: ConstantColor.colorMain,
                width: 1.0,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8.0),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  height: 90,
                  width: 60,
                  color: Colors.white,
                ),
              ),
              title: Container(
                height: 20.0,
                color: Colors.white,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10.0),
                  Container(
                    height: 20.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    height: 20.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
