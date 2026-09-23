import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final Geocoding _geocoding = Geocoding();

  Future<String> getCurrentLocationName() async {
    // 1. Check whether device location is enabled
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw LocationServiceDisabledException();
    }

    // 2. Check permission
    var permission = await Geolocator.checkPermission();

    // 3. Request permission
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 4. Permission denied
    if (permission == LocationPermission.denied) {
      throw LocationPermissionDeniedException();
    }

    // 5. Permission permanently denied
    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionPermanentlyDeniedException();
    }

    // 6. Get current coordinates
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    // 7. Reverse geocoding
    final placemarks = await _geocoding.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) {
      return 'Current location';
    }

    final place = placemarks.first;

    final city = place.locality?.trim();
    final state = place.administrativeArea?.trim();

    if (city != null &&
        city.isNotEmpty &&
        state != null &&
        state.isNotEmpty) {
      return '$city, $state';
    }

    if (city != null && city.isNotEmpty) {
      return city;
    }

    if (state != null && state.isNotEmpty) {
      return state;
    }

    return 'Current location';
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}


/// Location service is disabled.
class LocationServiceDisabledException implements Exception {}


/// User denied location permission.
class LocationPermissionDeniedException implements Exception {}


/// User permanently denied location permission.
class LocationPermissionPermanentlyDeniedException
    implements Exception {}