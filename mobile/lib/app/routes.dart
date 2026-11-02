import 'package:go_router/go_router.dart';

import '../features/authentication/screens/email_login_screen.dart';
import '../features/authentication/screens/otp_screen.dart';
import '../features/authentication/screens/phone_login_screen.dart';
import '../features/onboarding/screens/intro_screen.dart';
import '../features/onboarding/screens/splash_screen.dart';
import '../features/onboarding/screens/welcome_screen.dart';
import '../features/profile/models/profile_draft.dart';
import '../features/profile/screens/basics_screen.dart';
import '../features/profile/screens/intentions_screen.dart';
import '../features/profile/screens/interests_screen.dart';
import '../features/profile/screens/photos_screen.dart';
import '../features/profile/screens/preview_screen.dart';
import '../features/profile/screens/prompts_screen.dart';

/// Route paths. Use these constants instead of string literals.
abstract final class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const intro = '/intro';
  static const phoneLogin = '/auth/phone';
  static const emailLogin = '/auth/email';
  static const otp = '/auth/otp';

  // Profile setup
  static const setupBasics = '/setup/basics';
  static const setupIntentions = '/setup/intentions';
  static const setupInterests = '/setup/interests';
  static const setupPhotos = '/setup/photos';
  static const setupPrompts = '/setup/prompts';
  static const setupPreview = '/setup/preview';
}

GoRouter createAppRouter({String initialLocation = AppRoutes.splash}) {
  // One draft per router, shared by every profile-setup screen.
  final profileDraft = ProfileDraft();

  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.intro,
        builder: (context, state) => const IntroScreen(),
      ),
      GoRoute(
        path: AppRoutes.phoneLogin,
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailLogin,
        builder: (context, state) => const EmailLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        // The OTP step needs a destination; without one, restart at phone login.
        redirect: (context, state) =>
            state.extra is OtpArgs ? null : AppRoutes.phoneLogin,
        builder: (context, state) => OtpScreen(args: state.extra! as OtpArgs),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            ProfileDraftScope(draft: profileDraft, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.setupBasics,
            builder: (context, state) => const BasicsScreen(),
          ),
          GoRoute(
            path: AppRoutes.setupIntentions,
            builder: (context, state) => const IntentionsScreen(),
          ),
          GoRoute(
            path: AppRoutes.setupInterests,
            builder: (context, state) => const InterestsScreen(),
          ),
          GoRoute(
            path: AppRoutes.setupPhotos,
            builder: (context, state) => const PhotosScreen(),
          ),
          GoRoute(
            path: AppRoutes.setupPrompts,
            builder: (context, state) => const PromptsScreen(),
          ),
          GoRoute(
            path: AppRoutes.setupPreview,
            builder: (context, state) => const PreviewScreen(),
          ),
        ],
      ),
    ],
  );
}
