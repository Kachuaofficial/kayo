class UserLocation {
  final double latitude;
  final double longitude;
  final String city;
  final String state;
  final String? postalCode;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.state,
    this.postalCode,
  });

  String get displayName {
    if (city.isNotEmpty && state.isNotEmpty) {
      return '$city, $state';
    }

    if (city.isNotEmpty) {
      return city;
    }

    return 'Current location';
  }
}