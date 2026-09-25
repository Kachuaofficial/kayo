import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kayo/pages/auth/auth_page.dart';
import 'package:kayo/pages/services/services_page.dart';
import 'package:kayo/router/page_transitions.dart';

import '../pages/bookings/bookings.dart';
import '../pages/explore/explore.dart';
import '../pages/home/home_page.dart';
import '../pages/profile/profile.dart';
import '../pages/search/search_page.dart';

/// Helper class to convert a Stream into a Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Creates the application router with Firebase authentication state integration
GoRouter createAppRouter([FirebaseAuth? auth]) {
  final firebaseAuth = auth ?? FirebaseAuth.instance;

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(firebaseAuth.authStateChanges()),
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = firebaseAuth.currentUser != null;
      final bool isAuthRoute = state.matchedLocation == '/auth';

      // If user is not authenticated and trying to access protected routes
      if (!loggedIn && !isAuthRoute) {
        return '/auth';
      }

      // If user is authenticated and is on auth route, take them home
      if (loggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/search',
        name: 'search',
        pageBuilder: (context, state) {
          final query = state.uri.queryParameters['q'];
          return AppPageTransitions.fadeSlide(
            key: state.pageKey,
            child: SearchPage(initialQuery: query),
          );
        },
      ),
      GoRoute(
        path: '/services',
        name: 'services',
        pageBuilder: (context, state) {
          return AppPageTransitions.fadeSlide(
            key: state.pageKey,
            child: const ServicesPage(),
          );
        },
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return AppRouterShell(navigationShell: navigationShell);
        },
        branches: [
          // HOME
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // EXPLORE
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                name: 'explore',
                builder: (context, state) => const ExplorePage(),
              ),
            ],
          ),

          // ACTIVITY
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/activity',
                name: 'activity',
                builder: (context, state) => const Bookings(),
              ),
            ],
          ),

          // PROFILE
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// Default instance
final GoRouter appRouter = createAppRouter();

// ------------------------------------------------------------
// BOTTOM NAVIGATION SHELL
// ------------------------------------------------------------

class AppRouterShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppRouterShell({super.key, required this.navigationShell});

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
