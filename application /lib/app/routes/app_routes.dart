import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/screens/main_navigation/main_navigation_screen.dart';
import '../../presentation/screens/login_screen/login_screen.dart';
import '../../presentation/screens/signup_screen/signup_screen.dart';
import '../../presentation/screens/pin_screen/pin_setup_screen.dart';
import '../../presentation/screens/pin_screen/pin_verification_screen.dart';
import '../../presentation/screens/initial_setup/initial_setup_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.loginScreen,
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final isSetupComplete = prefs.getBool('initial_setup_complete') ?? false;
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    // Check if initial setup is needed
    if (!isSetupComplete && state.matchedLocation != AppRoutes.initialSetup) {
      return AppRoutes.initialSetup;
    }

    // If not logged in and trying to access protected routes
    if (!isLoggedIn &&
        state.matchedLocation != AppRoutes.loginScreen &&
        state.matchedLocation != AppRoutes.signupScreen &&
        state.matchedLocation != AppRoutes.initialSetup) {
      return AppRoutes.loginScreen;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.initialSetup,
      builder: (context, state) => InitialSetupScreen(
        onSetupComplete: () {
          // Navigate to login after setup
          context.go(AppRoutes.loginScreen);
        },
      ),
    ),
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
      builder: (context, state) => const MainNavigationScreen(),
    ),
  ],
);

abstract class AppRoutes {
  static const initialSetup = '/initial-setup';
  static const loginScreen = '/login';
  static const signupScreen = '/signup';
  static const pinSetup = '/pin-setup';
  static const pinVerify = '/pin-verify';
  static const homeScreen = '/home';
}
