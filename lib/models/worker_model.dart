import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class WorkerModel {
  final String id;
  final String name;
  final String profession;
  final String? email;
  final String? phone;
  final String? profileImage;
  final double rating;
  final int completedJobs;
  final int experienceYears;
  final int hourlyRate;
  final List<String> skills;
  final bool isVerified;
  final bool isOnline;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String? pincode;
  final String? bio;
  final double? distanceInKm;
  final Map<String, dynamic> rawData;

  const WorkerModel({
    required this.id,
    required this.name,
    required this.profession,
    this.email,
    this.phone,
    this.profileImage,
    this.rating = 4.8,
    this.completedJobs = 0,
    this.experienceYears = 1,
    this.hourlyRate = 299,
    this.skills = const [],
    this.isVerified = false,
    this.isOnline = true,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.pincode,
    this.bio,
    this.distanceInKm,
    this.rawData = const {},
  });

  /// Factory constructor to parse any Firestore worker document format
  factory WorkerModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    double? userLat,
    double? userLng,
  }) {
    final data = doc.data() ?? {};
    return WorkerModel.fromMap(doc.id, data, userLat: userLat, userLng: userLng);
  }

  factory WorkerModel.fromMap(
    String id,
    Map<String, dynamic> data, {
    double? userLat,
    double? userLng,
  }) {
    // 1. Resolve Name
    final name = (data['name'] as String?)?.trim().isNotEmpty == true
        ? data['name'] as String
        : ((data['accountHolderName'] as String?)?.trim().isNotEmpty == true
            ? data['accountHolderName'] as String
            : 'Verified Professional');

    // 2. Resolve Profession / Trade
    final profession = (data['profession'] as String?)?.trim().isNotEmpty == true
        ? data['profession'] as String
        : ((data['primaryTrade'] as String?)?.trim().isNotEmpty == true
            ? data['primaryTrade'] as String
            : 'Service Provider');

    // 3. Resolve Profile Image
    final profileImage = (data['profileImage'] as String?)?.trim().isNotEmpty == true
        ? data['profileImage'] as String
        : ((data['livePhotoUrl'] as String?)?.trim().isNotEmpty == true
            ? data['livePhotoUrl'] as String
            : ((data['avatar'] as String?)?.trim().isNotEmpty == true
                ? data['avatar'] as String
                : null));

    // 4. Resolve Online / Active Status
    // A worker is online if isOnline is true, or isAvailable is true, or status is 'online'/'available'
    // If isOnline/isAvailable is explicitly false or status is 'offline', they are offline.
    bool online = true;
    if (data.containsKey('isOnline')) {
      online = data['isOnline'] == true;
    } else if (data.containsKey('isAvailable')) {
      online = data['isAvailable'] == true;
    } else if (data.containsKey('isActive')) {
      online = data['isActive'] == true;
    } else if (data.containsKey('status')) {
      final status = data['status']?.toString().toLowerCase();
      online = (status == 'online' || status == 'available');
    }

    // 5. Resolve Verification
    final isVerified = data['isVerified'] == true ||
        data['verificationStatus'] == 'verified' ||
        data['onboardingCompleted'] == true;

    // 6. Resolve Rating & Jobs
    final rating = (data['rating'] as num?)?.toDouble() ?? 4.8;
    final completedJobs = (data['completedJobs'] as num?)?.toInt() ??
        ((data['totalJobs'] as num?)?.toInt() ?? 0);
    final experienceYears = (data['experienceYears'] as num?)?.toInt() ?? 1;
    final hourlyRate = (data['hourlyRate'] as num?)?.toInt() ??
        ((data['basePrice'] as num?)?.toInt() ?? 299);

    // 7. Resolve Skills
    List<String> skillsList = [];
    if (data['skills'] is List) {
      skillsList = (data['skills'] as List).map((e) => e.toString()).toList();
    } else if (data['serviceAreas'] is List) {
      skillsList = (data['serviceAreas'] as List).map((e) => e.toString()).toList();
    }

    // 8. Resolve Coordinates
    double? lat;
    double? lng;

    if (data['location'] is GeoPoint) {
      final gp = data['location'] as GeoPoint;
      lat = gp.latitude;
      lng = gp.longitude;
    } else if (data['location'] is Map) {
      final locMap = data['location'] as Map;
      lat = (locMap['latitude'] as num?)?.toDouble() ??
          (locMap['lat'] as num?)?.toDouble();
      lng = (locMap['longitude'] as num?)?.toDouble() ??
          (locMap['lng'] as num?)?.toDouble();
    } else {
      lat = (data['latitude'] as num?)?.toDouble() ??
          (data['lat'] as num?)?.toDouble();
      lng = (data['longitude'] as num?)?.toDouble() ??
          (data['lng'] as num?)?.toDouble();
    }

    // Fallback coordinates if worker document doesn't have GPS coordinates yet
    if (lat == null || lng == null) {
      final city = data['city']?.toString().toLowerCase() ?? '';
      if (city.contains('gorakhpur')) {
        lat = 26.7606;
        lng = 83.3732;
      } else if (city.contains('lucknow')) {
        lat = 26.8467;
        lng = 80.9462;
      } else if (userLat != null && userLng != null) {
        // Approximate location in user's general area
        lat = userLat + 0.015;
        lng = userLng + 0.012;
      }
    }

    // 9. Calculate Distance if User Coordinates are provided
    double? distanceKm;
    if (userLat != null && userLng != null && lat != null && lng != null) {
      final distanceInMeters = Geolocator.distanceBetween(
        userLat,
        userLng,
        lat,
        lng,
      );
      distanceKm = distanceInMeters / 1000.0;
    }

    return WorkerModel(
      id: id,
      name: name,
      profession: profession,
      email: data['email']?.toString(),
      phone: data['phone']?.toString(),
      profileImage: profileImage,
      rating: rating,
      completedJobs: completedJobs,
      experienceYears: experienceYears,
      hourlyRate: hourlyRate,
      skills: skillsList,
      isVerified: isVerified,
      isOnline: online,
      latitude: lat,
      longitude: lng,
      city: data['city']?.toString(),
      state: data['state']?.toString(),
      pincode: data['pincode']?.toString(),
      bio: data['bio']?.toString() ?? data['about']?.toString(),
      distanceInKm: distanceKm,
      rawData: data,
    );
  }

  /// Human-friendly formatted distance string (e.g. "850 m away", "2.4 km away")
  String get formattedDistance {
    if (distanceInKm == null) return 'Nearby';
    if (distanceInKm! < 1.0) {
      final meters = (distanceInKm! * 1000).round();
      return '$meters m away';
    }
    return '${distanceInKm!.toStringAsFixed(1)} km away';
  }

  WorkerModel copyWithDistance(double? distanceKm) {
    return WorkerModel(
      id: id,
      name: name,
      profession: profession,
      email: email,
      phone: phone,
      profileImage: profileImage,
      rating: rating,
      completedJobs: completedJobs,
      experienceYears: experienceYears,
      hourlyRate: hourlyRate,
      skills: skills,
      isVerified: isVerified,
      isOnline: isOnline,
      latitude: latitude,
      longitude: longitude,
      city: city,
      state: state,
      pincode: pincode,
      bio: bio,
      distanceInKm: distanceKm,
      rawData: rawData,
    );
  }
}
