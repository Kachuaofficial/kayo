#!/usr/bin/env python3
"""
Savia Firestore Seeding Script
Populates Cloud Firestore with realistic demo data for Savia:
- users (10 documents)
- workers (20 documents)
- services (10 documents)
- bookings (25 documents)
- payments (25 documents)
- reviews (15 documents)
- notifications (30 documents)

Usage:
    python scripts/seed_firestore.py [PATH_TO_SERVICE_ACCOUNT_JSON]

Example:
    python scripts/seed_firestore.py ./serviceAccountKey.json
"""

import sys
import os
from datetime import datetime, timedelta, timezone

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print("Error: 'firebase-admin' package is not installed.")
    print("Please install it by running: pip install firebase-admin")
    sys.exit(1)


def find_service_account_path() -> str:
    # 1. Command-line argument
    if len(sys.argv) > 1 and sys.argv[1].endswith(".json"):
        return sys.argv[1]

    # 2. Environment variable
    env_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS") or os.environ.get("FIREBASE_SERVICE_ACCOUNT")
    if env_path and os.path.isfile(env_path):
        return env_path

    # 3. Look in local directory
    candidates = [
        "serviceAccountKey.json",
        "service-account.json",
        "firebase-adminsdk.json",
        "scripts/serviceAccountKey.json",
        "../serviceAccountKey.json",
    ]
    for candidate in candidates:
        if os.path.isfile(candidate):
            return candidate

    return ""


def initialize_db():
    sa_path = find_service_account_path()

    if not sa_path:
        print("=" * 60)
        print("ERROR: Service account JSON file not found.")
        print("Please provide the path as an argument or environment variable:")
        print("  python scripts/seed_firestore.py path/to/serviceAccountKey.json")
        print("=" * 60)
        sys.exit(1)

    print(f"Initializing Firebase Admin SDK using: {sa_path}")
    cred = credentials.Certificate(sa_path)
    firebase_admin.initialize_app(cred)
    return firestore.client()


