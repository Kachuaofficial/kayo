import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Type of search result item
enum SearchItemType {
  service,
  worker,
  category,
}

/// Unified search result model
class SearchResultItem {
  final String id;
  final SearchItemType type;
  final String title;
  final String subtitle;
  final String? description;
  final String? imageUrl;
  final String? iconName;
  final double? rating;
  final int? totalJobsOrReviews;
  final int? price;
  final String? category;
  final List<String> tags;
  final bool isOnline;
  final double? distanceInKm;
  final Map<String, dynamic> rawData;

  const SearchResultItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.description,
    this.imageUrl,
    this.iconName,
    this.rating,
    this.totalJobsOrReviews,
    this.price,
    this.category,
    this.tags = const [],
    this.isOnline = true,
    this.distanceInKm,
    this.rawData = const {},
  });

  String get formattedDistance {
    if (distanceInKm == null) return 'Nearby';
    if (distanceInKm! < 1.0) {
      final meters = (distanceInKm! * 1000).round();
      return '$meters m away';
    }
    return '${distanceInKm!.toStringAsFixed(1)} km away';
  }

  IconData get icon {
    switch (iconName) {
      case 'plumbing_rounded':
        return Icons.plumbing_rounded;
      case 'electrical_services_rounded':
        return Icons.electrical_services_rounded;
      case 'cleaning_services_rounded':
        return Icons.cleaning_services_rounded;
      case 'handyman_rounded':
        return Icons.handyman_rounded;
      case 'format_paint_rounded':
        return Icons.format_paint_rounded;
      case 'car_repair_rounded':
        return Icons.car_repair_rounded;
      case 'ac_unit_rounded':
        return Icons.ac_unit_rounded;
      case 'home_repair_service_rounded':
        return Icons.home_repair_service_rounded;
      case 'elderly_rounded':
      case 'home_rounded':
        return Icons.home_rounded;
      case 'yard_rounded':
        return Icons.yard_rounded;
      case 'drive_eta_rounded':
        return Icons.drive_eta_rounded;
      case 'pest_control_rounded':
        return Icons.pest_control_rounded;
      case 'brush_rounded':
        return Icons.brush_rounded;
      default:
        return type == SearchItemType.worker
            ? Icons.person_rounded
            : Icons.build_rounded;
    }
  }

  factory SearchResultItem.fromServiceDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return SearchResultItem(
      id: doc.id,
      type: SearchItemType.service,
      title: data['name']?.toString() ?? 'Service',
      subtitle: data['category']?.toString() ?? 'General',
      description: data['description']?.toString() ?? '',
      iconName: data['icon']?.toString() ?? 'handyman_rounded',
      price: (data['basePrice'] as num?)?.toInt(),
      category: data['category']?.toString(),
      tags: [
        if (data['category'] != null) data['category'].toString(),
        if (data['name'] != null) data['name'].toString(),
      ],
      rawData: data,
    );
  }

  factory SearchResultItem.fromWorkerDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    double? userLat,
    double? userLng,
  }) {
    final data = doc.data() ?? {};
    final skillsRaw = data['skills'];
    final List<String> skills = (skillsRaw is List)
        ? skillsRaw.map((e) => e.toString()).toList()
        : [];

    final name = (data['name'] as String?)?.trim().isNotEmpty == true
        ? data['name'] as String
        : ((data['accountHolderName'] as String?)?.trim().isNotEmpty == true
            ? data['accountHolderName'] as String
            : 'Worker');

    final profession = (data['profession'] as String?)?.trim().isNotEmpty == true
        ? data['profession'] as String
        : ((data['primaryTrade'] as String?)?.trim().isNotEmpty == true
            ? data['primaryTrade'] as String
            : 'Professional');

    final photo = (data['profileImage'] as String?)?.trim().isNotEmpty == true
        ? data['profileImage'] as String
        : ((data['livePhotoUrl'] as String?)?.trim().isNotEmpty == true
            ? data['livePhotoUrl'] as String
            : ((data['avatar'] as String?)?.trim().isNotEmpty == true
                ? data['avatar'] as String
                : null));

    bool online = true;
    if (data.containsKey('isOnline')) {
      online = data['isOnline'] == true;
    } else if (data.containsKey('isAvailable')) {
      online = data['isAvailable'] == true;
    } else if (data.containsKey('isActive')) {
      online = data['isActive'] == true;
    } else if (data.containsKey('status')) {
      final s = data['status']?.toString().toLowerCase();
      online = (s == 'online' || s == 'available');
    }

    // Distance calculation
    double? lat;
    double? lng;
    if (data['location'] is GeoPoint) {
      final gp = data['location'] as GeoPoint;
      lat = gp.latitude;
      lng = gp.longitude;
    } else if (data['location'] is Map) {
      final loc = data['location'] as Map;
      lat = (loc['latitude'] as num?)?.toDouble() ?? (loc['lat'] as num?)?.toDouble();
      lng = (loc['longitude'] as num?)?.toDouble() ?? (loc['lng'] as num?)?.toDouble();
    } else {
      lat = (data['latitude'] as num?)?.toDouble();
      lng = (data['longitude'] as num?)?.toDouble();
    }

    double? distanceKm;
    if (userLat != null && userLng != null && lat != null && lng != null) {
      final m = Geolocator.distanceBetween(userLat, userLng, lat, lng);
      distanceKm = m / 1000.0;
    }

    return SearchResultItem(
      id: doc.id,
      type: SearchItemType.worker,
      title: name,
      subtitle: profession,
      description: data['bio']?.toString() ?? data['about']?.toString() ?? '',
      imageUrl: photo,
      rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
      totalJobsOrReviews: (data['completedJobs'] as num?)?.toInt() ??
          ((data['totalJobs'] as num?)?.toInt() ?? 0),
      price: (data['hourlyRate'] as num?)?.toInt() ??
          ((data['basePrice'] as num?)?.toInt() ?? 299),
      category: profession,
      tags: skills,
      isOnline: online,
      distanceInKm: distanceKm,
      rawData: data,
    );
  }

  factory SearchResultItem.fromCategoryDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return SearchResultItem(
      id: doc.id,
      type: SearchItemType.category,
      title: data['name']?.toString() ?? 'Category',
      subtitle: '${data['serviceCount'] ?? 0} services',
      description: data['description']?.toString() ?? '',
      iconName: data['icon']?.toString() ?? 'category_rounded',
      rawData: data,
    );
  }
}

