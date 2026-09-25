import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationDetails {
  final double? latitude;
  final double? longitude;
  final String? house;
  final String? area;
  final String? city;
  final String? state;
  final String? pincode;

  const LocationDetails({
    this.latitude,
    this.longitude,
    this.house,
    this.area,
    this.city,
    this.state,
    this.pincode,
  });
}

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

  /// Attempt to fetch complete location and address details safely
  Future<LocationDetails?> getCurrentLocationDetails() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );

      final placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        return LocationDetails(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      final place = placemarks.first;
      return LocationDetails(
        latitude: position.latitude,
        longitude: position.longitude,
        house: place.street?.trim() ?? place.subThoroughfare?.trim() ?? '',
        area: place.subLocality?.trim().isNotEmpty == true
            ? place.subLocality!.trim()
            : (place.thoroughfare?.trim() ?? ''),
        city: place.locality?.trim().isNotEmpty == true
            ? place.locality!.trim()
            : (place.subAdministrativeArea?.trim() ?? ''),
        state: place.administrativeArea?.trim() ?? '',
        pincode: place.postalCode?.trim() ?? '',
      );
    } catch (_) {
      return null;
    }
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