def build_data():
    now = datetime.now(timezone.utc)

    # -------------------------------------------------------------------------
    # 1. SERVICES (10 categories)
    # -------------------------------------------------------------------------
    services = {
        "service_plumbing": {
            "name": "Plumbing",
            "description": "Professional pipe repair, leakage fixing, drainage and tap installation.",
            "icon": "plumbing_rounded",
            "category": "home_repair",
            "basePrice": 299,
            "isActive": True,
            "createdAt": now - timedelta(days=60),
            "updatedAt": now,
        },
        "service_electrician": {
            "name": "Electrician",
            "description": "Electrical wiring, switchboard fixing, fan installation, and short-circuit repair.",
            "icon": "electrical_services_rounded",
            "category": "electrical",
            "basePrice": 249,
            "isActive": True,
            "createdAt": now - timedelta(days=60),
            "updatedAt": now,
        },
        "service_cleaning": {
            "name": "Cleaning",
            "description": "Full home deep cleaning, kitchen sanitization, sofa and bathroom cleaning.",
            "icon": "cleaning_services_rounded",
            "category": "cleaning",
            "basePrice": 499,
            "isActive": True,
            "createdAt": now - timedelta(days=60),
            "updatedAt": now,
        },
        "service_carpenter": {
            "name": "Carpenter",
            "description": "Custom furniture repair, lock replacement, door hinge alignment, and woodwork.",
            "icon": "handyman_rounded",
            "category": "woodwork",
            "basePrice": 349,
            "isActive": True,
            "createdAt": now - timedelta(days=60),
            "updatedAt": now,
        },
        "service_painting": {
            "name": "Painting",
            "description": "Interior & exterior wall painting, waterproof coating, and texture designs.",
            "icon": "format_paint_rounded",
            "category": "painting",
            "basePrice": 799,
            "isActive": True,
            "createdAt": now - timedelta(days=60),
            "updatedAt": now,
        },
        "service_mechanic": {
            "name": "Mechanic",
            "description": "On-demand two-wheeler & four-wheeler repair, puncture fix, and oil service.",
            "icon": "car_repair_rounded",
            "category": "automotive",
            "basePrice": 399,
            "isActive": True,
            "createdAt": now - timedelta(days=60),
            "updatedAt": now,
        },
        "service_gardening": {
            "name": "Gardening",
            "description": "Lawn mowing, flower bed maintenance, hedge trimming, and organic plant care.",
            "icon": "yard_rounded",
            "category": "outdoor",
            "basePrice": 299,
            "isActive": True,
            "createdAt": now - timedelta(days=60),
            "updatedAt": now,
        },
        "service_ac_repair": {
            "name": "AC Repair",
            "description": "AC servicing, cooling issues, gas leakage refill, and copper piping inspection.",
            "icon": "ac_unit_rounded",
            "category": "appliances",
            "basePrice": 599,
            "isActive": True,
            "createdAt": now - timedelta(days=60),
            "updatedAt": now,
        },
        "service_appliance_repair": {
            "name": "Appliance Repair",
            "description": "Expert repair for refrigerators, washing machines, geysers, and microwaves.",
            "icon": "home_repair_service_rounded",
            "category": "appliances",
            "basePrice": 399,
            "isActive": True,
            "createdAt": now - timedelta(days=60),
            "updatedAt": now,
        },
        "service_caregiver": {
            "name": "Home Care",
            "description": "Trained elderly assistance, post-surgery home nursing, and personal care.",
            "icon": "home_rounded",
            "category": "care",
            "basePrice": 699,
            "isActive": True,
            "createdAt": now - timedelta(days=60),
            "updatedAt": now,
        },
    }

    # -------------------------------------------------------------------------
    # 2. USERS (10 realistic demo customers)
    # -------------------------------------------------------------------------
    user_names = [
        ("Aarav Sharma", "aarav.sharma@example.com", "+919876543201", "12A", "Civil Lines", "Gorakhpur", "Uttar Pradesh", "273001", 26.7606, 83.3732),
        ("Pooja Patel", "pooja.patel@example.com", "+919876543202", "45B", "Golghar", "Gorakhpur", "Uttar Pradesh", "273001", 26.7562, 83.3789),
        ("Rohan Gupta", "rohan.gupta@example.com", "+919876543203", "88/2", "Betiahata", "Gorakhpur", "Uttar Pradesh", "273001", 26.7490, 83.3680),
        ("Sneha Verma", "sneha.verma@example.com", "+919876543204", "104", "Medical College Road", "Gorakhpur", "Uttar Pradesh", "273013", 26.7925, 83.3980),
        ("Vikram Singh", "vikram.singh@example.com", "+919876543205", "23", "Rustampur", "Gorakhpur", "Uttar Pradesh", "273016", 26.7320, 83.3850),
        ("Ananya Reddy", "ananya.reddy@example.com", "+919876543206", "7G", "Taramandal", "Gorakhpur", "Uttar Pradesh", "273010", 26.7280, 83.3950),
        ("Rahul Joshi", "rahul.joshi@example.com", "+919876543207", "51", "Mohaddipur", "Gorakhpur", "Uttar Pradesh", "273008", 26.7540, 83.4020),
        ("Meera Nair", "meera.nair@example.com", "+919876543208", "19", "Shahpur", "Gorakhpur", "Uttar Pradesh", "273004", 26.7750, 83.3600),
        ("Aditya Chopra", "aditya.chopra@example.com", "+919876543209", "302", "Alinagar", "Gorakhpur", "Uttar Pradesh", "273001", 26.7620, 83.3650),
        ("Kavita Rao", "kavita.rao@example.com", "+919876543210", "64", "Basharatpur", "Gorakhpur", "Uttar Pradesh", "273004", 26.7810, 83.3820),
    ]

    users = {}
    for i, (name, email, phone, house, area, city, state, pincode, lat, lon) in enumerate(user_names, 1):
        uid = f"user_{i:03d}"
        users[uid] = {
            "uid": uid,
            "name": name,
            "email": email,
            "phone": phone,
            "profileImage": f"https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&fit=crop&crop=faces",
            "role": "customer",
            "isVerified": True,
            "isActive": True,
            "location": {
                "latitude": lat,
                "longitude": lon,
            },
            "address": {
                "house": house,
                "area": area,
                "city": city,
                "state": state,
                "pincode": pincode,
            },
            "city": city,
            "state": state,
            "pincode": pincode,
            "createdAt": now - timedelta(days=30 - i * 2),
            "updatedAt": now - timedelta(days=i),
        }

    # -------------------------------------------------------------------------
    # 2. WORKERS (20 demo workers across all professions)
    # -------------------------------------------------------------------------
    worker_specs = [
        ("Rajesh Kumar", "Electrician", "service_electrician", ["Electrical Repair", "Wiring", "Fan Installation", "MCB Fix"], 4.9, 142, 6),
        ("Amit Singh", "Electrician", "service_electrician", ["Inverter Wiring", "Switchboard Fitting", "Lighting"], 4.8, 98, 4),
        ("Vikas Yadav", "Plumber", "service_plumbing", ["Pipe Leakage", "Tap Replacement", "Geyser Fitting", "Sanitary"], 4.8, 120, 5),
        ("Mohit Verma", "Plumber", "service_plumbing", ["Drainage Cleaning", "Water Tank Installation", "Pipeline Repair"], 4.7, 85, 4),
        ("Priya Sharma", "Cleaner", "service_cleaning", ["Deep Home Cleaning", "Kitchen Degreasing", "Bathroom Disinfection"], 4.9, 175, 5),
        ("Suresh Das", "Cleaner", "service_cleaning", ["Sofa Shampooing", "Floor Polishing", "Carpet Cleaning"], 4.7, 64, 3),
        ("Ramesh Chand", "Carpenter", "service_carpenter", ["Furniture Assembly", "Door Lock Fitting", "Modular Kitchen Woodwork"], 4.9, 210, 9),
        ("Sunil Vishwakarma", "Carpenter", "service_carpenter", ["Bed Repair", "Custom Shelving", "Hinges & Handles"], 4.8, 115, 6),
        ("Dinesh Maurya", "Painter", "service_painting", ["Interior Wall Painting", "Waterproofing", "Texture Painting"], 4.8, 130, 7),
        ("Deepak Saini", "Painter", "service_painting", ["Exterior Whitewash", "Wood Polishing", "Color Consultation"], 4.6, 72, 3),
        ("Manoj Tiwari", "Mechanic", "service_mechanic", ["Two Wheeler Service", "Car Breakdown", "Engine Diagnostics"], 4.8, 156, 8),
        ("Anil Mishra", "Mechanic", "service_mechanic", ["Brake Repair", "Oil Change", "Puncture Assistance"], 4.7, 90, 4),
        ("Pankaj Pandey", "Gardener", "service_gardening", ["Lawn Mowing", "Tree Trimming", "Garden Landscaping"], 4.9, 88, 5),
        ("Santosh Gupta", "Gardener", "service_gardening", ["Plant Nursery Setup", "Pesticide Spraying", "Fertilizer Addition"], 4.7, 54, 3),
        ("Vijay Kushwaha", "AC Technician", "service_ac_repair", ["Split AC Service", "Gas Filling", "Cooling Coil Repair"], 4.9, 230, 8),
        ("Karan Kanojia", "AC Technician", "service_ac_repair", ["Window AC Installation", "Thermostat Replacement", "Filter Cleaning"], 4.8, 110, 5),
        ("Arun Chauhan", "Appliance Repair", "service_appliance_repair", ["Refrigerator Gas Leak", "Washing Machine Motor", "Microwave"], 4.8, 140, 6),
        ("Mukesh Dubey", "Appliance Repair", "service_appliance_repair", ["Water Purifier Service", "Geyser Element", "Mixer Repair"], 4.7, 78, 4),
        ("Harish Rawat", "Home Care", "service_caregiver", ["Elderly Care", "Mobility Assistance", "Health Routine Support"], 4.9, 95, 6),
        ("Gaurav Tripathi", "Home Care", "service_caregiver", ["Patient Care", "Post-Op Monitoring", "Daily Wellness"], 4.9, 105, 7),
    ]

    workers = {}
    for i, (name, profession, s_id, skills, rating, jobs, exp) in enumerate(worker_specs, 1):
        wid = f"worker_{i:03d}"
        email_prefix = name.lower().replace(" ", ".")
        workers[wid] = {
            "uid": wid,
            "name": name,
            "email": f"{email_prefix}@savia-workers.com",
            "phone": f"+919812345{i:03d}",
            "profileImage": f"https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&fit=crop&crop=faces",
            "role": "worker",
            "profession": profession,
            "isVerified": True,
            "isActive": True,
            "isAvailable": (i % 5 != 0),
            "rating": rating,
            "totalJobs": jobs,
            "experienceYears": exp,
            "skills": skills,
            "serviceIds": [s_id],
            "location": {
                "latitude": 26.7550 + (i * 0.002),
                "longitude": 83.3750 + (i * 0.002),
            },
            "serviceAreas": ["Civil Lines", "Golghar", "Betiahata", "Medical College Road", "Gorakhpur"],
            "createdAt": now - timedelta(days=90 - i * 2),
            "updatedAt": now - timedelta(days=i),
        }

    # -------------------------------------------------------------------------
    # 4. BOOKINGS (25 realistic bookings)
    # -------------------------------------------------------------------------
    booking_configs = [
        # (user_idx, worker_idx, service_key, status, amount, days_offset, notes)
        (1, 1, "service_electrician", "completed", 450, -14, "Master bedroom main switchboard repair and fan regulator replacement."),
        (2, 5, "service_cleaning", "completed", 899, -13, "Full 3BHK deep cleaning before family festival."),
        (3, 3, "service_plumbing", "completed", 350, -12, "Kitchen sink drainage pipe unclogging and tap seal replacement."),
        (4, 7, "service_carpenter", "completed", 650, -11, "Main door lock replacement with digital smart lock setup."),
        (5, 9, "service_painting", "completed", 1200, -10, "Living room feature wall texture painting with waterproof primer."),
        (6, 11, "service_mechanic", "completed", 550, -9, "Activa 6G general service, brake tightening and oil filter replacement."),
        (7, 15, "service_ac_repair", "completed", 950, -8, "Split AC deep jet pump service and coolant gas top-up."),
        (8, 17, "service_appliance_repair", "completed", 400, -7, "LG Front load washing machine vibration diagnosis."),
        (9, 19, "service_caregiver", "completed", 1200, -6, "Elderly home assistance and mobility routine support."),
        (10, 13, "service_gardening", "completed", 350, -5, "Trimming front lawn grass and rose plant pruning."),
        (1, 2, "service_electrician", "completed", 500, -4, "Installing 4 new LED ceiling panel lights in hall."),
        (2, 4, "service_plumbing", "completed", 400, -3, "Bathroom geyser outlet hot water pipe leaking fix."),
        (3, 6, "service_cleaning", "completed", 750, -2, "Sofa set dry cleaning and carpet sanitization."),
        (4, 8, "service_carpenter", "completed", 450, -1, "Wardrobe hinge repair and drawer slider replacement."),
        (5, 16, "service_ac_repair", "completed", 800, -1, "Bedroom 1.5 ton AC cooling coil check."),
        (6, 10, "service_painting", "in_progress", 1400, 0, "Balcony railing rust cleaning and weather coat repaint."),
        (7, 18, "service_appliance_repair", "in_progress", 450, 0, "Samsung Double Door Refrigerator defrost timer replacement."),
        (8, 20, "service_caregiver", "worker_on_way", 1500, 0, "Weekend post-op patient care and vitals tracking."),
        (9, 12, "service_mechanic", "arrived", 600, 0, "Royal Enfield Classic 350 battery check & clutch adjustment."),
        (10, 14, "service_gardening", "confirmed", 300, 1, "Fertilizer distribution and flower bed maintenance."),
        (1, 15, "service_ac_repair", "confirmed", 1100, 2, "Outdoor compressor capacitor replacement."),
        (2, 7, "service_carpenter", "accepted", 550, 2, "Wooden dining chair leg joint fixing and polishing."),
        (3, 1, "service_electrician", "requested", 350, 3, "Inverter backup connection check in garage."),
        (4, 3, "service_plumbing", "cancelled", 300, -15, "Customer rescheduled due to sudden travel."),
        (5, 5, "service_cleaning", "rejected", 800, -16, "Worker was already booked for requested slot."),
    ]

    bookings = {}
    for i, (u_idx, w_idx, s_key, status, amount, days_offset, notes) in enumerate(booking_configs, 1):
        bid = f"booking_{i:03d}"
        u_id = f"user_{u_idx:03d}"
        w_id = f"worker_{w_idx:03d}"
        user_info = users[u_id]

        sched_date = now + timedelta(days=days_offset, hours=(i % 8) + 9)
        bookings[bid] = {
            "bookingId": bid,
            "customerId": u_id,
            "workerId": w_id,
            "serviceId": s_key,
            "status": status,
            "scheduledAt": sched_date,
            "amount": amount,
            "address": user_info["address"],
            "location": user_info["location"],
            "notes": notes,
            "createdAt": sched_date - timedelta(days=2),
            "updatedAt": now if status in ["in_progress", "worker_on_way", "arrived"] else sched_date,
        }

    # -------------------------------------------------------------------------
    # 5. REVIEWS (15 reviews for the 15 completed bookings)
    # -------------------------------------------------------------------------
    completed_bids = [bid for bid, b in bookings.items() if b["status"] == "completed"]
    review_templates = [
        (4, ["✨ Professional", "⚡ On time", "🛠 Great work"], "Fantastic job! Arrived strictly on time, brought all necessary tools and finished the work cleanly without any mess."),
        (4, ["✨ Professional", "🛠 Great work", "😊 Friendly"], "Extremely polite and knowledgeable. Explained the issue clearly and fixed it in 30 minutes. Highly recommended!"),
        (3, ["⚡ On time", "💰 Fair price"], "Very satisfied with the quick response and reasonable pricing. Good service overall."),
        (4, ["✨ Professional", "🧹 Clean work", "🛠 Great work"], "Top notch work quality! Cleaned the area after completing the installation. 5 stars experience."),
        (3, ["🛠 Great work", "😊 Friendly"], "Great communication and very skilled. Fixed our long pending problem efficiently."),
        (4, ["✨ Professional", "⚡ On time", "💰 Fair price"], "Great experience with Savia. Genuine spare parts used and bill was transparent."),
        (4, ["🧹 Clean work", "✨ Professional"], "Very neat and thorough work. Will definitely book again through Savia for any home services."),
        (4, ["✨ Professional", "⚡ On time"], "Prompt arrival and skilled technician. Resolved the issue on the first visit."),
        (3, ["💰 Fair price", "🛠 Great work"], "Honest pricing and reliable work. Very happy with the result."),
        (4, ["😊 Friendly", "✨ Professional", "🛠 Great work"], "Super helpful and polite. Highly skilled and finished everything with perfection!"),
    ]

    reviews = {}
    for i, bid in enumerate(completed_bids[:15], 1):
        rid = f"review_{i:03d}"
        b = bookings[bid]
        exp, tags, comment = review_templates[(i - 1) % len(review_templates)]
        reviews[rid] = {
            "reviewId": rid,
            "bookingId": bid,
            "customerId": b["customerId"],
            "workerId": b["workerId"],
            "experience": exp,
            "tags": tags,
            "comment": comment,
            "createdAt": b["scheduledAt"] + timedelta(hours=2),
        }

    # -------------------------------------------------------------------------
    # 6. PAYMENTS (25 payments corresponding to bookings)
    # -------------------------------------------------------------------------
    payments = {}
    for i, (bid, b) in enumerate(bookings.items(), 1):
        pid = f"payment_{i:03d}"
        if b["status"] in ["completed", "in_progress", "worker_on_way", "arrived"]:
            p_status = "paid"
        elif b["status"] in ["confirmed", "accepted"]:
            p_status = "processing" if i % 2 == 0 else "pending"
        elif b["status"] == "cancelled":
            p_status = "refunded"
        else:
            p_status = "failed" if b["status"] == "rejected" else "pending"

        methods = ["upi", "razorpay", "card", "cash"]
        payments[pid] = {
            "paymentId": pid,
            "bookingId": bid,
            "customerId": b["customerId"],
            "workerId": b["workerId"],
            "amount": b["amount"],
            "currency": "INR",
            "status": p_status,
            "paymentMethod": methods[(i - 1) % len(methods)],
            "createdAt": b["createdAt"],
            "updatedAt": b["updatedAt"],
        }

    # -------------------------------------------------------------------------
    # 7. NOTIFICATIONS (30 notifications for customers)
    # -------------------------------------------------------------------------
    notifications = {}
    n_count = 1
    for bid, b in list(bookings.items())[:15]:
        nid = f"notification_{n_count:03d}"
        s_name = services[b["serviceId"]]["name"]
        w_name = workers[b["workerId"]]["name"]

        if b["status"] == "completed":
            title = f"Service Completed: {s_name}"
            msg = f"{w_name} has completed your {s_name} service. Please share your valuable review!"
            n_type = "service"
        elif b["status"] == "confirmed":
            title = f"Booking Confirmed #{bid[-3:]}"
            msg = f"Your {s_name} booking is confirmed with {w_name}."
            n_type = "booking"
        elif b["status"] == "in_progress":
            title = f"Service in Progress"
            msg = f"{w_name} has started working on your {s_name} request."
            n_type = "booking"
        elif b["status"] == "cancelled":
            title = f"Booking Cancelled"
            msg = f"Your booking #{bid[-3:]} was cancelled. Refund has been initiated."
            n_type = "payment"
        else:
            title = f"Booking Update #{bid[-3:]}"
            msg = f"Your service status has been updated to {b['status']}."
            n_type = "booking"

        notifications[nid] = {
            "notificationId": nid,
            "userId": b["customerId"],
            "title": title,
            "message": msg,
            "type": n_type,
            "isRead": (n_count % 2 == 0),
            "createdAt": b["updatedAt"],
        }
        n_count += 1

    # Add promotional and system notifications across users to make 30 total
    promo_templates = [
        ("Festive Discount 20% OFF 🎉", "Get flat 20% discount on AC repair and deep cleaning services this week using code SAVIA20.", "promotion"),
        ("Welcome to Savia ✨", "Find certified, background-verified professionals for all home needs right at your doorstep.", "system"),
        ("Monsoon Home Care Tips ☔", "Protect your home from seepage and dampness with verified waterproof painting experts.", "service"),
    ]

    while n_count <= 30:
        uid = f"user_{((n_count - 1) % len(users)) + 1:03d}"
        nid = f"notification_{n_count:03d}"
        title, msg, n_type = promo_templates[(n_count - 1) % len(promo_templates)]
        notifications[nid] = {
            "notificationId": nid,
            "userId": uid,
            "title": title,
            "message": msg,
            "type": n_type,
            "isRead": False,
            "createdAt": now - timedelta(days=(n_count % 10)),
        }
        n_count += 1

    return services, users, workers, bookings, reviews, payments, notifications


