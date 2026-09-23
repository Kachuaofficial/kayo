import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kayo/pages/services/services_page.dart';
import 'package:kayo/router/page_transitions.dart';

import '../pages/explore/explore.dart';
import '../pages/home/home_page.dart';
import '../pages/profile/profile.dart';
import '../pages/bookings/bookings.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',

  routes: [
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
    StatefulShellRoute.indexedStack(
      builder:
          (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return AppRouter(navigationShell: navigationShell);
          },

      branches: [
        // HOME
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) {
                return const HomePage();
              },
            ),
          ],
        ),

        // EXPLORE
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              name: 'explore',
              builder: (context, state) {
                return const ExplorePage();
              },
            ),
          ],
        ),

        // ACTIVITY
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/activity',
              name: 'activity',
              builder: (context, state) {
                return const Bookings();
              },
            ),
          ],
        ),

        // PROFILE
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) {
                return const ProfilePage();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);

// ------------------------------------------------------------
// BOTTOM NAVIGATION SHELL
// ------------------------------------------------------------

class AppRouter extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppRouter({super.key, required this.navigationShell});

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
