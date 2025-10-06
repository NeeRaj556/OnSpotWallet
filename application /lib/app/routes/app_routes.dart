import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/screens/home_screen/home_screen.dart';
import '../../presentation/screens/login_screen/login_screen.dart';
import '../../presentation/screens/signup_screen/signup_screen.dart';
import '../../presentation/screens/pin_screen/pin_setup_screen.dart';
import '../../presentation/screens/pin_screen/pin_verification_screen.dart';

final router = GoRouter(
  initialLocation: AppRoutes.loginScreen,
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    // If not logged in and trying to access protected routes
    if (!isLoggedIn &&
        state.matchedLocation != AppRoutes.loginScreen &&
        state.matchedLocation != AppRoutes.signupScreen) {
      return AppRoutes.loginScreen;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.loginScreen,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signupScreen,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.pinSetup,
      builder: (context, state) => const PinSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.pinVerify,
      builder: (context, state) => const PinVerificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.homeScreen,
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);

abstract class AppRoutes {
  static const loginScreen = '/login';
  static const signupScreen = '/signup';
  static const pinSetup = '/pin-setup';
  static const pinVerify = '/pin-verify';
  static const homeScreen = '/home';
}