def seed_firestore():
    db = initialize_db()

    print("\nPreparing Savia demo dataset...")
    services, users, workers, bookings, reviews, payments, notifications = build_data()

    # Validation of references
    print("Validating data consistency and foreign references...")
    for bid, b in bookings.items():
        assert b["customerId"] in users, f"Booking {bid} references unknown user {b['customerId']}"
        assert b["workerId"] in workers, f"Booking {bid} references unknown worker {b['workerId']}"
        assert b["serviceId"] in services, f"Booking {bid} references unknown service {b['serviceId']}"

    for pid, p in payments.items():
        assert p["bookingId"] in bookings, f"Payment {pid} references unknown booking {p['bookingId']}"

    for rid, r in reviews.items():
        assert r["bookingId"] in bookings, f"Review {rid} references unknown booking {r['bookingId']}"
        assert r["workerId"] in workers, f"Review {rid} references unknown worker {r['workerId']}"

    for nid, n in notifications.items():
        assert n["userId"] in users, f"Notification {nid} references unknown user {n['userId']}"

    print("All reference integrity checks passed!\n")

    # Write to Firestore in batches
    def write_collection(col_name, items_dict):
        print(f"Writing {len(items_dict)} documents to '{col_name}'...")
        batch = db.batch()
        count = 0
        for doc_id, doc_data in items_dict.items():
            doc_ref = db.collection(col_name).document(doc_id)
            batch.set(doc_ref, doc_data, merge=True)
            count += 1
            if count % 400 == 0:
                batch.commit()
                batch = db.batch()
        batch.commit()

    write_collection("services", services)
    write_collection("users", users)
    write_collection("workers", workers)
    write_collection("bookings", bookings)
    write_collection("payments", payments)
    write_collection("reviews", reviews)
    write_collection("notifications", notifications)

    print("\n" + "=" * 40)
    print("SAVIA FIRESTORE SEED COMPLETE")
    print("=" * 40)
    print(f"Users: {len(users)}")
    print(f"Workers: {len(workers)}")
    print(f"Services: {len(services)}")
    print(f"Bookings: {len(bookings)}")
    print(f"Payments: {len(payments)}")
    print(f"Reviews: {len(reviews)}")
    print(f"Notifications: {len(notifications)}")
    print("All references validated successfully.")
    print("=" * 40 + "\n")


if __name__ == "__main__":
    seed_firestore()
