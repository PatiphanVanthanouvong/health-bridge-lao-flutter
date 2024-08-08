import 'package:heathbridge_lao/src/screens/about_us/about_us.dart';
import 'package:heathbridge_lao/src/screens/setting/widgets/setting_widget.dart';
import 'package:heathbridge_lao/src/screens/user_add_fac/facility_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:heathbridge_lao/package.dart';

import 'edit_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the user data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        context.read<UserProvider>().fetchUser(firebaseUser.uid);
      }
      context.read<FacTypeProvider>().getFacType();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ConstantColor.colorMain,
        centerTitle: true,
        title: const Text(
          'ຕັ້ງຄ່າ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              child: Column(
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        "assets/images/app-logo.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      if (userProvider.userModel.isEmpty) {
                        return Column(
                          children: [
                            Text(
                              'ທ່ານເຂົ້າສູ່ລະບົບເເບບບໍ່ຢືນຢັນຕົວຕົນ',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 20),
                            AnimatedButton(
                              width: 140,
                              height: 40,
                              isFixedHeight: false,
                              buttonTextStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              text: 'ເຂົ້າສູ່ລະບົບ',
                              color: ConstantColor.colorMain,
                              pressEvent: () {
                                context.push("/signin");
                              },
                            ),
                          ],
                        );
                      } else {
                        final user = userProvider.userModel.first;
                        return Container(
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(
                                10), // Optional: Adds rounded corners
                            border: Border.all(
                              color: Colors.grey, // Outline color
                              width: 1, // Outline width
                            ),
                          ),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_pin_rounded,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Expanded(
                                      child: Text(
                                        "${user.firstname} ${user.lastname}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'ອິເມວ: ${user.email}',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'ເບີໂທລະສັບ: ${user.tel}',
                                      style: const TextStyle(
                                        fontSize:
                                            14, // Adjust font size as needed
                                        fontWeight: FontWeight
                                            .w400, // Adjust font weight as needed
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                AnimatedButton(
                                  width: 140,
                                  height: 40,
                                  isFixedHeight: false,
                                  buttonTextStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  text: 'ເເກ້ໄຂໜ້າຜູ້ໃຊ້',
                                  color: ConstantColor.colorMain,
                                  pressEvent: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const EditProfileScreen()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Divider(
                    thickness: 2,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  ProfileWidget(
                    title: "ເພີ່ມສະຖານທີ່ການເເພດຂອງທ່ານ",
                    icon: Icons.add_location_alt,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FacilityScreen()),
                      );
                    },
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ProfileWidget(
                    title: "ກ່ຽວກັບພວກເຮົາ",
                    icon: Icons.info,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AboutUs()),
                      );
                    },
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ProfileWidget(
                    title: "ອອກຈາກລະບົບ",
                    icon: Icons.logout,
                    textColor: Colors.black,
                    endIcon: true,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    onPressed: () {
                      _showLogoutConfirmationDialog();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleLogout(BuildContext context) {
    context.read<UserProvider>().logout();
  }

  // Function to show logout confirmation dialog
  void _showLogoutConfirmationDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.topSlide,
      title: 'ອອກຈາກລະບົບ',
      desc: 'ທ່ານຕ້ອງການອອກຈາກບັນຊີລະບົບບໍ?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        handleLogout(context);
        FirebaseAuth.instance.signOut();
        context.pushReplacement('/');
      },
    ).show();
  }
}
