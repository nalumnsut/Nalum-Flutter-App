import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nalum_app/app/router/app_routes.dart';
import 'package:nalum_app/app/router/auth_redirect.dart';
import 'package:nalum_app/app/shell/home_shell.dart';
import 'package:nalum_app/app/widgets/placeholder_screen.dart';
import 'package:nalum_app/features/auth/application/auth_controller.dart';
import 'package:nalum_app/features/auth/domain/auth_status.dart';
import 'package:nalum_app/features/auth/presentation/gate_screens.dart';
import 'package:nalum_app/features/auth/presentation/login_screen.dart';
import 'package:nalum_app/features/auth/presentation/splash_screen.dart';
import 'package:nalum_app/features/chat/presentation/chat_screen.dart';
import 'package:nalum_app/features/directory/presentation/directory_screen.dart';
import 'package:nalum_app/features/events/presentation/events_screen.dart';
import 'package:nalum_app/features/home/presentation/home_screen.dart';
import 'package:nalum_app/features/notifications/presentation/notifications_screen.dart';
import 'package:nalum_app/features/onboarding/presentation/profile_setup_screen.dart';
import 'package:nalum_app/features/posts/presentation/posts_screen.dart';
import 'package:nalum_app/features/settings/presentation/settings_screen.dart';
import 'package:nalum_app/features/verification/presentation/verify_alumni_screen.dart';
import 'package:nalum_app/l10n/l10n.dart';

/// The route table (docs/NAVIGATION.md §1). Detail routes sit above the tab
/// shell so they cover the bottom bar.
final appRouterProvider = Provider<GoRouter>((ref) {
  final status = ValueNotifier<AuthStatus>(ref.read(authControllerProvider));
  ref
    ..listen(authControllerProvider, (_, next) => status.value = next)
    ..onDispose(status.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: status,
    redirect: (_, state) => authRedirect(status.value, state.uri),
    errorBuilder: (context, _) =>
        PlaceholderScreen(title: context.l10n.notFoundTitle),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, _) => LoginScreen(
          onCreateAccount: () => context.push(AppRoutes.signUp),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, _) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (_, _) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: AppRoutes.banned,
        builder: (_, _) => const BannedScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminWeb,
        builder: (_, _) => const AdminWebScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (_, _) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyAlumni,
        builder: (_, _) => const VerifyAlumniScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          _tab(AppRoutes.home, const HomeScreen()),
          _tab(AppRoutes.directory, const DirectoryScreen()),
          _tab(AppRoutes.posts, const PostsScreen()),
          _tab(AppRoutes.events, const EventsScreen()),
          _tab(AppRoutes.chat, const ChatScreen()),
        ],
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.directory}/:userId',
        builder: (context, _) =>
            PlaceholderScreen(title: context.l10n.profileTitle),
      ),
      GoRoute(
        path: '${AppRoutes.posts}/:postId',
        builder: (context, _) =>
            PlaceholderScreen(title: context.l10n.postTitle),
      ),
      GoRoute(
        path: '${AppRoutes.events}/:eventId',
        builder: (context, _) =>
            PlaceholderScreen(title: context.l10n.eventTitle),
      ),
      GoRoute(
        path: '${AppRoutes.chat}/:conversationId',
        builder: (context, _) =>
            PlaceholderScreen(title: context.l10n.conversationTitle),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _tab(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (_, _) => screen)],
);
