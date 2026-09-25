import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kayo/widgets/home_banner.dart';
import 'package:kayo/widgets/home_search.dart';
import 'package:kayo/widgets/home_services.dart';
import 'package:kayo/widgets/nearby_workers.dart';

import '../../services/location_service.dart';
import '../../widgets/home_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocationService _locationService = LocationService();

  String _location = 'Getting location...';

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final location = await _locationService.getCurrentLocationName();

      if (!mounted) return;

      setState(() {
        _location = location;
      });
    } on LocationServiceDisabledException {
      if (!mounted) return;

      setState(() {
        _location = 'Location disabled';
      });
    } on LocationPermissionDeniedException {
      if (!mounted) return;

      setState(() {
        _location = 'Enable location';
      });
    } on LocationPermissionPermanentlyDeniedException {
      if (!mounted) return;

      setState(() {
        _location = 'Enable location';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _location = 'Location unavailable';
      });
    }
  }

  Future<void> _handleLocationTap() async {
    try {
      final location = await _locationService.getCurrentLocationName();

      if (!mounted) return;

      setState(() {
        _location = location;
      });
    } on LocationPermissionPermanentlyDeniedException {
      await _locationService.openAppSettings();
    } on LocationServiceDisabledException {
      await _locationService.openLocationSettings();
    } catch (_) {
      // Keep existing location text.
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String greetingName = () {
      if (user?.displayName?.trim().isNotEmpty == true) {
        return user!.displayName!.trim().split(' ').first;
      }
      if (user?.email?.isNotEmpty == true) {
        return user!.email!.split('@').first;
      }
      return 'Friend';
    }();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HomeHeader(
                userName: greetingName,
                photoUrl: user?.photoURL,
                location: _location,
                notificationCount: 3,
                onLocationTap: _handleLocationTap,
              ),

              const HomeSearch(),
              const HomeBanner(),
              const HomeServices(),
              const NearbyWorkers(),
            ],
          ),
        ),
      ),
    );
  }
}
