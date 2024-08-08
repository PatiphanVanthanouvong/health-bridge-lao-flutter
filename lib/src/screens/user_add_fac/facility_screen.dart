// ignore_for_file: use_build_context_synchronously

import 'package:heathbridge_lao/package.dart';
import 'package:heathbridge_lao/src/screens/home/widget/typedropdown.dart';
import 'package:heathbridge_lao/src/screens/user_add_fac/add_fac.dart';

class FacilityScreen extends StatefulWidget {
  const FacilityScreen({super.key});

  @override
  State<FacilityScreen> createState() => _FacilityScreenState();
}

class _FacilityScreenState extends State<FacilityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? uid;

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

      // Fetch facilities by user ID
      if (uid != null) {
        final facilityProvider = context.read<FacilityProvider>();
        facilityProvider.getFacilitiesByUserId(uid!);
        facilityProvider.getFacilitiesByUserIdAndStatus(uid!);
        facilityProvider.getRejectFacilities();
      }
    });
  }

  void _refreshFacilities() {
    final facilityProvider = context.read<FacilityProvider>();
    if (uid != null) {
      facilityProvider.getFacilitiesByUserId(uid!);
      facilityProvider.getFacilitiesByUserIdAndStatus(uid!);
      facilityProvider.getRejectFacilities();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        foregroundColor: Colors.white,
        backgroundColor: ConstantColor.colorMain,
        centerTitle: true,
        title: const Text(
          'ສະຖານທີ່ຂອງທ່ານ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        actions: const [],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: _buildTabBar(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddFacilityDialog(userUID: uid!),
          ).then((result) {
            if (result == true) {
              _refreshFacilities();
              _tabController.index = 1;
            }
          });
        },
        shape: const CircleBorder(),
        backgroundColor: ConstantColor.colorMain,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      body: _buildTabBarView(),
    );
  }

  Widget _buildFacilityTab(FacilityProvider facilityProvider) {
    return Column(
      children: [
        if (facilityProvider.isGettingFacInfo)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: facilityProvider.userFacData.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final facility = facilityProvider.userFacData[index];
                return ListTile(
                  leading: Chip(
                    label: Icon(
                      facility.status == 1
                          ? Icons.public_outlined
                          : Icons.check_outlined,
                      size: 30,
                      color: facility.status == 1
                          ? Colors.green.shade800
                          : Colors.red,
                    ),
                  ),
                  titleTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16),
                  title: Text(facility.name ?? ''),
                  subtitle: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'ປະເພດ: ${facility.facilityType!.nameLa ?? ''} ${facility.facilityType!.sub_type ?? ''}\n',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black), // Default style
                        ),
                        TextSpan(
                          text: '${facility.village ?? ''}, ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                                  .shade700), // Smaller font size for village
                        ),
                        TextSpan(
                          text: '${facility.district ?? ''}, ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                                  .shade700), // Smaller font size for district
                        ),
                        TextSpan(
                          text: '${facility.province ?? ''} ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                                  .shade700), // Smaller font size for province
                        ),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        showDialog(
                          context: context,
                          builder: (context) => AddFacilityDialog(
                              facilityInfo: facilityProvider.userFacData[index],
                              isEditMode: true,
                              userUID: uid!),
                        ).then((result) {
                          if (result == true) {
                            _refreshFacilities(); // Refresh data if result is true
                          }
                        });
                      } else if (value == 'delete') {
                        _deleteFacility(facility.facId.toString());
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPendingTab(FacilityProvider facilityProvider) {
    return Column(
      children: [
        if (facilityProvider.isGettingFacInfo)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: facilityProvider.pendingFac.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final facility = facilityProvider.pendingFac[index];
                return ListTile(
                  leading: const Chip(
                    label: Icon(
                      Icons.pending_actions_outlined,
                      size: 30,
                      color: ConstantColor.colorMain,
                    ),
                  ),
                  titleTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16),
                  title: Text(facility.name ?? ''),
                  subtitle: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'ປະເພດ: ${facility.facilityType!.nameLa ?? ''} ${facility.facilityType!.sub_type ?? ''}\n',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black), // Default style
                        ),
                        TextSpan(
                          text: '${facility.village ?? ''}, ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                                  .shade700), // Smaller font size for village
                        ),
                        TextSpan(
                          text: '${facility.district ?? ''}, ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                                  .shade700), // Smaller font size for district
                        ),
                        TextSpan(
                          text: '${facility.province ?? ''} ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                                  .shade700), // Smaller font size for province
                        ),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        showDialog(
                          context: context,
                          builder: (context) => AddFacilityDialog(
                              facilityInfo: facilityProvider.pendingFac[index],
                              isEditMode: true,
                              userUID: uid!),
                        ).then((result) {
                          if (result == true) {
                            _refreshFacilities(); // Refresh data if result is true
                          }
                        });
                      } else if (value == 'delete') {
                        _deleteFacility(facility.facId.toString());
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRejectTab(FacilityProvider facilityProvider) {
    return Column(
      children: [
        if (facilityProvider.isGettingFacInfo)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: facilityProvider.statusThreeFacData.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final facility = facilityProvider.statusThreeFacData[index];
                return ListTile(
                  leading: const Chip(
                    label: Icon(
                      Icons.public_off_outlined,
                      size: 30,
                      color: Colors.red,
                    ),
                  ),
                  titleTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16),
                  title: Text(facility.name ?? ''),
                  subtitle: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'ປະເພດ: ${facility.facilityType!.nameLa ?? ''} ${facility.facilityType!.sub_type ?? ''}\n',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black), // Default style
                        ),
                        TextSpan(
                          text: '${facility.village ?? ''}, ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                                  .shade700), // Smaller font size for village
                        ),
                        TextSpan(
                          text: '${facility.district ?? ''}, ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                                  .shade700), // Smaller font size for district
                        ),
                        TextSpan(
                          text: '${facility.province ?? ''} ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                                  .shade700), // Smaller font size for province
                        ),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        showDialog(
                          context: context,
                          builder: (context) => AddFacilityDialog(
                              facilityInfo: facilityProvider.pendingFac[index],
                              isEditMode: true,
                              userUID: uid!),
                        ).then((result) {
                          if (result == true) {
                            _refreshFacilities(); // Refresh data if result is true
                          }
                        });
                      } else if (value == 'delete') {
                        _deleteFacility(facility.facId.toString());
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _deleteFacility(String facilityId) async {
    final confirm = await _showDeleteConfirmationDialog();
    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final HasuraConnect hasuraConnect = HasuraHelper.hasuraHelper;

      const String mutation = '''
    mutation DeleteFacility(\$id: uuid!) {
      delete_facilities(where: {fac_id: {_eq: \$id}}) {
        affected_rows
      }
    }
    ''';

      final variables = {'id': facilityId};

      final result =
          await hasuraConnect.mutation(mutation, variables: variables);

      Navigator.of(context).pop(); // Close loading dialog

      if (result['data']['delete_facilities']['affected_rows'] > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Facility deleted successfully')),
        );

        _refreshFacilities(); // Refresh data after deletion
      } else {
        throw Exception('Failed to delete facility');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting facility: ${e.toString()}')),
      );
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this facility?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        Consumer<FacilityProvider>(
          builder: (context, facilityProvider, child) {
            return _buildFacilityTab(facilityProvider);
          },
        ),
        // Placeholder for other tabs
        Consumer<FacilityProvider>(
          builder: (context, facilityProvider, child) {
            return _buildPendingTab(facilityProvider);
          },
        ),
        Consumer<FacilityProvider>(
          builder: (context, facilityProvider, child) {
            return _buildRejectTab(facilityProvider);
          },
        ),
      ],
    );
  }

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
        Tab(text: 'ໜ້າຫຼັກ'),
        Tab(text: 'ກໍາລັງຮ້ອງຂໍ'),
        Tab(text: 'ປະຕິເສດ'),
      ],
    );
  }
}
