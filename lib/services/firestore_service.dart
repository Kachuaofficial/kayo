import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'location_service.dart';

/// User profile model representing the document structure in the 'users' collection
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String role;
  final bool isVerified;
  final bool isActive;
  final Map<String, dynamic> location;
  final Map<String, dynamic> address;
  final String city;
  final String state;
  final String pincode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.uid,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.profileImage = '',
    this.role = 'customer',
    this.isVerified = false,
    this.isActive = true,
    this.location = const {'latitude': 0.0, 'longitude': 0.0},
    this.address = const {
      'house': '',
      'area': '',
      'city': '',
      'state': '',
      'pincode': '',
    },
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      return UserProfile(uid: doc.id);
    }

    final locRaw = data['location'];
    final Map<String, dynamic> locMap = (locRaw is Map)
        ? Map<String, dynamic>.from(locRaw)
        : {'latitude': 0.0, 'longitude': 0.0};

    final addrRaw = data['address'];
    final Map<String, dynamic> addrMap = (addrRaw is Map)
        ? Map<String, dynamic>.from(addrRaw)
        : {
            'house': '',
            'area': '',
            'city': '',
            'state': '',
            'pincode': '',
          };

    return UserProfile(
      uid: doc.id,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      profileImage: (data['profileImage'] as String?) ?? '',
      role: (data['role'] as String?) ?? 'customer',
      isVerified: (data['isVerified'] as bool?) ?? false,
      isActive: (data['isActive'] as bool?) ?? true,
      location: locMap,
      address: addrMap,
      city: (data['city'] as String?) ?? '',
      state: (data['state'] as String?) ?? '',
      pincode: (data['pincode'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'role': role,
      'isVerified': isVerified,
      'isActive': isActive,
      'location': location,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }
}

/// Service to manage Cloud Firestore operations
class FirestoreService {
  final FirebaseFirestore _firestore;
  final LocationService _locationService;

  FirestoreService({
    FirebaseFirestore? firestore,
    LocationService? locationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _locationService = locationService ?? LocationService();

  /// Direct instance reference if needed
  FirebaseFirestore get firestore => _firestore;

  /// Reference to the users collection
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  /// Reference to the bookings collection
  CollectionReference<Map<String, dynamic>> get bookingsCollection =>
      _firestore.collection('bookings');

  /// Reference to the services collection
  CollectionReference<Map<String, dynamic>> get servicesCollection =>
      _firestore.collection('services');

  /// Save or update user document when signing in or signing up with the requested structure:
  /// users -> userId -> {uid, name, email, phone, profileImage, role, isVerified, isActive, location, address, city, state, pincode, createdAt, updatedAt}
  Future<void> saveOrUpdateUser(
    User user, {
    String? customDisplayName,
    String? customPhone,
  }) async {
    try {
      final docRef = usersCollection.doc(user.uid);
      final doc = await docRef.get();

      // Resolve user's display name
      final resolvedName = customDisplayName?.trim().isNotEmpty == true
          ? customDisplayName!.trim()
          : (user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : (user.email != null && user.email!.contains('@')
                  ? user.email!.split('@').first
                  : ''));

      final resolvedEmail = user.email?.trim() ?? '';
      final resolvedPhone = customPhone?.trim().isNotEmpty == true
          ? customPhone!.trim()
          : (user.phoneNumber?.trim() ?? '');
      final resolvedPhoto = user.photoURL?.trim() ?? '';
      final isVerified = user.emailVerified;

      // Optionally fetch location details if available
      LocationDetails? locDetails;
      try {
        locDetails = await _locationService.getCurrentLocationDetails();
      } catch (_) {}

      if (!doc.exists) {
        // Document does not exist: create complete user profile
        final locationMap = <String, dynamic>{
          'latitude': locDetails?.latitude ?? 0.0,
          'longitude': locDetails?.longitude ?? 0.0,
        };

        final cityVal = locDetails?.city ?? '';
        final stateVal = locDetails?.state ?? '';
        final pincodeVal = locDetails?.pincode ?? '';

        final addressMap = <String, dynamic>{
          'house': locDetails?.house ?? '',
          'area': locDetails?.area ?? '',
          'city': cityVal,
          'state': stateVal,
          'pincode': pincodeVal,
        };

        await docRef.set({
          'uid': user.uid,
          'name': resolvedName,
          'email': resolvedEmail,
          'phone': resolvedPhone,
          'profileImage': resolvedPhoto,
          'role': 'customer',
          'isVerified': isVerified,
          'isActive': true,
          'location': locationMap,
          'address': addressMap,
          'city': cityVal,
          'state': stateVal,
          'pincode': pincodeVal,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Document exists: update relevant fields & updatedAt timestamp
        final existingData = doc.data() ?? {};
        final updates = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
          'isVerified': isVerified,
        };

        if (resolvedName.isNotEmpty &&
            (existingData['name'] == null ||
                (existingData['name'] as String).isEmpty)) {
          updates['name'] = resolvedName;
        }

        if (resolvedEmail.isNotEmpty) {
          updates['email'] = resolvedEmail;
        }

        if (resolvedPhoto.isNotEmpty) {
          updates['profileImage'] = resolvedPhoto;
        }

        if (resolvedPhone.isNotEmpty &&
            (existingData['phone'] == null ||
                (existingData['phone'] as String).isEmpty)) {
          updates['phone'] = resolvedPhone;
        }

        // If location was obtained and was previously empty/default
        if (locDetails != null &&
            locDetails.latitude != null &&
            locDetails.longitude != null) {
          final existingLoc = existingData['location'] as Map?;
          final lat = existingLoc?['latitude'] as num?;
          if (lat == null || lat == 0.0) {
            updates['location'] = {
              'latitude': locDetails.latitude!,
              'longitude': locDetails.longitude!,
            };
          }

          if ((existingData['city'] == null ||
                  (existingData['city'] as String).isEmpty) &&
              locDetails.city?.isNotEmpty == true) {
            updates['city'] = locDetails.city!;
          }

          if ((existingData['state'] == null ||
                  (existingData['state'] as String).isEmpty) &&
              locDetails.state?.isNotEmpty == true) {
            updates['state'] = locDetails.state!;
          }

          if ((existingData['pincode'] == null ||
                  (existingData['pincode'] as String).isEmpty) &&
              locDetails.pincode?.isNotEmpty == true) {
            updates['pincode'] = locDetails.pincode!;
          }

          final existingAddr = existingData['address'] as Map?;
          if (existingAddr == null || (existingAddr['city'] as String?)?.isEmpty == true) {
            updates['address'] = {
              'house': locDetails.house ?? '',
              'area': locDetails.area ?? '',
              'city': locDetails.city ?? '',
              'state': locDetails.state ?? '',
              'pincode': locDetails.pincode ?? '',
            };
          }
        }

        await docRef.update(updates);
      }
    } catch (e) {
      // Avoid failing authentication if firestore write has transient issues
    }
  }

  /// Get user profile by UID
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  /// Stream user profile in real-time
  Stream<UserProfile?> streamUserProfile(String uid) {
    return usersCollection.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserProfile.fromFirestore(snapshot);
    });
  }

  /// Update user profile fields directly
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await usersCollection.doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Create a new booking in Firestore
  Future<DocumentReference<Map<String, dynamic>>> createBooking({
    required String userId,
    required String serviceTitle,
    required Map<String, dynamic> bookingDetails,
  }) async {
    return await bookingsCollection.add({
      'userId': userId,
      'serviceTitle': serviceTitle,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      ...bookingDetails,
    });
  }

  /// Stream bookings for a specific user
  Stream<QuerySnapshot<Map<String, dynamic>>> streamUserBookings(String userId) {
    return bookingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
