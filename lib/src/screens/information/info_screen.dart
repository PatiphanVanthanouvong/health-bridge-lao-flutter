import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:heathbridge_lao/src/provider/review_provider.dart';
import 'package:provider/provider.dart';
import 'package:heathbridge_lao/package.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? uid; // Changed to nullable string

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch data only if user is logged in
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userModelList = userProvider.userModel;
    if (userModelList.isNotEmpty) {
      final userModel = userModelList[0];
      uid = userModel.userId;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final facTypeProvider = context.read<FacTypeProvider>();
      final serviceProvider = context.read<ServiceProvider>();

      facTypeProvider.getType();
      serviceProvider.getServiceList();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Call providers in didChangeDependencies to ensure context is available

    if (uid != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final reviewProvider = context.read<ReviewProvider>();
        reviewProvider.fetchUserReviews(uid!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ConstantColor.colorMain,
        centerTitle: true,
        title: const Text(
          'ຂໍ້ມູນເພີ່ມເຕີມ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: _buildTabBar(),
        ), // Conditional bottom property based on uid
      ),
      body: _buildTabBarView(),
    );
  }

  // Build tab bar with tabs for facilities, services, and reviews
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      indicatorColor: Colors.white,
      unselectedLabelColor: Colors.white38,
      tabs: const [
        Tab(text: 'ປະເພດສະຖານທີ່'),
        Tab(text: 'ການບໍລິການ'),
        Tab(text: 'ຄວາມຄິດເຫັນ'), // New tab for reviews
      ],
    );
  }

  // Build tab bar view with corresponding content for facilities, services, and reviews
  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        Consumer<FacTypeProvider>(
          builder: (context, facTypeProvider, child) {
            return _buildFacilityTab(facTypeProvider);
          },
        ),
        Consumer<ServiceProvider>(
          builder: (context, serviceProvider, child) {
            return _buildServiceTab(serviceProvider);
          },
        ),
        Consumer<ReviewProvider>(
          builder: (context, reviewProvider, child) {
            return _buildReviewsTab(reviewProvider);
          },
        ),
      ],
    );
  }

  // Build content for the facility tab
  Widget _buildFacilityTab(FacTypeProvider facTypeProvider) {
    return Column(
      children: [
        if (facTypeProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: facTypeProvider.listInfo.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final facility = facTypeProvider.listInfo[index];
                return ListTile(
                  title: Text(
                      '${facility.nameLa ?? ''} ${facility.sub_type ?? ''}'),
                  subtitle: Text(
                      '${facility.nameEn ?? ''}\n${facility.description ?? ''}'),
                );
              },
            ),
          ),
      ],
    );
  }

  // Build content for the service tab
  Widget _buildServiceTab(ServiceProvider serviceProvider) {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.all(8.0)),
        if (serviceProvider.isGettingService)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: serviceProvider.serviceList.length,
              itemBuilder: (context, index) {
                final service = serviceProvider.serviceList[index];
                return ListTile(
                  title: Text(service.nameLa ?? ''),
                  subtitle: Text(
                      '${service.type_name ?? ''}\n${service.nameEn ?? ''}'),
                );
              },
            ),
          ),
      ],
    );
  }

  // Build content for the reviews tab
  Widget _buildReviewsTab(ReviewProvider reviewProvider) {
    return Column(
      children: [
        if (reviewProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (uid == null)
          _buildNotLoggedInMessage() // Show not logged in message
        else if (reviewProvider.reviews.isEmpty)
          const Center(child: Text('No reviews found.'))
        else
          Expanded(
            child: ListView.builder(
              itemCount: reviewProvider.userReviews.length,
              itemBuilder: (context, index) {
                final review = reviewProvider.userReviews[index];
                return ListTile(
                  title: Text(review.facility?.name ?? 'no comment'),
                  subtitle:
                      Text('${review.description}\nRating: ${review.rating}'),
                  // trailing: IconButton(
                  //   icon: const Icon(Icons.delete),
                  //   onPressed: () {
                  //     // Dismiss the review (change status to 0)
                  //     // log(review.facId.toString());
                  //     // reviewProvider.dismissReview(review.reviewId ?? '');
                  //   },
                  // ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Build UI when user is not logged in
  Widget _buildNotLoggedInMessage() {
    return const Center(
      child: Text(
        'ທ່ານຍັງບໍ່ໄດ້ເຂົ້າສູ່ລະບົບ.',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
