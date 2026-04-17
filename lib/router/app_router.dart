import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/phone_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/onboarding/screens/languages_screen.dart';
import '../features/onboarding/screens/travel_style_screen.dart';
import '../features/onboarding/screens/interests_screen.dart';
import '../features/onboarding/screens/matching_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/explore/screens/explore_screen.dart';
import '../features/chat/screens/chat_list_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/package_detail/screens/package_detail_screen.dart';
import '../features/chat/screens/chat_detail_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/post/screens/new_post_screen.dart';
import '../features/trips/screens/my_trips_screen.dart';
import 'main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/auth/phone',
  routes: [
    // Auth
    GoRoute(
      path: '/auth/phone',
      pageBuilder: (context, state) => _fadeTransition(
        state,
        const PhoneScreen(),
      ),
    ),
    GoRoute(
      path: '/auth/otp',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const OtpScreen(),
      ),
    ),

    // Onboarding
    GoRoute(
      path: '/onboarding/languages',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const LanguagesScreen(),
      ),
    ),
    GoRoute(
      path: '/onboarding/travel-style',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const TravelStyleScreen(),
      ),
    ),
    GoRoute(
      path: '/onboarding/interests',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const InterestsScreen(),
      ),
    ),
    GoRoute(
      path: '/onboarding/matching',
      pageBuilder: (context, state) => _fadeTransition(
        state,
        const MatchingScreen(),
      ),
    ),

    // Notifications (overlay)
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const NotificationsScreen(),
      ),
    ),

    // Main shell with bottom nav
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/shell/home',
          pageBuilder: (context, state) =>
              _noTransition(state, const HomeScreen()),
        ),
        GoRoute(
          path: '/shell/explore',
          pageBuilder: (context, state) =>
              _noTransition(state, const ExploreScreen()),
        ),
        GoRoute(
          path: '/shell/chat',
          pageBuilder: (context, state) =>
              _noTransition(state, const ChatListScreen()),
        ),
        GoRoute(
          path: '/shell/profile',
          pageBuilder: (context, state) =>
              _noTransition(state, const ProfileScreen()),
        ),
      ],
    ),

    // Package detail
    GoRoute(
      path: '/package/:id',
      pageBuilder: (context, state) => _slideTransition(
        state,
        PackageDetailScreen(packageId: state.pathParameters['id'] ?? ''),
      ),
    ),

    // Chat detail
    GoRoute(
      path: '/chat/:id',
      pageBuilder: (context, state) => _slideTransition(
        state,
        ChatDetailScreen(chatId: state.pathParameters['id'] ?? ''),
      ),
    ),

    // Profile edit
    GoRoute(
      path: '/profile/edit',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const EditProfileScreen(),
      ),
    ),

    // My trips
    GoRoute(
      path: '/trips',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const MyTripsScreen(),
      ),
    ),

    // New post
    GoRoute(
      path: '/post/new',
      pageBuilder: (context, state) => _slideUpTransition(
        state,
        const NewPostScreen(),
      ),
    ),
  ],
);

// ── Transition helpers ───────────────────────────────────────────────────────

Page<dynamic> _fadeTransition(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );

Page<dynamic> _slideTransition(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );

Page<dynamic> _slideUpTransition(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, _, child) {
        final tween = Tween(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );

Page<dynamic> _noTransition(GoRouterState state, Widget child) =>
    NoTransitionPage(key: state.pageKey, child: child);