/// Service providing live search querying over Firestore collections
class FirestoreSearchService {
  final FirebaseFirestore _firestore;

  FirestoreSearchService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static final List<String> _recentSearches = [
    'Plumber',
    'AC Repair',
    'Deep Cleaning',
    'Electrician',
  ];

  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  void addRecentSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _recentSearches.remove(trimmed);
    _recentSearches.insert(0, trimmed);
    if (_recentSearches.length > 8) {
      _recentSearches.removeLast();
    }
  }

  void removeRecentSearch(String query) {
    _recentSearches.remove(query);
  }

  void clearRecentSearches() {
    _recentSearches.clear();
  }

  /// Stream of all active services from Firestore
  Stream<List<SearchResultItem>> streamServices() {
    return _firestore
        .collection('services')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => SearchResultItem.fromServiceDoc(d)).toList());
  }

  /// Stream of all active workers from Firestore
  Stream<List<SearchResultItem>> streamWorkers({
    double? userLat,
    double? userLng,
  }) {
    return _firestore
        .collection('workers')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => SearchResultItem.fromWorkerDoc(
                  d,
                  userLat: userLat,
                  userLng: userLng,
                ))
            .toList());
  }

  /// Combined search stream across services and workers
  Stream<List<SearchResultItem>> searchLive({
    String query = '',
    SearchItemType? filterType,
    double? userLat,
    double? userLng,
  }) {
    final cleanQuery = query.trim().toLowerCase();

    return _firestore
        .collection('services')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((servicesSnap) async {
      final List<SearchResultItem> allResults = [];

      // 1. Services
      if (filterType == null || filterType == SearchItemType.service) {
        for (final doc in servicesSnap.docs) {
          final item = SearchResultItem.fromServiceDoc(doc);
          if (_matchesQuery(item, cleanQuery)) {
            allResults.add(item);
          }
        }
      }

      // 2. Workers
      if (filterType == null || filterType == SearchItemType.worker) {
        try {
          final workersSnap = await _firestore.collection('workers').get();

          for (final doc in workersSnap.docs) {
            final item = SearchResultItem.fromWorkerDoc(
              doc,
              userLat: userLat,
              userLng: userLng,
            );
            if (_matchesQuery(item, cleanQuery)) {
              allResults.add(item);
            }
          }
        } catch (_) {}
      }

      return allResults;
    });
  }

  bool _matchesQuery(SearchResultItem item, String cleanQuery) {
    if (cleanQuery.isEmpty) return true;

    if (item.title.toLowerCase().contains(cleanQuery)) return true;
    if (item.subtitle.toLowerCase().contains(cleanQuery)) return true;
    if (item.description?.toLowerCase().contains(cleanQuery) == true) return true;
    if (item.category?.toLowerCase().contains(cleanQuery) == true) return true;

    for (final tag in item.tags) {
      if (tag.toLowerCase().contains(cleanQuery)) return true;
    }

    final city = item.rawData['city']?.toString().toLowerCase();
    if (city != null && city.contains(cleanQuery)) return true;

    return false;
  }
}
