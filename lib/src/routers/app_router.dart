import 'package:heathbridge_lao/bottom_bar.dart';
import 'package:heathbridge_lao/package.dart';
import 'package:heathbridge_lao/src/screens/login/otp_login.dart';
import 'package:heathbridge_lao/src/screens/home/search_screen.dart';

Future<bool> isUserLoggedIn() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('uid') ?? '';
  String fid = prefs.getString('fid') ?? '';
  bool isAnonymous = prefs.getBool('isAnonymous') ?? false;

  return fid != "" || uid != "" || isAnonymous;
}

GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: "/signin", builder: (context, state) => const SignInScreen()),
    GoRoute(path: "/signup", builder: (context, state) => const SignUpScreen()),
    GoRoute(
      path: "/controller_page",
      builder: (context, state) => const ControllerPage(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: "/otp/:verificationId",
      builder: (BuildContext context, GoRouterState state) {
        String? verificationId = state.pathParameters['verificationId'];
        return OTPLogin(
          verificationId: verificationId.toString(),
        );
      },
    ),
  ],
  redirect: (context, state) async {
    final isLoggedIn = await isUserLoggedIn();

    // If the user is trying to access the welcome screen while logged in, redirect to the controller page
    if (state.uri.toString() == '/' && isLoggedIn) {
      return '/controller_page';
    }

    // If the user is trying to access a protected route while not logged in, redirect to the welcome screen
    final isGoingToProtectedRoute =
        state.uri.toString() == '/controller_page' ||
            state.uri.toString() == '/search';
    if (isGoingToProtectedRoute && !isLoggedIn) {
      return '/';
    }

    // No redirection needed
    return null;
  },
);
