import 'package:cloud_firestore/cloud_firestore.dart';

/// In-app Firestore seeder for populating realistic demo data directly from Flutter.
class FirestoreSeeder {
  final FirebaseFirestore _firestore;

  FirestoreSeeder({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, int>> seedAll() async {
    final now = DateTime.now();

    // 1. SERVICES
    final services = {
      'service_plumbing': {
        'name': 'Plumbing',
        'description': 'Professional pipe repair, leakage fixing, drainage and tap installation.',
        'icon': 'plumbing_rounded',
        'category': 'home_repair',
        'basePrice': 299,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'service_electrician': {
        'name': 'Electrician',
        'description': 'Electrical wiring, switchboard fixing, fan installation, and short-circuit repair.',
        'icon': 'electrical_services_rounded',
        'category': 'electrical',
        'basePrice': 249,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'service_cleaning': {
        'name': 'Cleaning',
        'description': 'Full home deep cleaning, kitchen sanitization, sofa and bathroom cleaning.',
        'icon': 'cleaning_services_rounded',
        'category': 'cleaning',
        'basePrice': 499,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'service_carpenter': {
        'name': 'Carpenter',
        'description': 'Custom furniture repair, lock replacement, door hinge alignment, and woodwork.',
        'icon': 'handyman_rounded',
        'category': 'woodwork',
        'basePrice': 349,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'service_painting': {
        'name': 'Painting',
        'description': 'Interior & exterior wall painting, waterproof coating, and texture designs.',
        'icon': 'format_paint_rounded',
        'category': 'painting',
        'basePrice': 799,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'service_mechanic': {
        'name': 'Mechanic',
        'description': 'On-demand two-wheeler & four-wheeler repair, puncture fix, and oil service.',
        'icon': 'car_repair_rounded',
        'category': 'automotive',
        'basePrice': 399,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'service_gardening': {
        'name': 'Gardening',
        'description': 'Lawn mowing, flower bed maintenance, hedge trimming, and organic plant care.',
        'icon': 'yard_rounded',
        'category': 'outdoor',
        'basePrice': 299,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'service_ac_repair': {
        'name': 'AC Repair',
        'description': 'AC servicing, cooling issues, gas leakage refill, and copper piping inspection.',
        'icon': 'ac_unit_rounded',
        'category': 'appliances',
        'basePrice': 599,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'service_appliance_repair': {
        'name': 'Appliance Repair',
        'description': 'Expert repair for refrigerators, washing machines, geysers, and microwaves.',
        'icon': 'home_repair_service_rounded',
        'category': 'appliances',
        'basePrice': 399,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'service_caregiver': {
        'name': 'Home Care',
        'description': 'Trained elderly assistance, post-surgery home nursing, and personal care.',
        'icon': 'home_rounded',
        'category': 'care',
        'basePrice': 699,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    };

    // 2. USERS
    final userNames = [
      ['Aarav Sharma', 'aarav.sharma@example.com', '+919876543201', '12A', 'Civil Lines', 'Gorakhpur', 'Uttar Pradesh', '273001', 26.7606, 83.3732],
      ['Pooja Patel', 'pooja.patel@example.com', '+919876543202', '45B', 'Golghar', 'Gorakhpur', 'Uttar Pradesh', '273001', 26.7562, 83.3789],
      ['Rohan Gupta', 'rohan.gupta@example.com', '+919876543203', '88/2', 'Betiahata', 'Gorakhpur', 'Uttar Pradesh', '273001', 26.7490, 83.3680],
      ['Sneha Verma', 'sneha.verma@example.com', '+919876543204', '104', 'Medical College Road', 'Gorakhpur', 'Uttar Pradesh', '273013', 26.7925, 83.3980],
      ['Vikram Singh', 'vikram.singh@example.com', '+919876543205', '23', 'Rustampur', 'Gorakhpur', 'Uttar Pradesh', '273016', 26.7320, 83.3850],
      ['Ananya Reddy', 'ananya.reddy@example.com', '+919876543206', '7G', 'Taramandal', 'Gorakhpur', 'Uttar Pradesh', '273010', 26.7280, 83.3950],
      ['Rahul Joshi', 'rahul.joshi@example.com', '+919876543207', '51', 'Mohaddipur', 'Gorakhpur', 'Uttar Pradesh', '273008', 26.7540, 83.4020],
      ['Meera Nair', 'meera.nair@example.com', '+919876543208', '19', 'Shahpur', 'Gorakhpur', 'Uttar Pradesh', '273004', 26.7750, 83.3600],
      ['Aditya Chopra', 'aditya.chopra@example.com', '+919876543209', '302', 'Alinagar', 'Gorakhpur', 'Uttar Pradesh', '273001', 26.7620, 83.3650],
      ['Kavita Rao', 'kavita.rao@example.com', '+919876543210', '64', 'Basharatpur', 'Gorakhpur', 'Uttar Pradesh', '273004', 26.7810, 83.3820],
    ];

    final users = <String, Map<String, dynamic>>{};
    for (int i = 0; i < userNames.length; i++) {
      final u = userNames[i];
      final uid = 'user_${(i + 1).toString().padLeft(3, '0')}';
      users[uid] = {
        'uid': uid,
        'name': u[0],
        'email': u[1],
        'phone': u[2],
        'profileImage': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&fit=crop&crop=faces',
        'role': 'customer',
        'isVerified': true,
        'isActive': true,
        'location': {'latitude': u[8], 'longitude': u[9]},
        'address': {
          'house': u[3],
          'area': u[4],
          'city': u[5],
          'state': u[6],
          'pincode': u[7],
        },
        'city': u[5],
        'state': u[6],
        'pincode': u[7],
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 30 - i * 2))),
        'updatedAt': Timestamp.fromDate(now.subtract(Duration(days: i))),
      };
    }

    // 3. WORKERS
    final workerSpecs = [
      ['Rajesh Kumar', 'Electrician', 'service_electrician', ['Electrical Repair', 'Wiring', 'Fan Installation', 'MCB Fix'], 4.9, 142, 6],
      ['Amit Singh', 'Electrician', 'service_electrician', ['Inverter Wiring', 'Switchboard Fitting', 'Lighting'], 4.8, 98, 4],
      ['Vikas Yadav', 'Plumber', 'service_plumbing', ['Pipe Leakage', 'Tap Replacement', 'Geyser Fitting', 'Sanitary'], 4.8, 120, 5],
      ['Mohit Verma', 'Plumber', 'service_plumbing', ['Drainage Cleaning', 'Water Tank Installation', 'Pipeline Repair'], 4.7, 85, 4],
      ['Priya Sharma', 'Cleaner', 'service_cleaning', ['Deep Home Cleaning', 'Kitchen Degreasing', 'Bathroom Disinfection'], 4.9, 175, 5],
      ['Suresh Das', 'Cleaner', 'service_cleaning', ['Sofa Shampooing', 'Floor Polishing', 'Carpet Cleaning'], 4.7, 64, 3],
      ['Ramesh Chand', 'Carpenter', 'service_carpenter', ['Furniture Assembly', 'Door Lock Fitting', 'Modular Kitchen Woodwork'], 4.9, 210, 9],
      ['Sunil Vishwakarma', 'Carpenter', 'service_carpenter', ['Bed Repair', 'Custom Shelving', 'Hinges & Handles'], 4.8, 115, 6],
      ['Dinesh Maurya', 'Painter', 'service_painting', ['Interior Wall Painting', 'Waterproofing', 'Texture Painting'], 4.8, 130, 7],
      ['Deepak Saini', 'Painter', 'service_painting', ['Exterior Whitewash', 'Wood Polishing', 'Color Consultation'], 4.6, 72, 3],
      ['Manoj Tiwari', 'Mechanic', 'service_mechanic', ['Two Wheeler Service', 'Car Breakdown', 'Engine Diagnostics'], 4.8, 156, 8],
      ['Anil Mishra', 'Mechanic', 'service_mechanic', ['Brake Repair', 'Oil Change', 'Puncture Assistance'], 4.7, 90, 4],
      ['Pankaj Pandey', 'Gardener', 'service_gardening', ['Lawn Mowing', 'Tree Trimming', 'Garden Landscaping'], 4.9, 88, 5],
      ['Santosh Gupta', 'Gardener', 'service_gardening', ['Plant Nursery Setup', 'Pesticide Spraying', 'Fertilizer Addition'], 4.7, 54, 3],
      ['Vijay Kushwaha', 'AC Technician', 'service_ac_repair', ['Split AC Service', 'Gas Filling', 'Cooling Coil Repair'], 4.9, 230, 8],
      ['Karan Kanojia', 'AC Technician', 'service_ac_repair', ['Window AC Installation', 'Thermostat Replacement', 'Filter Cleaning'], 4.8, 110, 5],
      ['Arun Chauhan', 'Appliance Repair', 'service_appliance_repair', ['Refrigerator Gas Leak', 'Washing Machine Motor', 'Microwave'], 4.8, 140, 6],
      ['Mukesh Dubey', 'Appliance Repair', 'service_appliance_repair', ['Water Purifier Service', 'Geyser Element', 'Mixer Repair'], 4.7, 78, 4],
      ['Harish Rawat', 'Home Care', 'service_caregiver', ['Elderly Care', 'Mobility Assistance', 'Health Routine Support'], 4.9, 95, 6],
      ['Gaurav Tripathi', 'Home Care', 'service_caregiver', ['Patient Care', 'Post-Op Monitoring', 'Daily Wellness'], 4.9, 105, 7],
    ];

    final workers = <String, Map<String, dynamic>>{};
    for (int i = 0; i < workerSpecs.length; i++) {
      final w = workerSpecs[i];
      final wid = 'worker_${(i + 1).toString().padLeft(3, '0')}';
      final emailPrefix = (w[0] as String).toLowerCase().replaceAll(' ', '.');
      workers[wid] = {
        'uid': wid,
        'name': w[0],
        'email': '$emailPrefix@savia-workers.com',
        'phone': '+919812345${(i + 1).toString().padLeft(3, '0')}',
        'profileImage': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&fit=crop&crop=faces',
        'role': 'worker',
        'profession': w[1],
        'isVerified': true,
        'isActive': true,
        'isAvailable': (i % 5 != 0),
        'rating': w[4],
        'totalJobs': w[5],
        'experienceYears': w[6],
        'skills': w[3],
        'serviceIds': [w[2]],
        'location': {
          'latitude': 26.7550 + (i * 0.002),
          'longitude': 83.3750 + (i * 0.002),
        },
        'serviceAreas': ['Civil Lines', 'Golghar', 'Betiahata', 'Medical College Road', 'Gorakhpur'],
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 90 - i * 2))),
        'updatedAt': Timestamp.fromDate(now.subtract(Duration(days: i))),
      };
    }

    // 4. BOOKINGS (25 bookings)
    final bookingConfigs = [
      [1, 1, 'service_electrician', 'completed', 450, -14, 'Master bedroom main switchboard repair and fan regulator replacement.'],
      [2, 5, 'service_cleaning', 'completed', 899, -13, 'Full 3BHK deep cleaning before family festival.'],
      [3, 3, 'service_plumbing', 'completed', 350, -12, 'Kitchen sink drainage pipe unclogging and tap seal replacement.'],
      [4, 7, 'service_carpenter', 'completed', 650, -11, 'Main door lock replacement with digital smart lock setup.'],
      [5, 9, 'service_painting', 'completed', 1200, -10, 'Living room feature wall texture painting with waterproof primer.'],
      [6, 11, 'service_mechanic', 'completed', 550, -9, 'Activa 6G general service, brake tightening and oil filter replacement.'],
      [7, 15, 'service_ac_repair', 'completed', 950, -8, 'Split AC deep jet pump service and coolant gas top-up.'],
      [8, 17, 'service_appliance_repair', 'completed', 400, -7, 'LG Front load washing machine vibration diagnosis.'],
      [9, 19, 'service_caregiver', 'completed', 1200, -6, 'Elderly home assistance and mobility routine support.'],
      [10, 13, 'service_gardening', 'completed', 350, -5, 'Trimming front lawn grass and rose plant pruning.'],
      [1, 2, 'service_electrician', 'completed', 500, -4, 'Installing 4 new LED ceiling panel lights in hall.'],
      [2, 4, 'service_plumbing', 'completed', 400, -3, 'Bathroom geyser outlet hot water pipe leaking fix.'],
      [3, 6, 'service_cleaning', 'completed', 750, -2, 'Sofa set dry cleaning and carpet sanitization.'],
      [4, 8, 'service_carpenter', 'completed', 450, -1, 'Wardrobe hinge repair and drawer slider replacement.'],
      [5, 16, 'service_ac_repair', 'completed', 800, -1, 'Bedroom 1.5 ton AC cooling coil check.'],
      [6, 10, 'service_painting', 'in_progress', 1400, 0, 'Balcony railing rust cleaning and weather coat repaint.'],
      [7, 18, 'service_appliance_repair', 'in_progress', 450, 0, 'Samsung Double Door Refrigerator defrost timer replacement.'],
      [8, 20, 'service_caregiver', 'worker_on_way', 1500, 0, 'Weekend post-op patient care and vitals tracking.'],
      [9, 12, 'service_mechanic', 'arrived', 600, 0, 'Royal Enfield Classic 350 battery check & clutch adjustment.'],
      [10, 14, 'service_gardening', 'confirmed', 300, 1, 'Fertilizer distribution and flower bed maintenance.'],
      [1, 15, 'service_ac_repair', 'confirmed', 1100, 2, 'Outdoor compressor capacitor replacement.'],
      [2, 7, 'service_carpenter', 'accepted', 550, 2, 'Wooden dining chair leg joint fixing and polishing.'],
      [3, 1, 'service_electrician', 'requested', 350, 3, 'Inverter backup connection check in garage.'],
      [4, 3, 'service_plumbing', 'cancelled', 300, -15, 'Customer rescheduled due to sudden travel.'],
      [5, 5, 'service_cleaning', 'rejected', 800, -16, 'Worker was already booked for requested slot.'],
    ];

    final bookings = <String, Map<String, dynamic>>{};
    for (int i = 0; i < bookingConfigs.length; i++) {
      final bc = bookingConfigs[i];
      final bid = 'booking_${(i + 1).toString().padLeft(3, '0')}';
      final uId = 'user_${(bc[0] as int).toString().padLeft(3, '0')}';
      final wId = 'worker_${(bc[1] as int).toString().padLeft(3, '0')}';
      final userInfo = users[uId]!;
      final daysOffset = bc[5] as int;
      final schedDate = now.add(Duration(days: daysOffset, hours: (i % 8) + 9));

      bookings[bid] = {
        'bookingId': bid,
        'customerId': uId,
        'workerId': wId,
        'serviceId': bc[2],
        'status': bc[3],
        'scheduledAt': Timestamp.fromDate(schedDate),
        'amount': bc[4],
        'address': userInfo['address'],
        'location': userInfo['location'],
        'notes': bc[6],
        'createdAt': Timestamp.fromDate(schedDate.subtract(const Duration(days: 2))),
        'updatedAt': Timestamp.fromDate(schedDate),
      };
    }

    // 5. REVIEWS (15 reviews for completed bookings)
    final completedBids = bookings.entries
        .where((e) => e.value['status'] == 'completed')
        .map((e) => e.key)
        .toList();

    final reviews = <String, Map<String, dynamic>>{};
    final reviewTemplates = [
      [4, ['✨ Professional', '⚡ On time', '🛠 Great work'], 'Fantastic job! Arrived strictly on time, brought all necessary tools and finished cleanly.'],
      [4, ['✨ Professional', '🛠 Great work', '😊 Friendly'], 'Extremely polite and knowledgeable. Explained the issue clearly and fixed it in 30 minutes.'],
      [3, ['⚡ On time', '💰 Fair price'], 'Very satisfied with the quick response and reasonable pricing. Good service overall.'],
      [4, ['✨ Professional', '🧹 Clean work', '🛠 Great work'], 'Top notch work quality! Cleaned the area after completing the installation. 5 stars experience.'],
      [3, ['🛠 Great work', '😊 Friendly'], 'Great communication and very skilled. Fixed our long pending problem efficiently.'],
      [4, ['✨ Professional', '⚡ On time', '💰 Fair price'], 'Great experience with Savia. Genuine spare parts used and bill was transparent.'],
      [4, ['🧹 Clean work', '✨ Professional'], 'Very neat and thorough work. Will definitely book again through Savia for any home services.'],
    ];

    for (int i = 0; i < completedBids.length && i < 15; i++) {
      final bid = completedBids[i];
      final rid = 'review_${(i + 1).toString().padLeft(3, '0')}';
      final b = bookings[bid]!;
      final tmpl = reviewTemplates[i % reviewTemplates.length];
      final schedAt = (b['scheduledAt'] as Timestamp).toDate();

      reviews[rid] = {
        'reviewId': rid,
        'bookingId': bid,
        'customerId': b['customerId'],
        'workerId': b['workerId'],
        'experience': tmpl[0],
        'tags': tmpl[1],
        'comment': tmpl[2],
        'createdAt': Timestamp.fromDate(schedAt.add(const Duration(hours: 2))),
      };
    }

    // 6. PAYMENTS (25 payments)
    final payments = <String, Map<String, dynamic>>{};
    final methods = ['upi', 'razorpay', 'card', 'cash'];
    int pIdx = 1;
    for (final entry in bookings.entries) {
      final bid = entry.key;
      final b = entry.value;
      final pid = 'payment_${pIdx.toString().padLeft(3, '0')}';

      String pStatus = 'paid';
      if (b['status'] == 'cancelled') {
        pStatus = 'refunded';
      } else if (b['status'] == 'rejected') {
        pStatus = 'failed';
      } else if (b['status'] == 'confirmed' || b['status'] == 'accepted') {
        pStatus = pIdx % 2 == 0 ? 'processing' : 'pending';
      }

      payments[pid] = {
        'paymentId': pid,
        'bookingId': bid,
        'customerId': b['customerId'],
        'workerId': b['workerId'],
        'amount': b['amount'],
        'currency': 'INR',
        'status': pStatus,
        'paymentMethod': methods[(pIdx - 1) % methods.length],
        'createdAt': b['createdAt'],
        'updatedAt': b['updatedAt'],
      };
      pIdx++;
    }

    // 7. NOTIFICATIONS (30 notifications)
    final notifications = <String, Map<String, dynamic>>{};
    int nCount = 1;
    for (final entry in bookings.entries.take(15)) {
      final bid = entry.key;
      final b = entry.value;
      final nid = 'notification_${nCount.toString().padLeft(3, '0')}';
      final sName = services[b['serviceId']]?['name'] ?? 'Service';

      notifications[nid] = {
        'notificationId': nid,
        'userId': b['customerId'],
        'title': 'Booking Update: $sName',
        'message': 'Your $sName booking (#${bid.substring(bid.length - 3)}) status is now ${b['status']}.',
        'type': 'booking',
        'isRead': nCount % 2 == 0,
        'createdAt': b['updatedAt'],
      };
      nCount++;
    }

    final promoTemplates = [
      ['Festive Discount 20% OFF 🎉', 'Get flat 20% discount on AC repair and deep cleaning services this week using code SAVIA20.', 'promotion'],
      ['Welcome to Savia ✨', 'Book background-verified local technicians and home service professionals easily.', 'system'],
      ['Monsoon Home Care Tips ☔', 'Protect your home from seepage and dampness with verified waterproof painting experts.', 'service'],
    ];

    while (nCount <= 30) {
      final uid = 'user_${(((nCount - 1) % users.length) + 1).toString().padLeft(3, '0')}';
      final nid = 'notification_${nCount.toString().padLeft(3, '0')}';
      final p = promoTemplates[(nCount - 1) % promoTemplates.length];
      notifications[nid] = {
        'notificationId': nid,
        'userId': uid,
        'title': p[0],
        'message': p[1],
        'type': p[2],
        'isRead': false,
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: nCount % 10))),
      };
      nCount++;
    }

    // Write all to Firestore in batches
    final batch = _firestore.batch();

    for (final e in services.entries) {
      batch.set(_firestore.collection('services').doc(e.key), e.value, SetOptions(merge: true));
    }
    for (final e in users.entries) {
      batch.set(_firestore.collection('users').doc(e.key), e.value, SetOptions(merge: true));
    }
    for (final e in workers.entries) {
      batch.set(_firestore.collection('workers').doc(e.key), e.value, SetOptions(merge: true));
    }
    for (final e in bookings.entries) {
      batch.set(_firestore.collection('bookings').doc(e.key), e.value, SetOptions(merge: true));
    }
    for (final e in payments.entries) {
      batch.set(_firestore.collection('payments').doc(e.key), e.value, SetOptions(merge: true));
    }
    for (final e in reviews.entries) {
      batch.set(_firestore.collection('reviews').doc(e.key), e.value, SetOptions(merge: true));
    }
    for (final e in notifications.entries) {
      batch.set(_firestore.collection('notifications').doc(e.key), e.value, SetOptions(merge: true));
    }

    await batch.commit();

    return {
      'users': users.length,
      'workers': workers.length,
      'services': services.length,
      'bookings': bookings.length,
      'payments': payments.length,
      'reviews': reviews.length,
      'notifications': notifications.length,
    };
  }
}
