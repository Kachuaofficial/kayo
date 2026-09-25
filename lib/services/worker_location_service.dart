import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/worker_model.dart';

class WorkerLocationService {
  final FirebaseFirestore _firestore;

  WorkerLocationService({
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Default search radius in kilometers
  static const double defaultRadiusKm = 25.0;

  /// Available preset radius filters in km
  static const List<double> radiusOptions = [5.0, 10.0, 25.0, 50.0, 100.0];

  /// Get current user coordinates safely
  Future<Position?> getUserPosition() async {
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

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Real-time stream of online workers within specified distance radius
  Stream<List<WorkerModel>> streamNearbyOnlineWorkers({
    Position? userPosition,
    double radiusKm = defaultRadiusKm,
    bool onlyOnline = true,
    String? categoryFilter,
    String? searchQuery,
  }) {
    return _firestore.collection('workers').snapshots().map((snapshot) {
      final userLat = userPosition?.latitude;
      final userLng = userPosition?.longitude;

      final cleanQuery = searchQuery?.trim().toLowerCase();
      final cleanCategory = categoryFilter?.trim().toLowerCase();

      final List<WorkerModel> nearbyWorkers = [];

      for (final doc in snapshot.docs) {
        final worker = WorkerModel.fromFirestore(
          doc,
          userLat: userLat,
          userLng: userLng,
        );

        // 1. Online Filter: Must be currently active/online
        if (onlyOnline && !worker.isOnline) {
          continue;
        }

        // 2. Distance Radius Filter
        if (worker.distanceInKm != null && radiusKm < 1000.0) {
          if (worker.distanceInKm! > radiusKm) {
            continue;
          }
        }

        // 3. Category Filter
        if (cleanCategory != null && cleanCategory.isNotEmpty && cleanCategory != 'all') {
          final prof = worker.profession.toLowerCase();
          final skills = worker.skills.map((s) => s.toLowerCase()).toList();
          final match = prof.contains(cleanCategory) ||
              skills.any((s) => s.contains(cleanCategory));
          if (!match) continue;
        }

        // 4. Search Query Filter
        if (cleanQuery != null && cleanQuery.isNotEmpty) {
          final name = worker.name.toLowerCase();
          final prof = worker.profession.toLowerCase();
          final city = (worker.city ?? '').toLowerCase();
          final skills = worker.skills.map((s) => s.toLowerCase()).toList();

          final match = name.contains(cleanQuery) ||
              prof.contains(cleanQuery) ||
              city.contains(cleanQuery) ||
              skills.any((s) => s.contains(cleanQuery));

          if (!match) continue;
        }

        nearbyWorkers.add(worker);
      }

      // Sort by nearest distance first, fallback to highest rating
      nearbyWorkers.sort((a, b) {
        if (a.distanceInKm != null && b.distanceInKm != null) {
          return a.distanceInKm!.compareTo(b.distanceInKm!);
        }
        if (a.distanceInKm != null) return -1;
        if (b.distanceInKm != null) return 1;
        return b.rating.compareTo(a.rating);
      });

      return nearbyWorkers;
    });
  }
}
