import 'package:heathbridge_lao/package.dart';
import 'package:heathbridge_lao/src/screens/information/info_screen.dart';

class ControllerPage extends StatefulWidget {
  const ControllerPage({super.key});

  @override
  State<ControllerPage> createState() => _NaviPageState();
}

class _NaviPageState extends State<ControllerPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ListSearch(),
    InfoScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final userModel = context.watch<UserProvider>().userModel;
    debugPrint("User Model Data: $userModel");
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: SizedBox(
          height: 65,
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const <NavigationDestination>[
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.home,
                  size: 30,
                ),
                icon: Icon(
                  Icons.home_outlined,
                  size: 30,
                ),
                label: 'ໜ້າຫຼັກ',
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.view_list,
                  size: 30,
                ),
                icon: Icon(
                  Icons.view_list_outlined,
                  size: 30,
                ),
                label: 'ລາຍການ',
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.info,
                  size: 30,
                ),
                icon: Icon(
                  Icons.info_outline,
                  size: 30,
                ),
                label: 'ຂໍ້ມູນເພີ່ມເຕີມ',
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.settings,
                  size: 30,
                ),
                icon: Icon(
                  Icons.settings_outlined,
                  size: 30,
                ),
                label: 'ຕັ້ງຄ່າ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
